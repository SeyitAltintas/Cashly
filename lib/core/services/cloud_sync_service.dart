import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:cashly/core/services/cache_service.dart';

/// Bu servis, Firebase'den (Firestore) kullanıcının tüm verilerini çekip
/// lokale (CacheService) yükler. Cihaz değiştiğinde (silip yükleme) verilerin
/// kaybolmamasını sağlar.
class CloudSyncService {
  static final _firestore = FirebaseFirestore.instance;

  static Future<void> syncAllUserData(String userId) async {
    // EC-9: Boş userId Firestore kolköküne erişim yaratabilir
    if (userId.isEmpty) {
      debugPrint('CloudSyncService: userId boş, sync atlandı.');
      return;
    }

    debugPrint(
      'CloudSyncService: Paralel senkronizasyon başlıyor... [$userId]',
    );
    try {
      final userDoc = _firestore.collection('users').doc(userId);

      final results = await Future.wait([
        userDoc.collection('expenseCategories').get(), // 0
        userDoc.collection('incomeCategories').get(), // 1
        userDoc.collection('settings').get(), // 2
      ]).timeout(const Duration(seconds: 10));

      // 1. Gider Kategorileri
      final eCategorySnap = results[0];
      final eCats = eCategorySnap.docs
          .map((d) => _sanitizeFirestoreMap(d.data()))
          .toList();
      CacheService.set('expense_categories_$userId', eCats, ttl: _cloudSyncTtl);

      // 2. Gelir Kategorileri
      final iCategorySnap = results[1];
      final iCats = iCategorySnap.docs
          .map((d) => _sanitizeFirestoreMap(d.data()))
          .toList();
      CacheService.set('income_categories_$userId', iCats, ttl: _cloudSyncTtl);

      // 3. Ayarlar (Bütçe, Gelir Hedefi, Tekrarlayanlar vb.)
      final settingsSnap = results[2];
      for (final doc in settingsSnap.docs) {
        final data = _sanitizeFirestoreMap(doc.data());
        if (doc.id == 'general') {
          final budget = data['budget'];
          if (budget is num) {
            CacheService.set(
              'budget_$userId',
              budget.toDouble(),
              ttl: _cloudSyncTtl,
            );
          }

          final categoryBudgets = data['categoryBudgets'];
          if (categoryBudgets is Map) {
            CacheService.set(
              'category_budgets_$userId',
              Map<String, double>.from(
                categoryBudgets.map(
                  (k, v) => MapEntry(k.toString(), (v as num).toDouble()),
                ),
              ),
              ttl: _cloudSyncTtl,
            );
          }

          final fixedExpenseTemplates = data['fixedExpenseTemplates'];
          if (fixedExpenseTemplates is List) {
            CacheService.set(
              'fixed_templates_$userId',
              List<Map<String, dynamic>>.from(fixedExpenseTemplates),
              ttl: _cloudSyncTtl,
            );
          }

          final voiceFeedback = data['voiceFeedback'];
          if (voiceFeedback is bool) {
            CacheService.set(
              'voice_feedback_$userId',
              voiceFeedback,
              ttl: _cloudSyncTtl,
            );
          }

          final transferHistoryLimit = data['transferHistoryLimit'];
          if (transferHistoryLimit is num) {
            CacheService.set(
              'transfer_limit_$userId',
              transferHistoryLimit.toInt(),
              ttl: _cloudSyncTtl,
            );
          }

          final defaultPaymentMethod = data['defaultPaymentMethod'];
          if (defaultPaymentMethod is String) {
            CacheService.set(
              'default_payment_method_$userId',
              defaultPaymentMethod,
              ttl: _cloudSyncTtl,
            );
          }
        } else if (doc.id == 'income') {
          final monthlyIncomeTarget = data['monthlyIncomeTarget'];
          if (monthlyIncomeTarget is num) {
            CacheService.set(
              'income_target_$userId',
              monthlyIncomeTarget.toDouble(),
              ttl: _cloudSyncTtl,
            );
          }

          final recurringIncomes = data['recurringIncomes'];
          if (recurringIncomes is List) {
            CacheService.set(
              'income_templates_$userId',
              List<Map<String, dynamic>>.from(recurringIncomes),
              ttl: _cloudSyncTtl,
            );
          }
        }
      }

      debugPrint(
        'CloudSyncService: Senkronizasyon BASARILI (Kategoriler & Ayarlar)',
      );
    } on TimeoutException {
      debugPrint(
        'CloudSyncService: Zaman aşımı (10s). Var olan cache korundu.',
      );
    } catch (e, stackTrace) {
      debugPrint('CloudSyncService: HATA: $e\n$stackTrace');
    }
  }
}

/// Buluttan gelen verilerin cache'de 24 saat boyunca canlı kalmasını sağlar.
/// (CacheService default TTL'i 5dk olduğundan uzun süreli oturumlarda
/// kategori/ayar verilerinin kaybolmaması için ayrı bir TTL kullanılır.)
const _cloudSyncTtl = Duration(hours: 24);

/// Firestore Timestamp ve iç içe Map/List'leri güvenle String/primitive'e çevirir.
/// CacheService'in Timestamp desteklememesinden kaynaklanan çökmeleri önler.
Map<String, dynamic> _sanitizeFirestoreMap(Map<String, dynamic> map) {
  final sanitized = <String, dynamic>{};
  map.forEach((key, value) {
    if (value is Timestamp) {
      sanitized[key] = value.toDate().toIso8601String();
    } else if (value is Map) {
      sanitized[key] = _sanitizeFirestoreMap(Map<String, dynamic>.from(value));
    } else if (value is List) {
      sanitized[key] = value.map((e) {
        if (e is Timestamp) return e.toDate().toIso8601String();
        if (e is Map) {
          return _sanitizeFirestoreMap(Map<String, dynamic>.from(e));
        }
        return e;
      }).toList();
    } else {
      sanitized[key] = value;
    }
  });
  return sanitized;
}
