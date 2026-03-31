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
        userDoc.collection('incomes').get(),          // 0
        userDoc.collection('expenses').get(),         // 1
        userDoc.collection('assets').get(),           // 2
        userDoc.collection('paymentMethods').get(),   // 3
        userDoc.collection('transfers').get(),        // 4
        userDoc.collection('expenseCategories').get(), // 5
        userDoc.collection('incomeCategories').get(), // 6
      ]).timeout(const Duration(seconds: 20));

      // 1. Gelirler
      final incomesSnap = results[0];
      final incomes = incomesSnap.docs.map((d) {
        final data = Map<String, dynamic>.from(d.data());
        if (data['tarih'] is Timestamp) {
          data['tarih'] = (data['tarih'] as Timestamp).toDate().toIso8601String();
        }
        return data;
      }).toList();
      CacheService.set('incomes_$userId', incomes, ttl: _cloudSyncTtl);

      // 2. Giderler
      final expensesSnap = results[1];
      final expenses = expensesSnap.docs.map((d) {
        final data = Map<String, dynamic>.from(d.data());
        if (data['tarih'] is Timestamp) {
          data['tarih'] = (data['tarih'] as Timestamp).toDate().toIso8601String();
        }
        return data;
      }).toList();
      CacheService.set('expenses_$userId', expenses, ttl: _cloudSyncTtl);

      // 3. Varlıklar
      final assetsSnap = results[2];
      final assets = assetsSnap.docs.map((d) {
        final data = Map<String, dynamic>.from(d.data());
        if (data['lastUpdated'] is Timestamp) {
          data['lastUpdated'] = (data['lastUpdated'] as Timestamp).toDate().toIso8601String();
        }
        return data;
      }).toList();
      CacheService.set('assets_$userId', assets, ttl: _cloudSyncTtl);

      // 4. Ödeme Yöntemleri
      final paymentSnap = results[3];
      final methods = paymentSnap.docs.map((d) {
        final data = Map<String, dynamic>.from(d.data());
        if (data['createdAt'] is Timestamp) {
          data['createdAt'] = (data['createdAt'] as Timestamp).toDate().toIso8601String();
        }
        return data;
      }).toList();
      CacheService.set('payment_methods_$userId', methods, ttl: _cloudSyncTtl);

      // 5. Transferler (EC-5: Timestamp dönüşümü eklendi)
      final transferSnap = results[4];
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

      // 6. Gider Kategorileri
      final eCategorySnap = results[5];
      if (eCategorySnap.docs.isNotEmpty) {
        final cats = eCategorySnap.docs.map((d) => Map<String, dynamic>.from(d.data())).toList();
        CacheService.set('expense_categories_$userId', cats, ttl: _cloudSyncTtl);
      }

      // 7. Gelir Kategorileri
      final iCategorySnap = results[6];
      if (iCategorySnap.docs.isNotEmpty) {
        final cats = iCategorySnap.docs.map((d) => Map<String, dynamic>.from(d.data())).toList();
        CacheService.set('income_categories_$userId', cats, ttl: _cloudSyncTtl);
      }

      debugPrint('CloudSyncService: Senkronizasyon BASARILI! '
          '(G:${incomes.length} H:${expenses.length} V:${assets.length} '
          'ÖY:${methods.length} T:${transfers.length})');
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
