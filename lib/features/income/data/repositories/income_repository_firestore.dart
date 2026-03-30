import 'package:cloud_firestore/cloud_firestore.dart';
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
      final batch = _firestore.batch();

      for (final doc in existing.docs) {
        batch.delete(doc.reference);
      }

      for (final income in incomes) {
        final id = income['id'] as String? ?? '';
        if (id.isEmpty) continue;
        final data = Map<String, dynamic>.from(income);
        if (data['tarih'] is String) {
          data['tarih'] = Timestamp.fromDate(DateTime.parse(data['tarih']));
        }
        data['updatedAt'] = FieldValue.serverTimestamp();
        batch.set(colRef.doc(id), data);
      }

      await batch.commit();
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
      saveCategories(userId, defaultCategories);
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
      final batch = _firestore.batch();

      final existing = await colRef.get();
      for (final doc in existing.docs) {
        batch.delete(doc.reference);
      }

      for (int i = 0; i < categories.length; i++) {
        final catId = categories[i]['isim']?.toString().toLowerCase().replaceAll(' ', '_') ?? 'cat_$i';
        batch.set(colRef.doc(catId), categories[i]);
      }

      await batch.commit();
    } catch (e) {
      debugPrint('Gelir kategorileri kaydedilirken hata: $e');
      rethrow;
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
      final batch = _firestore.batch();

      final existing = await colRef.get();
      for (final doc in existing.docs) {
        batch.delete(doc.reference);
      }

      for (final income in incomes) {
        final id = income['id'] as String? ?? 'recurring_${incomes.indexOf(income)}';
        batch.set(colRef.doc(id), income);
      }

      await batch.commit();
      CacheService.set('recurring_incomes_$userId', incomes);
    } catch (e) {
      debugPrint('Tekrarlayan gelirler kaydedilirken hata: $e');
      rethrow;
    }
  }
}
