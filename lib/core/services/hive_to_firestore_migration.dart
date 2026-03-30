import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

/// Hive → Firestore tek seferlik veri migrasyon servisi
class HiveToFirestoreMigration {
  final _firestore = FirebaseFirestore.instance;

  Future<MigrationResult> migrate(String hiveUserId, String firebaseUid) async {
    try {
      final userDoc = _firestore.collection('users').doc(firebaseUid);
      final box = Hive.box('cashly_box');

      int migratedCount = 0;

      // 1. Harcamaları taşı
      migratedCount += await _migrateList(
        box, 'harcamalar_$hiveUserId', userDoc, 'expenses',
        convertTimestamps: true,
      );

      // 2. Gelirleri taşı
      migratedCount += await _migrateList(
        box, 'gelirler_$hiveUserId', userDoc, 'incomes',
        convertTimestamps: true,
      );

      // 3. Varlıkları taşı
      migratedCount += await _migrateList(
        box, 'varliklar_$hiveUserId', userDoc, 'assets',
      );
      migratedCount += await _migrateList(
        box, 'silinen_varliklar_$hiveUserId', userDoc, 'deletedAssets',
      );

      // 4. Ödeme yöntemlerini taşı
      migratedCount += await _migrateList(
        box, 'odeme_yontemleri_$hiveUserId', userDoc, 'paymentMethods',
      );
      migratedCount += await _migrateList(
        box, 'silinen_odeme_yontemleri_$hiveUserId', userDoc, 'deletedPaymentMethods',
      );
      migratedCount += await _migrateList(
        box, 'transferler_$hiveUserId', userDoc, 'transfers',
      );

      // 5. Kategorileri taşı
      migratedCount += await _migrateList(
        box, 'kategoriler_$hiveUserId', userDoc, 'expenseCategories',
        idField: 'isim',
      );
      migratedCount += await _migrateList(
        box, 'gelir_kategorileri_$hiveUserId', userDoc, 'incomeCategories',
        idField: 'isim',
      );

      // 6. Sabit gider şablonları taşı
      migratedCount += await _migrateList(
        box, 'sabit_gider_sablonlari_$hiveUserId', userDoc, 'fixedExpenseTemplates',
      );

      // 7. Tekrarlayan gelirler taşı
      migratedCount += await _migrateList(
        box, 'tekrarlayan_gelirler_$hiveUserId', userDoc, 'recurringIncomes',
      );

      // 8. Ayarları tek dokümanda taşı
      final categoryBudgets = box.get('kategori_butceleri_$hiveUserId');
      await userDoc.collection('settings').doc('general').set({
        'budget': box.get('butce_limiti_$hiveUserId', defaultValue: 8000.0),
        'defaultPaymentMethod': box.get('varsayilan_odeme_yontemi_$hiveUserId'),
        'voiceFeedback': box.get('sesli_geri_bildirim_$hiveUserId', defaultValue: true),
        'transferHistoryLimit': box.get('transfer_gecmisi_limiti_$hiveUserId', defaultValue: 30),
        if (categoryBudgets != null)
          'categoryBudgets': Map<String, dynamic>.from(categoryBudgets),
      });

      // 9. Streak verisini taşı
      if (Hive.isBoxOpen('streak_box')) {
        final streakBox = Hive.box('streak_box');
        final streakData = streakBox.get('streak_$hiveUserId');
        if (streakData != null) {
          await userDoc.collection('settings').doc('streak').set(
            Map<String, dynamic>.from(streakData),
          );
        }
      }

      // 10. Haptic ayarlarını taşı
      if (Hive.isBoxOpen('haptic_settings')) {
        final hapticBox = Hive.box('haptic_settings');
        await userDoc.collection('settings').doc('haptic').set({
          'master_enabled': hapticBox.get('master_enabled', defaultValue: true),
          'button_taps': hapticBox.get('button_taps', defaultValue: true),
          'navigation': hapticBox.get('navigation', defaultValue: true),
          'delete_actions': hapticBox.get('delete_actions', defaultValue: true),
          'success_feedback': hapticBox.get('success_feedback', defaultValue: true),
          'error_feedback': hapticBox.get('error_feedback', defaultValue: true),
          'celebration_feedback': hapticBox.get('celebration_feedback', defaultValue: true),
        });
      }

      // 11. Bildirim ayarlarını taşı
      if (Hive.isBoxOpen('notification_settings')) {
        final notifBox = Hive.box('notification_settings');
        final notifData = notifBox.get('settings');
        if (notifData != null) {
          await userDoc.collection('settings').doc('notification').set(
            Map<String, dynamic>.from(notifData),
          );
        }
      }

      return MigrationResult(
        success: true,
        message: '$migratedCount kayıt başarıyla taşındı',
        migratedCount: migratedCount,
      );
    } catch (e) {
      debugPrint('Migrasyon hatası: $e');
      return MigrationResult(
        success: false,
        message: 'Migrasyon hatası: $e',
        migratedCount: 0,
      );
    }
  }

  Future<int> _migrateList(
    Box box,
    String hiveKey,
    DocumentReference userDoc,
    String collection, {
    bool convertTimestamps = false,
    String idField = 'id',
  }) async {
    final items = box.get(hiveKey, defaultValue: []);
    if (items is! List || items.isEmpty) return 0;

    // Firestore batch limiti: 500 doküman
    const batchLimit = 450;
    int count = 0;

    for (int i = 0; i < items.length; i += batchLimit) {
      final batch = _firestore.batch();
      final end = (i + batchLimit < items.length) ? i + batchLimit : items.length;

      for (int j = i; j < end; j++) {
        final map = Map<String, dynamic>.from(items[j]);
        final id = map[idField]?.toString() ?? const Uuid().v4();
        map['id'] = map['id'] ?? id;

        if (convertTimestamps && map['tarih'] is String) {
          try {
            map['tarih'] = Timestamp.fromDate(DateTime.parse(map['tarih']));
          } catch (_) {
            // Geçersiz tarih formatı, string olarak bırak
          }
        }

        final docId = id.toLowerCase().replaceAll(' ', '_');
        batch.set(userDoc.collection(collection).doc(docId), map);
        count++;
      }

      await batch.commit();
    }

    return count;
  }
}

class MigrationResult {
  final bool success;
  final String message;
  final int migratedCount;

  MigrationResult({
    required this.success,
    required this.message,
    required this.migratedCount,
  });
}
