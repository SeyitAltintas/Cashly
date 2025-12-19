import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

/// Haptic (dokunsal) geri bildirim servisi
/// Önemli işlemlerde kullanıcıya fiziksel geri bildirim sağlar
class HapticService {
  HapticService._();

  /// Cihazın titreşim desteği olup olmadığını kontrol eder
  static Future<bool> hasVibrator() async {
    try {
      return await Vibration.hasVibrator() == true;
    } catch (e) {
      return false;
    }
  }

  /// Hafif titreşim - Buton tıklamaları için (50ms)
  static Future<void> lightImpact() async {
    if (await hasVibrator()) {
      Vibration.vibrate(duration: 50, amplitude: 50);
    }
    HapticFeedback.lightImpact();
  }

  /// Orta titreşim - Önemli işlemler için (100ms)
  static Future<void> mediumImpact() async {
    if (await hasVibrator()) {
      Vibration.vibrate(duration: 100, amplitude: 128);
    }
    HapticFeedback.mediumImpact();
  }

  /// Ağır titreşim - Kritik işlemler için (200ms)
  static Future<void> heavyImpact() async {
    if (await hasVibrator()) {
      Vibration.vibrate(duration: 200, amplitude: 255);
    }
    HapticFeedback.heavyImpact();
  }

  /// Seçim titreşimi - Liste seçimleri için
  static Future<void> selectionClick() async {
    if (await hasVibrator()) {
      Vibration.vibrate(duration: 30, amplitude: 40);
    }
    HapticFeedback.selectionClick();
  }

  /// Başarı titreşimi - İşlem tamamlandığında (çift titreşim)
  static Future<void> success() async {
    if (await hasVibrator()) {
      Vibration.vibrate(
        pattern: [0, 50, 50, 100],
        intensities: [0, 128, 0, 200],
      );
    }
    HapticFeedback.mediumImpact();
  }

  /// Hata titreşimi - Hata durumlarında (uzun titreşim)
  static Future<void> error() async {
    if (await hasVibrator()) {
      Vibration.vibrate(duration: 300, amplitude: 255);
    }
    HapticFeedback.heavyImpact();
  }

  /// Uyarı titreşimi - Dikkat gerektiren durumlar
  static Future<void> warning() async {
    if (await hasVibrator()) {
      Vibration.vibrate(duration: 75, amplitude: 100);
    }
    HapticFeedback.lightImpact();
  }

  /// Silme titreşimi - Silme işlemleri için güçlü titreşim
  static Future<void> delete() async {
    if (await hasVibrator()) {
      Vibration.vibrate(duration: 150, amplitude: 200);
    }
    HapticFeedback.heavyImpact();
  }
}
