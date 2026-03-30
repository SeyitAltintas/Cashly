import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'secure_storage_service.dart';

/// Hataları (Exceptions/Crash) kalıcı olarak localde tutan
/// ve internet olduğunda Crashlytics/Sentry (veya kendi sunucunuz)
/// gibi yerlere toplu göndermeye yarayan Servis.
class ErrorLoggerService {
  static const String _boxName = 'error_logs';
  static bool _isInitialized = false;

  static Future<void> init() async {
    if (!_isInitialized) {
      // Eğer box önceden açılmadıysa aç
      if (!Hive.isBoxOpen(_boxName)) {
        await SecureStorageService.openSecureBox<String>(_boxName);
      }
      _isInitialized = true;
    }
  }

  /// Yeni bir hata logu kaydeder
  static Future<void> logError(String message, {String? stackTrace}) async {
    if (!_isInitialized) await init();
    try {
      final box = Hive.box<String>(_boxName);
      final timestamp = DateTime.now().toIso8601String();
      final logEntry = '[$timestamp] $message\nStack: ${stackTrace ?? "Belirtilmedi"}';
      
      await box.add(logEntry);
      
      // Hata raporlarını şişirmemek için limit: Son 100 hatayı tut, en eskiyi sil
      if (box.length > 100) {
        await box.deleteAt(0);
      }
      
      if (kDebugMode) {
        debugPrint('📝 Hata Kalıcı Olarak Loglandı: $message');
      }
    } catch (e) {
      debugPrint('Loglama Hatası: $e');
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

  /// Tüm logları siler (Örn: sunucuya (Sentry/Crashlytics) gönderildikten sonra)
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
