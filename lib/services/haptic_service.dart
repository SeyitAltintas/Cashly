import 'package:flutter/services.dart';

/// Haptic (dokunsal) geri bildirim servisi
/// Önemli işlemlerde kullanıcıya fiziksel geri bildirim sağlar
class HapticService {
  HapticService._();

  /// Hafif titreşim - Buton tıklamaları için
  static Future<void> lightImpact() async {
    await HapticFeedback.lightImpact();
  }

  /// Orta titreşim - Önemli işlemler için
  static Future<void> mediumImpact() async {
    await HapticFeedback.mediumImpact();
  }

  /// Ağır titreşim - Kritik işlemler için
  static Future<void> heavyImpact() async {
    await HapticFeedback.heavyImpact();
  }

  /// Seçim titreşimi - Liste seçimleri için
  static Future<void> selectionClick() async {
    await HapticFeedback.selectionClick();
  }

  /// Başarı titreşimi - İşlem tamamlandığında
  static Future<void> success() async {
    await HapticFeedback.mediumImpact();
  }

  /// Hata titreşimi - Hata durumlarında
  static Future<void> error() async {
    await HapticFeedback.heavyImpact();
  }

  /// Uyarı titreşimi - Dikkat gerektiren durumlar
  static Future<void> warning() async {
    await HapticFeedback.lightImpact();
  }
}
