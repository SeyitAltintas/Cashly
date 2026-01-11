import 'package:flutter/material.dart';

/// Ödeme yöntemi kartları için merkezi renk paleti
/// Tüm sayfalarda tutarlı görünüm sağlar
class CardColorConstants {
  CardColorConstants._();

  /// 24 adet premium kart rengi - gradient paletler
  static const List<List<Color>> gradients = [
    // === KOYU TONLAR ===
    [Color(0xFF1a1a2e), Color(0xFF16213e)], // 1. Gece Mavisi
    [Color(0xFF2d132c), Color(0xFF432371)], // 2. Derin Mor
    [Color(0xFF0f3460), Color(0xFF16537e)], // 3. Okyanus Mavisi
    [Color(0xFF1e5128), Color(0xFF4e9f3d)], // 4. Orman Yeşili
    [Color(0xFF5c2018), Color(0xFF8b3a2f)], // 5. Bordo
    [Color(0xFF3d3d3d), Color(0xFF5a5a5a)], // 6. Grafit
    // === METALİK TONLAR ===
    [Color(0xFF232526), Color(0xFF414345)], // 7. Karbon Siyah
    [Color(0xFF283048), Color(0xFF859398)], // 8. Çelik Gri
    [Color(0xFF4b3621), Color(0xFF8b6914)], // 9. Bronz
    [Color(0xFF1f1c2c), Color(0xFF928DAB)], // 10. Gümüş Mor
    [Color(0xFF0F2027), Color(0xFF2C5364)], // 11. Titanyum
    [Color(0xFF141E30), Color(0xFF243B55)], // 12. Midnight Blue
    // === SICAK TONLAR ===
    [Color(0xFF642B73), Color(0xFFC6426E)], // 13. Magenta
    [Color(0xFF833ab4), Color(0xFFfd1d1d)], // 14. Günbatımı
    [Color(0xFFb91d73), Color(0xFFf953c6)], // 15. Neon Pembe
    [Color(0xFF6D0EB5), Color(0xFF4059F1)], // 16. Elektrik Mor
    [Color(0xFFc31432), Color(0xFF240b36)], // 17. Şarap Kırmızısı
    [Color(0xFFeb3349), Color(0xFFf45c43)], // 18. Ateş Kırmızısı
    // === SOĞUK TONLAR ===
    [Color(0xFF11998e), Color(0xFF38ef7d)], // 19. Zümrüt
    [Color(0xFF00b4db), Color(0xFF0083b0)], // 20. Turkuaz
    [Color(0xFF1CB5E0), Color(0xFF000851)], // 21. Elektrik Mavi
    [Color(0xFF00c9ff), Color(0xFF92fe9d)], // 22. Aurora
    [Color(0xFF373B44), Color(0xFF4286f4)], // 23. Safir
    [Color(0xFF134E5E), Color(0xFF71B280)], // 24. Deniz Yeşili
  ];

  /// Güvenli index ile gradient al (sınır dışı değerleri clamp eder)
  static List<Color> getGradient(int index) {
    return gradients[index.clamp(0, gradients.length - 1)];
  }

  /// Toplam renk sayısı
  static int get count => gradients.length;
}
