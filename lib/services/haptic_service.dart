import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Haptic (dokunsal) geri bildirim servisi
/// Önemli işlemlerde kullanıcıya fiziksel geri bildirim sağlar
/// Ayarlar Hive veritabanında saklanır
class HapticService {
  HapticService._();

  static const String _boxName = 'haptic_settings';
  static Box? _box;

  /// Ayar anahtarları
  static const String keyMasterEnabled = 'master_enabled';
  static const String keyButtonTaps = 'button_taps';
  static const String keyNavigation = 'navigation';
  static const String keyDelete = 'delete_actions';
  static const String keySuccess = 'success_feedback';
  static const String keyError = 'error_feedback';

  /// Hive box'ı başlat
  static Future<void> init() async {
    _box = await Hive.openBox(_boxName);
  }

  /// Box'a erişim
  static Box get _settings {
    if (_box == null || !_box!.isOpen) {
      throw Exception('HapticService not initialized. Call init() first.');
    }
    return _box!;
  }

  /// Ayar değerini al
  static bool getSetting(String key, {bool defaultValue = true}) {
    try {
      return _settings.get(key, defaultValue: defaultValue) as bool;
    } catch (e) {
      return defaultValue;
    }
  }

  /// Ayar değerini kaydet
  static Future<void> setSetting(String key, bool value) async {
    try {
      await _settings.put(key, value);
    } catch (e) {
      // Hata durumunda sessizce devam et
    }
  }

  /// Ana anahtar etkin mi kontrol et
  static bool get isEnabled => getSetting(keyMasterEnabled, defaultValue: true);

  /// Tüm ayarları döndür
  static Map<String, bool> getAllSettings() {
    return {
      keyMasterEnabled: getSetting(keyMasterEnabled, defaultValue: true),
      keyButtonTaps: getSetting(keyButtonTaps, defaultValue: true),
      keyNavigation: getSetting(keyNavigation, defaultValue: true),
      keyDelete: getSetting(keyDelete, defaultValue: true),
      keySuccess: getSetting(keySuccess, defaultValue: true),
      keyError: getSetting(keyError, defaultValue: true),
    };
  }

  /// Cihazın titreşim desteği olup olmadığını kontrol eder
  static Future<bool> hasVibrator() async {
    try {
      return await Vibration.hasVibrator() == true;
    } catch (e) {
      return false;
    }
  }

  /// Titreşim yapılabilir mi kontrol et
  static Future<bool> _canVibrate(String settingKey) async {
    if (!isEnabled) return false;
    if (!getSetting(settingKey, defaultValue: true)) return false;
    return await hasVibrator();
  }

  /// Hafif titreşim - Buton tıklamaları için (50ms)
  static Future<void> lightImpact() async {
    if (!await _canVibrate(keyButtonTaps)) return;
    Vibration.vibrate(duration: 50, amplitude: 50);
    HapticFeedback.lightImpact();
  }

  /// Orta titreşim - Önemli işlemler için (100ms)
  static Future<void> mediumImpact() async {
    if (!await _canVibrate(keyButtonTaps)) return;
    Vibration.vibrate(duration: 100, amplitude: 128);
    HapticFeedback.mediumImpact();
  }

  /// Ağır titreşim - Kritik işlemler için (200ms)
  static Future<void> heavyImpact() async {
    if (!await _canVibrate(keyButtonTaps)) return;
    Vibration.vibrate(duration: 200, amplitude: 255);
    HapticFeedback.heavyImpact();
  }

  /// Seçim titreşimi - Navigasyon ve liste seçimleri için
  static Future<void> selectionClick() async {
    if (!await _canVibrate(keyNavigation)) return;
    Vibration.vibrate(duration: 30, amplitude: 40);
    HapticFeedback.selectionClick();
  }

  /// Başarı titreşimi - İşlem tamamlandığında (çift titreşim)
  static Future<void> success() async {
    if (!await _canVibrate(keySuccess)) return;
    Vibration.vibrate(pattern: [0, 50, 50, 100], intensities: [0, 128, 0, 200]);
    HapticFeedback.mediumImpact();
  }

  /// Hata titreşimi - Hata durumlarında (uzun titreşim)
  static Future<void> error() async {
    if (!await _canVibrate(keyError)) return;
    Vibration.vibrate(duration: 300, amplitude: 255);
    HapticFeedback.heavyImpact();
  }

  /// Uyarı titreşimi - Dikkat gerektiren durumlar
  static Future<void> warning() async {
    if (!await _canVibrate(keyError)) return;
    Vibration.vibrate(duration: 75, amplitude: 100);
    HapticFeedback.lightImpact();
  }

  /// Silme titreşimi - Silme işlemleri için güçlü titreşim
  static Future<void> delete() async {
    if (!await _canVibrate(keyDelete)) return;
    Vibration.vibrate(duration: 150, amplitude: 200);
    HapticFeedback.heavyImpact();
  }
}
