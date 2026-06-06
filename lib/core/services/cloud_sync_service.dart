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
      if (eCategorySnap.docs.isNotEmpty) {
        final cats = eCategorySnap.docs.map((d) => _sanitizeFirestoreMap(d.data())).toList();
        CacheService.set('expense_categories_$userId', cats, ttl: _cloudSyncTtl);
      }

      // 2. Gelir Kategorileri
      final iCategorySnap = results[1];
      if (iCategorySnap.docs.isNotEmpty) {
        final cats = iCategorySnap.docs.map((d) => _sanitizeFirestoreMap(d.data())).toList();
        CacheService.set('income_categories_$userId', cats, ttl: _cloudSyncTtl);
      }

      // 3. Ayarlar (Bütçe, Gelir Hedefi, Tekrarlayanlar vb.)
      final settingsSnap = results[2];
      for (final doc in settingsSnap.docs) {
        final data = _sanitizeFirestoreMap(doc.data());
        if (doc.id == 'general') {
          if (data.containsKey('budget')) {
            CacheService.set(
              'budget_$userId',
              (data['budget'] as num).toDouble(),
              ttl: _cloudSyncTtl,
            );
          }
          if (data.containsKey('fixedExpenseTemplates')) {
            CacheService.set(
              'fixed_templates_$userId',
              List<Map<String, dynamic>>.from(
                data['fixedExpenseTemplates'] as List,
              ),
              ttl: _cloudSyncTtl,
            );
          }
        } else if (doc.id == 'income') {
          if (data.containsKey('monthlyIncomeTarget')) {
            CacheService.set(
              'income_target_$userId',
              (data['monthlyIncomeTarget'] as num).toDouble(),
              ttl: _cloudSyncTtl,
            );
          }
          if (data.containsKey('recurringIncomes')) {
            CacheService.set(
              'income_templates_$userId',
              List<Map<String, dynamic>>.from(data['recurringIncomes'] as List),
              ttl: _cloudSyncTtl,
            );
          }
        }
      }

      debugPrint('CloudSyncService: Senkronizasyon BASARILI (Kategoriler & Ayarlar)');
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
        if (e is Map) return _sanitizeFirestoreMap(Map<String, dynamic>.from(e));
        return e;
      }).toList();
    } else {
      sanitized[key] = value;
    }
  });
  return sanitized;
}
