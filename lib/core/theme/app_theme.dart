import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Varsayılan tema için sayfa bazlı renkler
class PageThemeColors {
  // Ana renkler - Siyaha yakın gri ve beyaza yakın gri
  static const Color darkGray = Color(0xFF2D2D2D); // Siyaha yakın gri (Primary)
  static const Color lightGray = Color(
    0xFFE0E0E0,
  ); // Beyaza yakın gri (Secondary)

  // Harcamalar sayfası
  static const Color expensePrimary = darkGray;
  static const Color expenseSecondary = lightGray;

  // Gelirler sayfası - Yeşil (özel renk korunuyor)
  static const Color incomePrimary = Color(0xFF4CAF50);
  static const Color incomeSecondary = Color(0xFF81C784);

  // Varlıklar sayfası - Lacivert (özel renk korunuyor)
  static const Color assetsPrimary = Color(0xFF1A237E);
  static const Color assetsSecondary = Color(0xFF3949AB);

  // Varsayılan (Profil, Ayarlar vs.)
  static const Color defaultPrimary = darkGray;
  static const Color defaultSecondary = lightGray;

  // Kart ikonları için çeşitli renkler
  static const List<Color> iconColors = [
    Color(0xFFE91E63), // Pink
    Color(0xFF9C27B0), // Purple
    Color(0xFF673AB7), // Deep Purple
    Color(0xFF3F51B5), // Indigo
    Color(0xFF2196F3), // Blue
    Color(0xFF00BCD4), // Cyan
    Color(0xFF009688), // Teal
    Color(0xFF4CAF50), // Green
    Color(0xFFFF9800), // Orange
    Color(0xFFF44336), // Red
  ];

  /// Index'e göre ikon rengi getir (döngüsel)
  static Color getIconColor(int index) {
    return iconColors[index % iconColors.length];
  }
}

/// Uygulama teması için merkezi sınıf
/// Tek tema: Varsayılan koyu tema
class AppTheme {
  // Private constructor - statik metodlarla kullanılacak
  AppTheme._();

  /// Varsayılan Tema - Koyu gri / açık gri renk şeması
  static ThemeData get defaultTheme {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: const Color(0xFF000000),
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
      colorScheme: const ColorScheme.dark(
        primary: PageThemeColors.darkGray,
        secondary: PageThemeColors.lightGray,
        surface: Color(0xFF121212),
        error: Color(0xFFCF6679),
        brightness: Brightness.dark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF000000),
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: PageThemeColors.lightGray),
      ),
      cardTheme: const CardThemeData(
        color: Color(0xFF121212),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: PageThemeColors.darkGray,
        foregroundColor: Colors.white,
      ),
    );
  }

  /// Tüm mevcut temaların listesi (artık sadece varsayılan)
  static List<ThemeData> get allThemes => [defaultTheme];

  /// Tema isimlerinin listesi
  static List<String> get themeNames => ['Varsayılan'];

  /// Index'e göre tema getir (her zaman varsayılan döner)
  static ThemeData getThemeByIndex(int index) {
    return _applyNoSplash(defaultTheme);
  }

  /// Varsayılan tema mı kontrol et (artık her zaman true)
  static bool isDefaultTheme(int index) => true;

  /// Temaya ripple/splash kaldırma uygula
  static ThemeData _applyNoSplash(ThemeData theme) {
    return theme.copyWith(
      splashFactory: NoSplash.splashFactory,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          splashFactory: NoSplash.splashFactory,
        ).merge(theme.elevatedButtonTheme.style),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          splashFactory: NoSplash.splashFactory,
        ).merge(theme.textButtonTheme.style),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          splashFactory: NoSplash.splashFactory,
        ).merge(theme.outlinedButtonTheme.style),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          splashFactory: NoSplash.splashFactory,
        ).merge(theme.iconButtonTheme.style),
      ),
    );
  }

  /// Tema adına göre tema getir (her zaman varsayılan döner)
  static ThemeData getThemeByName(String name) {
    return getThemeByIndex(0);
  }
}
