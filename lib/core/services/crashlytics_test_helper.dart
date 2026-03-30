import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// Firebase Crashlytics test yardımcısı
/// Sadece debug modda çalışır, production'da devre dışıdır
class CrashlyticsTestHelper {
  /// Test crash gönder - Crashlytics Console'da görünür
  /// Uygulamayı ÇÖKERTİR (fatal crash simülasyonu)
  static void sendTestCrash() {
    if (kDebugMode) {
      debugPrint('🔥 Crashlytics test crash gönderiliyor...');
    }
    FirebaseCrashlytics.instance.crash();
  }

  /// Non-fatal hata gönder - Uygulama ÇÖKMEZ
  /// Crashlytics Console'da "Non-fatals" sekmesinde görünür
  static Future<void> sendTestNonFatal() async {
    try {
      throw Exception('Cashly test non-fatal error - ${DateTime.now()}');
    } catch (e, stack) {
      await FirebaseCrashlytics.instance.recordError(
        e,
        stack,
        reason: 'Cashly Crashlytics Test (non-fatal)',
        fatal: false,
      );
      if (kDebugMode) {
        debugPrint('✅ Non-fatal test hatası Crashlytics\'e gönderildi');
      }
    }
  }

  /// Custom log gönder - Console'da crash detaylarında görünür
  static Future<void> sendTestLog() async {
    FirebaseCrashlytics.instance.log('Cashly test log - ${DateTime.now()}');
    await FirebaseCrashlytics.instance.setCustomKey('test_key', 'test_value');
    await FirebaseCrashlytics.instance.setCustomKey('environment', 'development');
    if (kDebugMode) {
      debugPrint('✅ Test log ve custom key\'ler Crashlytics\'e gönderildi');
    }
  }
}
