import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Uygulama temaları için merkezi sınıf
/// Farklı koyu renkli tema seçenekleri sunar
class AppTheme {
  // Private constructor - statik metodlarla kullanılacak
  AppTheme._();

  /// Koyu Mor Tema (Mevcut tema - Royal Violet)
  static ThemeData get darkPurpleTheme {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: const Color(0xFF000000), // Saf Siyah
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF7B2CBF), // Darker Purple
        secondary: Color(0xFF9D4EDD), // Medium Purple
        surface: Color(0xFF121212), // Dark Surface
        error: Color(0xFFCF6679),
        brightness: Brightness.dark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF000000),
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Color(0xFF7B2CBF)),
      ),
      cardTheme: const CardThemeData(
        color: Color(0xFF121212),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF7B2CBF),
        foregroundColor: Colors.white,
      ),
    );
  }

  /// Koyu Yeşil Tema (Emerald Night)
  static ThemeData get darkGreenTheme {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: const Color(0xFF000000), // Saf Siyah
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF2E7D32), // Green 800
        secondary: Color(0xFF43A047), // Green 600
        surface: Color(0xFF0A0A0A), // Slightly Lighter Surface
        error: Color(0xFFCF6679),
        brightness: Brightness.dark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF000000),
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Color(0xFF2E7D32)),
      ),
      cardTheme: const CardThemeData(
        color: Color(0xFF0A0A0A),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
    );
  }

  /// Koyu Mavi Tema (Ocean Deep)
  static ThemeData get darkBlueTheme {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: const Color(0xFF000000), // Saf Siyah
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF1565C0), // Blue 800
        secondary: Color(0xFF42A5F5), // Blue 400
        surface: Color(0xFF0A0A0A), // Slightly Lighter Surface
        error: Color(0xFFCF6679),
        brightness: Brightness.dark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF000000),
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Color(0xFF1565C0)),
      ),
      cardTheme: const CardThemeData(
        color: Color(0xFF0A0A0A),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF1565C0),
        foregroundColor: Colors.white,
      ),
    );
  }

  /// Koyu Kırmızı Tema (Crimson Night)
  static ThemeData get darkRedTheme {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: const Color(0xFF000000), // Saf Siyah
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFFC62828), // Red 800
        secondary: Color(0xFFEF5350), // Red 400
        surface: Color(0xFF0A0A0A), // Slightly Lighter Surface
        error: Color(0xFFCF6679),
        brightness: Brightness.dark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF000000),
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Color(0xFFC62828)),
      ),
      cardTheme: const CardThemeData(
        color: Color(0xFF0A0A0A),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFFC62828),
        foregroundColor: Colors.white,
      ),
    );
  }

  /// Koyu Turuncu Tema (Sunset Ember)
  static ThemeData get darkOrangeTheme {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: const Color(0xFF000000), // Saf Siyah
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFFEF6C00), // Orange 800
        secondary: Color(0xFFFFA726), // Orange 400
        surface: Color(0xFF0A0A0A), // Slightly Lighter Surface
        error: Color(0xFFCF6679),
        brightness: Brightness.dark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF000000),
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Color(0xFFEF6C00)),
      ),
      cardTheme: const CardThemeData(
        color: Color(0xFF0A0A0A),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFFEF6C00),
        foregroundColor: Colors.white,
      ),
    );
  }

  /// Koyu Camgöbeği Tema (Cyan Wave)
  static ThemeData get darkCyanTheme {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: const Color(0xFF000000), // Saf Siyah
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF00838F), // Cyan 800
        secondary: Color(0xFF26C6DA), // Cyan 400
        surface: Color(0xFF0A0A0A), // Slightly Lighter Surface
        error: Color(0xFFCF6679),
        brightness: Brightness.dark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF000000),
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Color(0xFF00838F)),
      ),
      cardTheme: const CardThemeData(
        color: Color(0xFF0A0A0A),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF00838F),
        foregroundColor: Colors.white,
      ),
    );
  }

  /// Tüm mevcut temaların listesi
  static List<ThemeData> get allThemes => [
    darkPurpleTheme,
    darkGreenTheme,
    darkBlueTheme,
    darkRedTheme,
    darkOrangeTheme,
    darkCyanTheme,
  ];

  /// Tema isimlerinin listesi (tema seçimi için)
  static List<String> get themeNames => [
    'Lavanta',
    'Zümrüt',
    'Anadolu',
    'Nar',
    'Safran',
    'Turkuaz',
  ];

  /// Index'e göre tema getir
  static ThemeData getThemeByIndex(int index) {
    if (index < 0 || index >= allThemes.length) {
      return darkPurpleTheme; // Varsayılan tema
    }
    return allThemes[index];
  }

  /// Tema adına göre tema getir
  static ThemeData getThemeByName(String name) {
    final index = themeNames.indexOf(name);
    return getThemeByIndex(index);
  }
}
