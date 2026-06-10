import 'package:flutter/material.dart';

/// Ödeme yöntemi kartları için merkezi renk paleti
/// Tüm sayfalarda tutarlı görünüm sağlar
class CardColorConstants {
  CardColorConstants._();

  /// 24 adet premium kart rengi - gradient paletler
  static List<List<Color>> gradients = [
    // === KOYU TONLAR ===
    [const Color(0xFF1E1E1E), const Color(0xFF16213e)], // 1. Gece Mavisi
    [const Color(0xFF2d132c), const Color(0xFF432371)], // 2. Derin Mor
    [const Color(0xFF0f3460), const Color(0xFF16537e)], // 3. Okyanus Mavisi
    [const Color(0xFF1e5128), const Color(0xFF4e9f3d)], // 4. Orman Yeşili
    [const Color(0xFF5c2018), const Color(0xFF8b3a2f)], // 5. Bordo
    [const Color(0xFF3d3d3d), const Color(0xFF5a5a5a)], // 6. Grafit
    // === METALİK TONLAR ===
    [const Color(0xFF232526), const Color(0xFF414345)], // 7. Karbon Siyah
    [const Color(0xFF283048), const Color(0xFF859398)], // 8. Çelik Gri
    [const Color(0xFF4b3621), const Color(0xFF8b6914)], // 9. Bronz
    [const Color(0xFF1f1c2c), const Color(0xFF928DAB)], // 10. Gümüş Mor
    [const Color(0xFF0F2027), const Color(0xFF2C5364)], // 11. Titanyum
    [const Color(0xFF141E30), const Color(0xFF243B55)], // 12. Midnight Blue
    // === SICAK TONLAR ===
    [const Color(0xFF642B73), const Color(0xFFC6426E)], // 13. Magenta
    [const Color(0xFF833ab4), const Color(0xFFfd1d1d)], // 14. Günbatımı
    [const Color(0xFFb91d73), const Color(0xFFf953c6)], // 15. Neon Pembe
    [const Color(0xFF6D0EB5), const Color(0xFF4059F1)], // 16. Elektrik Mor
    [const Color(0xFFc31432), const Color(0xFF240b36)], // 17. Şarap Kırmızısı
    [const Color(0xFFeb3349), const Color(0xFFf45c43)], // 18. Ateş Kırmızısı
    // === SOĞUK TONLAR ===
    [const Color(0xFF11998e), const Color(0xFF38ef7d)], // 19. Zümrüt
    [const Color(0xFF00b4db), const Color(0xFF0083b0)], // 20. Turkuaz
    [const Color(0xFF1CB5E0), const Color(0xFF000851)], // 21. Elektrik Mavi
    [const Color(0xFF00c9ff), const Color(0xFF92fe9d)], // 22. Aurora
    [const Color(0xFF373B44), const Color(0xFF4286f4)], // 23. Safir
    [const Color(0xFF134E5E), const Color(0xFF71B280)], // 24. Deniz Yeşili
  ];

  /// Güvenli index ile gradient al (sınır dışı değerleri clamp eder)
  static List<Color> getGradient(int index) {
    return gradients[index.clamp(0, gradients.length - 1)];
  }

  /// Toplam renk sayısı
  static int get count => gradients.length;
}
