import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/services/cache_service.dart';
import '../../domain/repositories/income_repository.dart';
import '../../../../core/services/network_service.dart';

/// Gelir repository implementasyonu (Firestore)
class IncomeRepositoryFirestore implements IncomeRepository {
  final _firestore = FirebaseFirestore.instance;

  static List<Map<String, dynamic>> get defaultCategories => [
    {'isim': 'Maaş', 'ikon': 'work'},
    {'isim': 'Freelance', 'ikon': 'laptop'},
    {'isim': 'Yatırım', 'ikon': 'trending_up'},
    {'isim': 'Kira Geliri', 'ikon': 'home'},
    {'isim': 'Hediye', 'ikon': 'card_giftcard'},
    {'isim': 'Diğer', 'ikon': 'category'},
  ];

  DocumentReference _userDoc(String userId) =>
      _firestore.collection('users').doc(userId);

  @override
  List<Map<String, dynamic>> getIncomes(String userId) {
    final cacheKey = 'incomes_$userId';
    final cached = CacheService.get<List<Map<String, dynamic>>>(cacheKey);
    if (cached != null) return cached;
    return [];
  }

  Stream<List<Map<String, dynamic>>> watchIncomes(String userId) {
    return _userDoc(userId)
        .collection('incomes')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      final incomes = snapshot.docs.map((doc) {
        final data = doc.data();
        if (data['date'] is Timestamp) {
          data['date'] = (data['date'] as Timestamp).toDate().toIso8601String();
        }
        return data;
      }).toList();
      CacheService.set('incomes_$userId', incomes);
      return incomes;
    });
  }

  @override
  Stream<List<Map<String, dynamic>>> watchIncomesByMonth(String userId, DateTime month) {
    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(month.year, month.month + 1, 0, 23, 59, 59, 999);
    
    return _userDoc(userId)
        .collection('incomes')
        .where('date', isGreaterThanOrEqualTo: startOfMonth.toIso8601String())
        .where('date', isLessThanOrEqualTo: endOfMonth.toIso8601String())
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        if (data['date'] is Timestamp) {
          data['date'] = (data['date'] as Timestamp).toDate().toIso8601String();
        }
        return data;
      }).toList();
    });
  }

  @override
  Future<void> addIncome(String userId, Map<String, dynamic> income) async {
    try {
      if ((income['id']?.toString() ?? '').isEmpty) {
        throw Exception('Gelir eklenirken ID eksik!');
      }
      final docRef = _userDoc(userId).collection('incomes').doc(income['id'].toString());
      final data = Map<String, dynamic>.from(income);
      if (data['tarih'] is String) {
        data['tarih'] = Timestamp.fromDate(DateTime.parse(data['tarih']));
      }
      data['updatedAt'] = FieldValue.serverTimestamp();
      await docRef.set(data);

      // Cache'i güncelle
      final cacheKey = 'incomes_$userId';
      final cached = CacheService.get<List<Map<String, dynamic>>>(cacheKey) ?? [];
      if (!cached.any((i) => i['id'] == income['id'])) {
        cached.add(income);
        CacheService.set(cacheKey, cached);
      }
    } catch (e) {
      debugPrint('Firestore gelir ekleme hatası: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateIncome(String userId, Map<String, dynamic> income) async {
    try {
      if ((income['id']?.toString() ?? '').isEmpty) {
        throw Exception('Gelir güncellenirken ID eksik!');
      }
      final docRef = _userDoc(userId).collection('incomes').doc(income['id'].toString());
      final data = Map<String, dynamic>.from(income);
      if (data['date'] is String) {
        data['date'] = Timestamp.fromDate(DateTime.parse(data['date']));
      }
      data['updatedAt'] = FieldValue.serverTimestamp();
      await docRef.update(data);

      // Cache'i güncelle
      final cacheKey = 'incomes_$userId';
      final cached = CacheService.get<List<Map<String, dynamic>>>(cacheKey) ?? [];
      final index = cached.indexWhere((i) => i['id'] == income['id']);
      if (index != -1) {
        cached[index] = income;
        CacheService.set(cacheKey, cached);
      }
    } catch (e) {
      debugPrint('Firestore gelir güncelleme hatası: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteIncome(String userId, String incomeId) async {
    try {
      final docRef = _userDoc(userId).collection('incomes').doc(incomeId);
      await docRef.delete();

      // Cache'i güncelle
      final cacheKey = 'incomes_$userId';
      final cached = CacheService.get<List<Map<String, dynamic>>>(cacheKey) ?? [];
      cached.removeWhere((i) => i['id'] == incomeId);
      CacheService.set(cacheKey, cached);
    } catch (e) {
      debugPrint('Firestore gelir silme hatası: $e');
      rethrow;
    }
  }

  @override
  List<Map<String, dynamic>> getCategories(String userId) {
    try {
      final cached = CacheService.get<List<Map<String, dynamic>>>(
          'income_categories_$userId');
      if (cached != null) return cached;
      // EC-2: Sadece Firebase oturumu varken Firestore'a yaz (döngü/crash önleme)
      if (FirebaseAuth.instance.currentUser != null) {
        saveCategories(userId, defaultCategories).catchError((e) {
          debugPrint('Varsayılan gelir kategorileri yazılamadı: $e');
        });
      }
      return defaultCategories;
    } catch (e) {
      return defaultCategories;
    }
  }

  @override
  Future<void> saveCategories(
    String userId,
    List<Map<String, dynamic>> categories,
  ) async {
    try {
      final colRef = _userDoc(userId).collection('incomeCategories');
      final getOptions = NetworkService().isOffline
          ? const GetOptions(source: Source.cache)
          : const GetOptions();
      final existing = await colRef.get(getOptions);
      // EC-1: Batch 500 limit için chunk'lara böl
      await _commitInChunks([
        ...existing.docs.map((d) => _BatchOp(d.reference, null)),
        ...List.generate(categories.length, (i) {
          final catId = categories[i]['isim']?.toString().toLowerCase().replaceAll(' ', '_') ?? 'cat_$i';
          return _BatchOp(colRef.doc(catId), categories[i]);
        }),
      ]);
    } on TimeoutException {
      debugPrint('Gelir kategorileri zaman aşımı.');
    } catch (e) {
      debugPrint('Gelir kategorileri kaydedilirken hata: $e');
      rethrow;
    }
  }

  /// EC-1: Firestore batch 500 döküman limitini aşmamak için işlemleri bölümlere ayır
  Future<void> _commitInChunks(List<_BatchOp> ops) async {
    const chunkSize = 450;
    for (int i = 0; i < ops.length; i += chunkSize) {
      final chunk = ops.sublist(i, (i + chunkSize).clamp(0, ops.length));
      final batch = _firestore.batch();
      for (final op in chunk) {
        if (op.data == null) {
          batch.delete(op.ref);
        } else {
          batch.set(op.ref, op.data!);
        }
      }
      if (NetworkService().isOffline) {
        batch.commit();
      } else {
        await batch.commit().timeout(const Duration(seconds: 10));
      }
    }
  }

  @override
  List<Map<String, dynamic>> getRecurringIncomes(String userId) {
    try {
      return CacheService.get<List<Map<String, dynamic>>>(
              'recurring_incomes_$userId') ??
          [];
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> saveRecurringIncomes(
    String userId,
    List<Map<String, dynamic>> incomes,
  ) async {
    try {
      final colRef = _userDoc(userId).collection('recurringIncomes');
      final getOptions = NetworkService().isOffline
          ? const GetOptions(source: Source.cache)
          : const GetOptions();
      final existing = await colRef.get(getOptions);

      final ops = [
        ...existing.docs.map((d) => _BatchOp(d.reference, null)),
        ...incomes.asMap().entries.map((e) {
          final id =
              e.value['id'] as String? ?? 'recurring_${e.key}';
          return _BatchOp(colRef.doc(id), e.value);
        }),
      ];
      await _commitInChunks(ops);
      CacheService.set('recurring_incomes_$userId', incomes);
    } catch (e) {
      debugPrint('Tekrarlayan gelirler kaydedilirken hata: $e');
      rethrow;
    }
  }

  // ===== GELİR HEDEFİ =====

  @override
  double getIncomeTarget(String userId) {
    final cacheKey = 'income_target_$userId';
    final cached = CacheService.get<double>(cacheKey);
    if (cached != null) return cached;
    return 0.0;
  }

  Stream<double> watchIncomeTarget(String userId) {
    return _userDoc(userId)
        .collection('settings')
        .doc('income')
        .snapshots()
        .map((doc) {
      final target = (doc.data()?['monthlyIncomeTarget'] as num?)?.toDouble() ?? 0.0;
      CacheService.set('income_target_$userId', target);
      return target;
    });
  }

  @override
  Future<void> saveIncomeTarget(String userId, double target) async {
    try {
      await _userDoc(userId).collection('settings').doc('income').set({
        'monthlyIncomeTarget': target,
      }, SetOptions(merge: true));
      CacheService.set('income_target_$userId', target);
    } catch (e) {
      debugPrint('Gelir hedefi kaydedilirken hata: $e');
      rethrow;
    }
  }

  // ===== TEKRARlAYAN GELİR ŞABLONLARI (Gelir Ayarları) =====

  @override
  List<Map<String, dynamic>> getRecurringIncomeTemplates(String userId) {
    try {
      return CacheService.get<List<Map<String, dynamic>>>(
              'income_templates_$userId') ??
          [];
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> saveRecurringIncomeTemplates(
    String userId,
    List<Map<String, dynamic>> templates,
  ) async {
    try {
      await _userDoc(userId).collection('settings').doc('income').set({
        'recurringIncomes': templates,
      }, SetOptions(merge: true));
      CacheService.set('income_templates_$userId', templates);
    } catch (e) {
      debugPrint('Tekrarlayan gelir şablonları kaydedilirken hata: $e');
      rethrow;
    }
  }
}

/// EC-1 yardimci sinif: Batch islemini temsil eder (set veya delete)
class _BatchOp {
  final DocumentReference ref;
  final Map<String, dynamic>? data;
  const _BatchOp(this.ref, this.data);
}

