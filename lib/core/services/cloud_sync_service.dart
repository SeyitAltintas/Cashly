import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:cashly/core/services/cache_service.dart';

/// Bu servis, Firebase'den (Firestore) kullanıcının tüm verilerini çekip
/// lokale (CacheService) yükler. Cihaz değiştiğinde (silip yükleme) verilerin
/// kaybolmamasını sağlar.
class CloudSyncService {
  static final _firestore = FirebaseFirestore.instance;

  static Future<void> syncAllUserData(String userId) async {
    debugPrint("CloudSyncService: Buluttan senkronize ediliyor... [$userId]");
    try {
      final userDoc = _firestore.collection('users').doc(userId);

      // 1. Gelirler
      final incomesSnap = await userDoc.collection('incomes').get();
      if (incomesSnap.docs.isNotEmpty) {
        final incomes = incomesSnap.docs.map((d) {
          final data = d.data();
          if (data['tarih'] is Timestamp) {
            data['tarih'] = (data['tarih'] as Timestamp).toDate().toIso8601String();
          }
          return data;
        }).toList();
        CacheService.set('incomes_$userId', incomes);
      } else {
        CacheService.set('incomes_$userId', <Map<String, dynamic>>[]);
      }

      // 2. Giderler
      final expensesSnap = await userDoc.collection('expenses').get();
      if (expensesSnap.docs.isNotEmpty) {
        final expenses = expensesSnap.docs.map((d) {
          final data = d.data();
          if (data['tarih'] is Timestamp) {
            data['tarih'] = (data['tarih'] as Timestamp).toDate().toIso8601String();
          }
          return data;
        }).toList();
        CacheService.set('expenses_$userId', expenses);
      } else {
        CacheService.set('expenses_$userId', <Map<String, dynamic>>[]);
      }

      // 3. Varlıklar
      final assetsSnap = await userDoc.collection('assets').get();
      if (assetsSnap.docs.isNotEmpty) {
        final assets = assetsSnap.docs.map((d) {
          final data = d.data();
          if (data['lastUpdated'] is Timestamp) {
            data['lastUpdated'] = (data['lastUpdated'] as Timestamp).toDate().toIso8601String();
          }
          return data;
        }).toList();
        CacheService.set('assets_$userId', assets);
      } else {
        CacheService.set('assets_$userId', <Map<String, dynamic>>[]);
      }

      // 4. Ödeme Yöntemleri
      final paymentSnap = await userDoc.collection('paymentMethods').get();
      if (paymentSnap.docs.isNotEmpty) {
        final methods = paymentSnap.docs.map((d) {
          final data = d.data();
          if (data['createdAt'] is Timestamp) {
            data['createdAt'] = (data['createdAt'] as Timestamp).toDate().toIso8601String();
          }
          return data;
        }).toList();
        CacheService.set('payment_methods_$userId', methods);
      } else {
        CacheService.set('payment_methods_$userId', <Map<String, dynamic>>[]);
      }

      // 5. Transferler
      final transferSnap = await userDoc.collection('transfers').get();
      if (transferSnap.docs.isNotEmpty) {
        final transfers = transferSnap.docs.map((d) {
          final data = d.data();
          if (data['date'] is Timestamp) {
            data['date'] = (data['date'] as Timestamp).toDate().toIso8601String();
          }
          return data;
        }).toList();
        CacheService.set('transfers_$userId', transfers);
      } else {
        CacheService.set('transfers_$userId', <Map<String, dynamic>>[]);
      }

      // 6. Gider Kategorileri
      final eCategorySnap = await userDoc.collection('expenseCategories').get();
      if (eCategorySnap.docs.isNotEmpty) {
        final cats = eCategorySnap.docs.map((d) => d.data()).toList();
        CacheService.set('expense_categories_$userId', cats);
      }

      // 7. Gelir Kategorileri
      final iCategorySnap = await userDoc.collection('incomeCategories').get();
      if (iCategorySnap.docs.isNotEmpty) {
        final cats = iCategorySnap.docs.map((d) => d.data()).toList();
        CacheService.set('income_categories_$userId', cats);
      }

      debugPrint("CloudSyncService: Senkronizasyon BASARILI!");
    } catch (e, stackTrace) {
      debugPrint("CloudSyncService: HATA: $e\n$stackTrace");
    }
  }
}
