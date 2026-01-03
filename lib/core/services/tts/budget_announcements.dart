/// TTS Bütçe Bildirimleri
/// TtsService'den ayrılmış bütçe ile ilgili sesli bildirimler
library;

/// Bütçe ile ilgili TTS bildirimlerini oluşturan mixin
mixin BudgetAnnouncements {
  /// Bütçe durumu mesajı oluşturur
  String buildButceDurumMessage({
    required double kalanLimit,
    required double asilanMiktar,
  }) {
    if (asilanMiktar > 0) {
      return 'Bütçenizi ${asilanMiktar.toStringAsFixed(0)} lira aştınız';
    } else if (kalanLimit > 0) {
      return 'Bütçenizden ${kalanLimit.toStringAsFixed(0)} lira kaldı';
    } else {
      return 'Bütçeniz tam olarak harcandı';
    }
  }

  /// Kalan bütçe mesajı oluşturur
  String buildKalanButceMessage({
    required double kalanButce,
    required double butceLimiti,
  }) {
    String kalanStr = kalanButce.toStringAsFixed(0);
    String limitStr = butceLimiti.toStringAsFixed(0);

    if (kalanButce > 0) {
      return '$limitStr liralık bütçenizden $kalanStr lira kaldı.';
    } else if (kalanButce < 0) {
      return 'Bütçenizi ${(-kalanButce).toStringAsFixed(0)} lira aştınız.';
    } else {
      return 'Bütçeniz tam olarak tükendi.';
    }
  }

  /// Limit güncellendi mesajı oluşturur
  String buildLimitGucellendiMessage({required double yeniLimit}) {
    String limitStr = yeniLimit.toStringAsFixed(0);
    return 'Aylık bütçeniz $limitStr lira olarak güncellendi.';
  }

  /// Tasarruf mesajı oluşturur
  String buildTasarrufMessage({
    required double tasarruf,
    required double butceLimiti,
  }) {
    String tasarrufStr = tasarruf.abs().toStringAsFixed(0);

    if (tasarruf > 0) {
      return 'Bu ay $tasarrufStr lira tasarruf ettiniz. Tebrikler!';
    } else if (tasarruf < 0) {
      return 'Bu ay $tasarrufStr lira açık verdiniz. Dikkatli olun.';
    } else {
      return 'Bu ay tam bütçeniz kadar harcadınız.';
    }
  }
}
