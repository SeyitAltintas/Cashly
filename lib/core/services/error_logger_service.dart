import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'secure_storage_service.dart';

/// Hibrit Hata Loglama Servisi
/// 1. Lokal Hive'a yazar (offline yedek)
/// 2. Firebase Crashlytics'e gönderir (bulut takibi)
///
/// İnternet olmadığında Crashlytics kendi kuyruk mekanizmasını kullanır.
/// Lokal loglar ise flushLogsToCloud() ile toplu gönderilip temizlenebilir.
class ErrorLoggerService {
  static const String _boxName = 'error_logs';
  static bool _isInitialized = false;

  static Future<void> init() async {
    if (!_isInitialized) {
      if (!Hive.isBoxOpen(_boxName)) {
        await SecureStorageService.openSecureBox<String>(_boxName);
      }
      _isInitialized = true;
    }
  }

  /// Yeni bir hata logu kaydeder (Hibrit: Lokal + Crashlytics)
  static Future<void> logError(String message, {String? stackTrace}) async {
    if (!_isInitialized) await init();

    // 1. Lokale yaz (offline yedek)
    try {
      final box = Hive.box<String>(_boxName);
      final timestamp = DateTime.now().toIso8601String();
      final logEntry =
          '[$timestamp] $message\nStack: ${stackTrace ?? "Belirtilmedi"}';

      await box.add(logEntry);

      // Son 100 hatayı tut
      if (box.length > 100) {
        await box.deleteAt(0);
      }

      if (kDebugMode) {
        debugPrint('📝 Hata Loglandı: $message');
      }
    } catch (e) {
      debugPrint('Lokal loglama hatası: $e');
    }

    // 2. Crashlytics'e gönder (internet varsa anında, yoksa kuyrukta bekler)
    try {
      FirebaseCrashlytics.instance.log(message);
      await FirebaseCrashlytics.instance.recordError(
        Exception(message),
        stackTrace != null ? StackTrace.fromString(stackTrace) : null,
        reason: message,
        fatal: false,
      );
    } catch (e) {
      // Firebase henüz başlatılmadıysa veya Crashlytics erişilemezse sessizce devam et
      if (kDebugMode) {
        debugPrint('Crashlytics gönderim hatası: $e');
      }
    }
  }

  /// İnternet geldiğinde lokal logları Crashlytics'e toplu gönder ve temizle
  static Future<void> flushLogsToCloud() async {
    final logs = getAllLogs();
    if (logs.isEmpty) return;

    try {
      for (final log in logs) {
        FirebaseCrashlytics.instance.log(log);
      }
      await clearLogs();
      if (kDebugMode) {
        debugPrint('✅ ${logs.length} log Crashlytics\'e gönderildi ve lokal temizlendi');
      }
    } catch (e) {
      debugPrint('Toplu log gönderim hatası: $e');
    }
  }

  /// Crashlytics'te kullanıcı bilgisi ayarla (auth sonrası çağrılmalı)
  static Future<void> setUser(String userId, {String? userName}) async {
    try {
      await FirebaseCrashlytics.instance.setUserIdentifier(userId);
      if (userName != null) {
        await FirebaseCrashlytics.instance.setCustomKey('userName', userName);
      }
    } catch (e) {
      debugPrint('Crashlytics kullanıcı ayarlama hatası: $e');
    }
  }

  /// Kayıtlı tüm hataları getirir
  static List<String> getAllLogs() {
    if (!_isInitialized) return [];
    try {
      final box = Hive.box<String>(_boxName);
      return box.values.toList();
    } catch (e) {
      return [];
    }
  }

  /// Tüm logları siler (sunucuya gönderildikten sonra)
  static Future<void> clearLogs() async {
    if (!_isInitialized) return;
    try {
      final box = Hive.box<String>(_boxName);
      await box.clear();
    } catch (e) {
      debugPrint('Log temizleme hatası: $e');
    }
  }
}
