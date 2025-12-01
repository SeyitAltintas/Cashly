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
        primary: Color(0xFF9D00FF), // Neon Violet
        secondary: Color(0xFFBB86FC), // Light Violet
        surface: Color(0xFF121212), // Dark Surface
        error: Color(0xFFCF6679),
        brightness: Brightness.dark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF000000),
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Color(0xFF9D00FF)),
      ),
      cardTheme: const CardThemeData(
        color: Color(0xFF121212),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF9D00FF),
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
        primary: Color(0xFF00C853), // Neon Green
        secondary: Color(0xFF69F0AE), // Light Green
        surface: Color(0xFF121212), // Dark Surface
        error: Color(0xFFCF6679),
        brightness: Brightness.dark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF000000),
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Color(0xFF00C853)),
      ),
      cardTheme: const CardThemeData(
        color: Color(0xFF121212),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF00C853),
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
        primary: Color(0xFF00B0FF), // Neon Blue
        secondary: Color(0xFF82B1FF), // Light Blue
        surface: Color(0xFF121212), // Dark Surface
        error: Color(0xFFCF6679),
        brightness: Brightness.dark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF000000),
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Color(0xFF00B0FF)),
      ),
      cardTheme: const CardThemeData(
        color: Color(0xFF121212),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF00B0FF),
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
        primary: Color(0xFFFF1744), // Neon Red
        secondary: Color(0xFFFF5252), // Light Red
        surface: Color(0xFF121212), // Dark Surface
        error: Color(0xFFCF6679),
        brightness: Brightness.dark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF000000),
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Color(0xFFFF1744)),
      ),
      cardTheme: const CardThemeData(
        color: Color(0xFF121212),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFFFF1744),
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
        primary: Color(0xFFFF6D00), // Neon Orange
        secondary: Color(0xFFFF9E40), // Light Orange
        surface: Color(0xFF121212), // Dark Surface
        error: Color(0xFFCF6679),
        brightness: Brightness.dark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF000000),
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Color(0xFFFF6D00)),
      ),
      cardTheme: const CardThemeData(
        color: Color(0xFF121212),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFFFF6D00),
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
        primary: Color(0xFF00E5FF), // Neon Cyan
        secondary: Color(0xFF84FFFF), // Light Cyan
        surface: Color(0xFF121212), // Dark Surface
        error: Color(0xFFCF6679),
        brightness: Brightness.dark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF000000),
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Color(0xFF00E5FF)),
      ),
      cardTheme: const CardThemeData(
        color: Color(0xFF121212),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF00E5FF),
        foregroundColor: Colors.black,
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
    'Koyu Mor',
    'Koyu Yeşil',
    'Koyu Mavi',
    'Koyu Kırmızı',
    'Koyu Turuncu',
    'Koyu Camgöbeği',
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
