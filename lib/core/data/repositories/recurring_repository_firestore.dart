import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../domain/repositories/recurring_repository.dart';

/// Tekrarlayan işlem repository - Firestore implementasyonu
///
/// Koleksiyon yapısı:
///   users/{uid}/recurring/fixed_expenses   → sabit gider şablonları (tek doküman)
///   users/{uid}/recurring/recurring_incomes → tekrarlayan gelirler (tek doküman)
class RecurringRepositoryFirestore implements RecurringRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  DocumentReference _recurringDoc(String userId, String docId) => _firestore
      .collection('users')
      .doc(userId)
      .collection('recurring')
      .doc(docId);

  // ===== SABİT GİDER ŞABLONLARI =====

  @override
  List<Map<String, dynamic>> getFixedExpenseTemplates(String userId) {
    // Sync interface — cache için kullanılır, gerçek veri için fetch kullan
    return [];
  }

  /// Firestore'dan sabit gider şablonlarını çeker
  Future<List<Map<String, dynamic>>> fetchFixedExpenseTemplates(String userId) async {
    try {
      final doc = await _recurringDoc(userId, 'fixed_expenses').get();
      if (!doc.exists) return [];
      final data = doc.data() as Map<String, dynamic>?;
      final list = data?['templates'] as List<dynamic>? ?? [];
      return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (e) {
      debugPrint('Firestore sabit gider şablonları getirilirken hata: $e');
      return [];
    }
  }

  @override
  Future<void> saveFixedExpenseTemplates(
    String userId,
    List<Map<String, dynamic>> templates,
  ) async {
    try {
      await _recurringDoc(userId, 'fixed_expenses').set({
        'templates': templates,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Firestore sabit gider şablonları kaydedilirken hata: $e');
      rethrow;
    }
  }

  // ===== TEKRARLAYAN GELİRLER =====

  @override
  List<Map<String, dynamic>> getRecurringIncomes(String userId) {
    return [];
  }

  /// Firestore'dan tekrarlayan gelirleri çeker
  Future<List<Map<String, dynamic>>> fetchRecurringIncomes(String userId) async {
    try {
      final doc = await _recurringDoc(userId, 'recurring_incomes').get();
      if (!doc.exists) return [];
      final data = doc.data() as Map<String, dynamic>?;
      final list = data?['incomes'] as List<dynamic>? ?? [];
      return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (e) {
      debugPrint('Firestore tekrarlayan gelirler getirilirken hata: $e');
      return [];
    }
  }

  @override
  Future<void> saveRecurringIncomes(
    String userId,
    List<Map<String, dynamic>> incomes,
  ) async {
    try {
      await _recurringDoc(userId, 'recurring_incomes').set({
        'incomes': incomes,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Firestore tekrarlayan gelirler kaydedilirken hata: $e');
      rethrow;
    }
  }
}
