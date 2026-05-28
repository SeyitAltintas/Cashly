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

    debugPrint('CloudSyncService: Paralel senkronizasyon başlıyor... [$userId]');
    try {
      final userDoc = _firestore.collection('users').doc(userId);

      // EC-4: Sequential await yerine paralel çekme - 7 koleksiyonu aynı anda iste
      final results = await Future.wait([
        // Incomes and Expenses are now loaded lazily by month, skipped here
        userDoc.collection('assets').get(),           // 0
        userDoc.collection('paymentMethods').get(),   // 1
        userDoc.collection('transfers').get(),        // 2
        userDoc.collection('expenseCategories').get(), // 3
        userDoc.collection('incomeCategories').get(), // 4
        userDoc.collection('settings').get(),         // 5
      ]).timeout(const Duration(seconds: 20));

      // 1. Varlıklar
      final assetsSnap = results[0];
      final assets = assetsSnap.docs.map((d) {
        final data = Map<String, dynamic>.from(d.data());
        if (data['lastUpdated'] is Timestamp) {
          data['lastUpdated'] = (data['lastUpdated'] as Timestamp).toDate().toIso8601String();
        }
        return data;
      }).toList();
      CacheService.set('assets_$userId', assets, ttl: _cloudSyncTtl);

      // 2. Ödeme Yöntemleri
      final paymentSnap = results[1];
      final methods = paymentSnap.docs.map((d) {
        final data = Map<String, dynamic>.from(d.data());
        if (data['createdAt'] is Timestamp) {
          data['createdAt'] = (data['createdAt'] as Timestamp).toDate().toIso8601String();
        }
        return data;
      }).toList();
      CacheService.set('payment_methods_$userId', methods, ttl: _cloudSyncTtl);

      // 3. Transferler (EC-5: Timestamp dönüşümü eklendi)
      final transferSnap = results[2];
      final transfers = transferSnap.docs.map((d) {
        final data = Map<String, dynamic>.from(d.data());
        if (data['date'] is Timestamp) {
          data['date'] = (data['date'] as Timestamp).toDate().toIso8601String();
        }
        if (data['tarih'] is Timestamp) {
          data['tarih'] = (data['tarih'] as Timestamp).toDate().toIso8601String();
        }
        return data;
      }).toList();
      CacheService.set('transfers_$userId', transfers, ttl: _cloudSyncTtl);

      // 4. Gider Kategorileri
      final eCategorySnap = results[3];
      if (eCategorySnap.docs.isNotEmpty) {
        final cats = eCategorySnap.docs.map((d) => Map<String, dynamic>.from(d.data())).toList();
        CacheService.set('expense_categories_$userId', cats, ttl: _cloudSyncTtl);
      }

      // 5. Gelir Kategorileri
      final iCategorySnap = results[4];
      if (iCategorySnap.docs.isNotEmpty) {
        final cats = iCategorySnap.docs.map((d) => Map<String, dynamic>.from(d.data())).toList();
        CacheService.set('income_categories_$userId', cats, ttl: _cloudSyncTtl);
      }

      // 6. Ayarlar (Bütçe, Gelir Hedefi, Tekrarlayanlar vb.)
      final settingsSnap = results[5];
      for (final doc in settingsSnap.docs) {
        final data = doc.data();
        if (doc.id == 'general') {
          if (data.containsKey('budget')) {
            CacheService.set('budget_$userId', (data['budget'] as num).toDouble(), ttl: _cloudSyncTtl);
          }
          if (data.containsKey('fixedExpenseTemplates')) {
            CacheService.set('fixed_templates_$userId', List<Map<String, dynamic>>.from(data['fixedExpenseTemplates'] as List), ttl: _cloudSyncTtl);
          }
        } else if (doc.id == 'income') {
          if (data.containsKey('monthlyIncomeTarget')) {
            CacheService.set('income_target_$userId', (data['monthlyIncomeTarget'] as num).toDouble(), ttl: _cloudSyncTtl);
          }
          if (data.containsKey('recurringIncomes')) {
            CacheService.set('income_templates_$userId', List<Map<String, dynamic>>.from(data['recurringIncomes'] as List), ttl: _cloudSyncTtl);
          }
        }
      }

      debugPrint('CloudSyncService: Senkronizasyon BASARILI! '
          '(V:${assets.length} ÖY:${methods.length} T:${transfers.length})');
    } on TimeoutException {
      debugPrint('CloudSyncService: Zaman aşımı (20s). Var olan cache korundu.');
    } catch (e, stackTrace) {
      debugPrint('CloudSyncService: HATA: $e\n$stackTrace');
    }
  }
}

/// Buluttan gelen verilerin cache'de 24 saat boyunca canlı kalmasını sağlar.
/// Böylece kullanıcı uygulama içinde dolaşırken 5 dakikalık TTL nedeniyle
/// veri kaybolmaz. Veri, bir sonraki girişte veya uygulama yeniden başlatıldığında yenilenir.
const _cloudSyncTtl = Duration(hours: 24);
