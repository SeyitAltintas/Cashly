import 'package:flutter/material.dart';

/// Uygulama genelinde kullanılan renk sabitleri
/// Tüm hardcoded renkleri merkezi bir yerde toplar
class ColorConstants {
  // Private constructor - statik sabitler olarak kullanılacak
  ColorConstants._();

  // ============================================================================
  // ANA TEMA RENKLERİ
  // ============================================================================

  /// Neon Mor - Ana tema rengi (Primary)
  static const Color neonMor = Color(0xFF9D00FF);

  /// Açık Mor - İkincil tema rengi (Secondary)
  static const Color acikMor = Color(0xFFBB86FC);

  /// Parlak Mor - Gradient ve vurgularda kullanılır
  static const Color parlakMor = Color(0xFF7F00FF);

  /// Derin Mor - Gradient başlangıcı
  static const Color derinMor = Color(0xFF2E004F);

  // ============================================================================
  // SURFACE & BACKGROUND RENKLERİ
  // ============================================================================

  /// Saf Siyah - Ana arkaplan rengi
  static const Color safSiyah = Color(0xFF000000);

  /// Koyu Surface - Kart ve surface elemanları için
  static const Color koyuSurface = Color(0xFF121212);

  /// Orta Koyu Surface - Dialog ve sheet elemanları için
  static const Color ortaKoyuSurface = Color(0xFF1E1E1E);

  // ============================================================================
  // SİSTEM RENKLERİ
  // ============================================================================

  /// Hata Rengi - Error mesajları ve uyarılar için
  static const Color hataRengi = Color(0xFFCF6679);

  /// Koyu Kırmızı - Silme işlemleri ve tehlikeli aksiyonlar
  static const Color koyuKirmizi = Color(0xFFB71C1C); // Colors.red.shade900

  /// Kırmızı Vurgu - Uyarı mesajları ve harcama teması
  static const Color kirmiziVurgu = Color(0xFFE53935); // Colors.red.shade600

  /// Yeşil - Başarı mesajları
  static const Color yesil = Color(0xFF4CAF50); // Colors.green

  /// Gri - Placeholder ve devre dışı öğeler
  static const Color gri = Color(0xFF9E9E9E); // Colors.grey

  // ============================================================================
  // KATEGORİ RENKLERİ (Analiz & Varlıklar)
  // ============================================================================

  /// Turuncu Vurgu - Yemek & Kafe kategorisi
  static const Color turuncuVurgu = Color(0xFFFFAB40); // Colors.orangeAccent

  /// Yeşil Vurgu - Market & Atıştırmalık kategorisi
  static const Color yesilVurgu = Color(0xFF69F0AE); // Colors.greenAccent

  /// Mavi Vurgu - Araç & Ulaşım kategorisi, Banka varlıkları
  static const Color maviVurgu = Color(0xFF448AFF); // Colors.blueAccent

  /// Mor Vurgu - Hediye & Özel kategorisi
  static const Color morVurgu = Color(0xFFE040FB); // Colors.purpleAccent

  /// Pembe Vurgu - Ek kategoriler için
  static const Color pembeVurgu = Color(0xFFFF4081); // Colors.pinkAccent

  /// Camgöbeği Vurgu - Ek kategoriler için
  static const Color camgobegiVurgu = Color(0xFF18FFFF); // Colors.tealAccent

  /// Amber Vurgu - Ek kategoriler için
  static const Color amberVurgu = Color(0xFFFFD740); // Colors.amberAccent

  /// Açık Yeşil Vurgu - Ek kategoriler için
  static const Color acikYesilVurgu = Color(
    0xFFB2FF59,
  ); // Colors.lightGreenAccent

  // ============================================================================
  // VARLIK KATEGORİ RENKLERİ
  // ============================================================================

  /// Amber - Altın varlıkları için
  static const Color amber = Color(0xFFFFC107); // Colors.amber

  /// Mavi Gri - Gümüş varlıkları için
  static const Color maviGri = Color(0xFF607D8B); // Colors.blueGrey

  // ============================================================================
  // YARDIMCI METODLAR
  // ============================================================================

  /// Kategori adına göre renk döndürür (Harcama kategorileri için)
  static Color getColorForExpenseCategory(String category) {
    switch (category.toLowerCase()) {
      case 'yemek & kafe':
      case 'yemek':
      case 'kafe':
        return turuncuVurgu;
      case 'market & atıştırmalık':
      case 'market':
      case 'atıştırmalık':
        return yesilVurgu;
      case 'araç & ulaşım':
      case 'araç':
      case 'ulaşım':
        return maviVurgu;
      case 'hediye & özel':
      case 'hediye':
      case 'özel':
        return morVurgu;
      case 'sabit giderler':
        return kirmiziVurgu;
      default:
        return gri;
    }
  }

  /// Kategori adına göre renk döndürür (Varlık kategorileri için)
  static Color getColorForAssetCategory(String category) {
    switch (category.toLowerCase()) {
      case 'altın':
        return amber;
      case 'döviz':
        return yesil;
      case 'kripto':
        return turuncuVurgu;
      case 'banka':
        return maviVurgu;
      case 'gümüş':
        return maviGri;
      default:
        return acikMor;
    }
  }

  /// Grafiklerde kullanılmak üzere renkli palet
  static List<Color> get chartColorPalette => [
    kirmiziVurgu,
    turuncuVurgu,
    maviVurgu,
    pembeVurgu,
    camgobegiVurgu,
    amberVurgu,
    acikYesilVurgu,
  ];

  /// Doluluk oranına göre renk döndürür (Bütçe göstergesi için)
  static Color getColorForBudgetRatio(double ratio) {
    if (ratio > 0.8) return kirmiziVurgu;
    if (ratio > 0.5) return turuncuVurgu;
    return acikMor;
  }
}
