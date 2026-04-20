import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/services/cache_service.dart';
import '../../domain/repositories/income_repository.dart';

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
        .orderBy('tarih', descending: true)
        .snapshots()
        .map((snapshot) {
      final incomes = snapshot.docs.map((doc) {
        final data = doc.data();
        if (data['tarih'] is Timestamp) {
          data['tarih'] = (data['tarih'] as Timestamp).toDate().toIso8601String();
        }
        return data;
      }).toList();
      CacheService.set('incomes_$userId', incomes);
      return incomes;
    });
  }

  @override
  Future<void> saveIncomes(
    String userId,
    List<Map<String, dynamic>> incomes,
  ) async {
    try {
      final colRef = _userDoc(userId).collection('incomes');
      final existing = await colRef.get();

      final ops = [
        ...existing.docs.map((d) => _BatchOp(d.reference, null)),
        ...incomes
            .where((i) => (i['id'] as String? ?? '').isNotEmpty)
            .map((i) {
          final data = Map<String, dynamic>.from(i);
          if (data['tarih'] is String) {
            data['tarih'] =
                Timestamp.fromDate(DateTime.parse(data['tarih']));
          }
          data['updatedAt'] = FieldValue.serverTimestamp();
          return _BatchOp(colRef.doc(i['id'] as String), data);
        }),
      ];
      await _commitInChunks(ops);
      CacheService.set('incomes_$userId', incomes);
    } catch (e) {
      debugPrint('Firestore gelir kaydetme hatası: $e');
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
      final existing = await colRef.get();
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
      await batch.commit().timeout(const Duration(seconds: 10));
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
      final existing = await colRef.get();

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
}

/// EC-1 yardimci sinif: Batch islemini temsil eder (set veya delete)
class _BatchOp {
  final DocumentReference ref;
  final Map<String, dynamic>? data;
  const _BatchOp(this.ref, this.data);
}
