import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/services/cache_service.dart';
import '../../domain/repositories/income_repository.dart';
import '../../../../core/services/network_service.dart';
import '../../../../core/services/batch_service.dart';
import 'package:cashly/core/services/error_logger_service.dart';

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

  // GÜVENLİK/KARARLILIK YAMASI: 
  // Firestore verisi içinde 'date' harici (örneğin 'updatedAt') dönen herhangi bir Timestamp
  // Hive tarafında desteklenmediği için çökmeye sebep olur. Hepsini bulup String'e çeviren yardımcı:
  Map<String, dynamic> _sanitizeMap(Map<String, dynamic> map) {
    final sanitized = <String, dynamic>{};
    map.forEach((key, value) {
      if (value is Timestamp) {
        sanitized[key] = value.toDate().toIso8601String();
      } else if (value is Map) {
        sanitized[key] = _sanitizeMap(Map<String, dynamic>.from(value));
      } else if (value is List) {
        sanitized[key] = value.map((e) {
          if (e is Timestamp) return e.toDate().toIso8601String();
          if (e is Map) return _sanitizeMap(Map<String, dynamic>.from(e));
          return e;
        }).toList();
      } else {
        sanitized[key] = value;
      }
    });
    return sanitized;
  }

  Stream<List<Map<String, dynamic>>> watchIncomes(String userId) {
    return _userDoc(
      userId,
    ).collection('incomes').orderBy('date', descending: true).snapshots().map((
      snapshot,
    ) {
      final incomes = snapshot.docs.map((doc) => _sanitizeMap(doc.data())).toList();
      CacheService.set('incomes_$userId', incomes);
      return incomes;
    });
  }

  @override
  Stream<List<Map<String, dynamic>>> watchIncomesByMonth(
    String userId,
    DateTime month,
  ) {
    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(
      month.year,
      month.month + 1,
      0,
      23,
      59,
      59,
      999,
    );

    return _userDoc(userId)
        .collection('incomes')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth))
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => _sanitizeMap(doc.data())).toList();
        });
  }

  @override
  Future<List<Map<String, dynamic>>> fetchIncomesForDateRange(
    String userId,
    DateTime start,
    DateTime end,
  ) async {
    try {
      final snap = await _userDoc(userId)
          .collection('incomes')
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(end))
          .orderBy('date', descending: true)
          .get();
      return snap.docs.map((doc) => _sanitizeMap(doc.data())).toList();
    } catch (e, stackTrace) {
      debugPrint('fetchIncomesForDateRange hatası: $e');
      ErrorLoggerService.logError('fetchIncomesForDateRange hatası: $e', stackTrace: stackTrace.toString());
      return [];
    }
  }

  @override
  Future<void> addIncome(String userId, Map<String, dynamic> income) async {
    try {
      if ((income['id']?.toString() ?? '').isEmpty) {
        throw Exception('Gelir eklenirken ID eksik!');
      }
      final docRef = _userDoc(
        userId,
      ).collection('incomes').doc(income['id'].toString());
      final data = Map<String, dynamic>.from(income);
      if (data['date'] is String) {
        data['date'] = Timestamp.fromDate(DateTime.parse(data['date']));
      }
      data['updatedAt'] = FieldValue.serverTimestamp();
      await docRef.set(data);

      // Cache'i güncelle
      final cacheKey = 'incomes_$userId';
      final cached =
          CacheService.get<List<Map<String, dynamic>>>(cacheKey) ?? [];
      if (!cached.any((i) => i['id'] == income['id'])) {
        cached.add(income);
        CacheService.set(cacheKey, cached);
      }
    } catch (e, stackTrace) {
      debugPrint('Firestore gelir ekleme hatası: $e');
      ErrorLoggerService.logError('Firestore gelir ekleme hatası: $e', stackTrace: stackTrace.toString());
      rethrow;
    }
  }

  @override
  Future<void> updateIncome(String userId, Map<String, dynamic> income) async {
    try {
      if ((income['id']?.toString() ?? '').isEmpty) {
        throw Exception('Gelir güncellenirken ID eksik!');
      }
      final docRef = _userDoc(
        userId,
      ).collection('incomes').doc(income['id'].toString());
      final data = Map<String, dynamic>.from(income);
      if (data['date'] is String) {
        data['date'] = Timestamp.fromDate(DateTime.parse(data['date']));
      }
      data['updatedAt'] = FieldValue.serverTimestamp();
      await docRef.update(data);

      // Cache'i güncelle
      final cacheKey = 'incomes_$userId';
      final cached =
          CacheService.get<List<Map<String, dynamic>>>(cacheKey) ?? [];
      final index = cached.indexWhere((i) => i['id'] == income['id']);
      if (index != -1) {
        cached[index] = income;
        CacheService.set(cacheKey, cached);
      }
    } catch (e, stackTrace) {
      debugPrint('Firestore gelir güncelleme hatası: $e');
      ErrorLoggerService.logError('Firestore gelir güncelleme hatası: $e', stackTrace: stackTrace.toString());
      rethrow;
    }
  }

  @override
  BatchOperation getUpdateIncomeOperation(
    String userId,
    Map<String, dynamic> income,
  ) {
    if ((income['id']?.toString() ?? '').isEmpty) {
      throw Exception('Gelir güncellenirken ID eksik!');
    }

    final data = Map<String, dynamic>.from(income);
    if (data['date'] is String) {
      data['date'] = Timestamp.fromDate(DateTime.parse(data['date']));
    }
    data['updatedAt'] = FieldValue.serverTimestamp();

    return FirestoreBatchOperation(
      collectionPath: 'users/$userId/incomes',
      documentId: income['id'].toString(),
      type: BatchOperationType.update,
      data: data,
    );
  }

  @override
  BatchOperation getAddIncomeOperation(
    String userId,
    Map<String, dynamic> income,
  ) {
    if ((income['id']?.toString() ?? '').isEmpty) {
      throw Exception('Gelir eklenirken ID eksik!');
    }

    final data = Map<String, dynamic>.from(income);
    if (data['date'] is String) {
      data['date'] = Timestamp.fromDate(DateTime.parse(data['date']));
    }
    data['updatedAt'] = FieldValue.serverTimestamp();

    return FirestoreBatchOperation(
      collectionPath: 'users/$userId/incomes',
      documentId: income['id'].toString(),
      type: BatchOperationType.set,
      data: data,
    );
  }

  @override
  BatchOperation getDeleteIncomeOperation(String userId, String incomeId) {
    return FirestoreBatchOperation(
      collectionPath: 'users/$userId/incomes',
      documentId: incomeId,
      type: BatchOperationType.delete,
    );
  }

  @override
  Future<void> deleteIncome(String userId, String incomeId) async {
    try {
      final docRef = _userDoc(userId).collection('incomes').doc(incomeId);
      await docRef.delete();

      // Cache'i güncelle
      final cacheKey = 'incomes_$userId';
      final cached =
          CacheService.get<List<Map<String, dynamic>>>(cacheKey) ?? [];
      cached.removeWhere((i) => i['id'] == incomeId);
      CacheService.set(cacheKey, cached);
    } catch (e, stackTrace) {
      debugPrint('Firestore gelir silme hatası: $e');
      ErrorLoggerService.logError('Firestore gelir silme hatası: $e', stackTrace: stackTrace.toString());
      rethrow;
    }
  }

  @override
  List<Map<String, dynamic>> getCategories(String userId) {
    try {
      final cached = CacheService.get<List<Map<String, dynamic>>>(
        'income_categories_$userId',
      );
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
          final catId =
              categories[i]['isim']?.toString().toLowerCase().replaceAll(
                ' ',
                '_',
              ) ??
              'cat_$i';
          return _BatchOp(colRef.doc(catId), categories[i]);
        }),
      ]);
    } on TimeoutException {
      debugPrint('Gelir kategorileri zaman aşımı.');
    } catch (e, stackTrace) {
      debugPrint('Gelir kategorileri kaydedilirken hata: $e');
      ErrorLoggerService.logError('Gelir kategorileri kaydedilirken hata: $e', stackTrace: stackTrace.toString());
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
            'recurring_incomes_$userId',
          ) ??
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
          final id = e.value['id'] as String? ?? 'recurring_${e.key}';
          return _BatchOp(colRef.doc(id), e.value);
        }),
      ];
      await _commitInChunks(ops);
      CacheService.set('recurring_incomes_$userId', incomes);
    } catch (e, stackTrace) {
      debugPrint('Tekrarlayan gelirler kaydedilirken hata: $e');
      ErrorLoggerService.logError('Tekrarlayan gelirler kaydedilirken hata: $e', stackTrace: stackTrace.toString());
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
    return _userDoc(
      userId,
    ).collection('settings').doc('income').snapshots().map((doc) {
      final target =
          (doc.data()?['monthlyIncomeTarget'] as num?)?.toDouble() ?? 0.0;
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
    } catch (e, stackTrace) {
      debugPrint('Gelir hedefi kaydedilirken hata: $e');
      ErrorLoggerService.logError('Gelir hedefi kaydedilirken hata: $e', stackTrace: stackTrace.toString());
      rethrow;
    }
  }

  // ===== TEKRARlAYAN GELİR ŞABLONLARI (Gelir Ayarları) =====

  @override
  List<Map<String, dynamic>> getRecurringIncomeTemplates(String userId) {
    try {
      return CacheService.get<List<Map<String, dynamic>>>(
            'income_templates_$userId',
          ) ??
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
    } catch (e, stackTrace) {
      debugPrint('Tekrarlayan gelir şablonları kaydedilirken hata: $e');
      ErrorLoggerService.logError('Tekrarlayan gelir şablonları kaydedilirken hata: $e', stackTrace: stackTrace.toString());
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
