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
    // Ek renkler
    Color(0xFF8BC34A), // Light Green
    Color(0xFFCDDC39), // Lime
    Color(0xFFFFEB3B), // Yellow
    Color(0xFFFF5722), // Deep Orange
    Color(0xFF795548), // Brown
    Color(0xFF607D8B), // Blue Grey
    Color(0xFFE040FB), // Purple Accent
    Color(0xFF00E676), // Green Accent
    Color(0xFFFF4081), // Pink Accent
    Color(0xFF536DFE), // Indigo Accent
  ];

  /// Index'e göre ikon rengi getir (döngüsel)
  static Color getIconColor(int index) {
    return iconColors[index % iconColors.length];
  }
}

/// Uygulama teması için merkezi sınıf
/// Tek tema: Varsayılan koyu tema
class AppTheme {
  AppTheme._();

  static const String _fontFamily = 'Inter';

  /// GoogleFonts ile Inter text theme oluştur
  static TextTheme _interTextTheme(TextTheme base) {
    return GoogleFonts.interTextTheme(base);
  }

  static ThemeData get defaultTheme {
    // 1. M3 dark tema bazını oluştur
    final base = ThemeData(useMaterial3: true, brightness: Brightness.dark);

    // 2. Typography seviyesinde Inter fontu zorla
    final m2021 = Typography.material2021(platform: TargetPlatform.android);
    final interTypography = m2021.copyWith(
      black: _interTextTheme(m2021.black),
      white: _interTextTheme(m2021.white),
      dense: _interTextTheme(m2021.dense),
      tall: _interTextTheme(m2021.tall),
    );

    // 3. textTheme ve primaryTextTheme'e de GoogleFonts ile uygula
    final interTextTheme = _interTextTheme(base.textTheme);
    final interPrimaryTextTheme = _interTextTheme(base.primaryTextTheme);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: _fontFamily,
      typography: interTypography,
      textTheme: interTextTheme,
      primaryTextTheme: interPrimaryTextTheme,
      scaffoldBackgroundColor: const Color(0xFF000000),
      colorScheme: const ColorScheme.dark(
        primary: PageThemeColors.darkGray,
        secondary: PageThemeColors.lightGray,
        surface: Color(0xFF121212),
        error: Color(0xFFCF6679),
        brightness: Brightness.dark,
      ),
      // TextField imleç ve seçim tutamakları için renkler
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: Colors.white,
        selectionColor: Colors.white.withValues(alpha: 0.4),
        selectionHandleColor: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF000000),
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        toolbarHeight: kToolbarHeight,
        titleTextStyle: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
        iconTheme: IconThemeData(color: PageThemeColors.lightGray),
      ),
      // M3 BottomNavigationBar — eski M2 boyutlarına yakın tut
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF000000),
        elevation: 0,
        selectedItemColor: Colors.white,
        unselectedItemColor: Color(0xFF757575),
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(fontFamily: _fontFamily, fontSize: 12),
        unselectedLabelStyle: TextStyle(fontFamily: _fontFamily, fontSize: 12),
      ),
      // M3 NavigationBar (yeni stil bottom nav)
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(0xFF000000),
        surfaceTintColor: Colors.transparent,
        indicatorColor: Colors.white.withValues(alpha: 0.1),
        elevation: 0,
        height: 65,
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(fontFamily: _fontFamily, fontSize: 12),
        ),
      ),
      cardTheme: const CardThemeData(
        color: Color(0xFF121212),
        elevation: 4,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      // Dialog — M3 surfaceTint kapatma
      dialogTheme: const DialogThemeData(
        backgroundColor: Color(0xFF1A1A1A),
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        contentTextStyle: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 14,
          color: Colors.white70,
        ),
      ),
      // BottomSheet — M3 surfaceTint kapatma
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Color(0xFF121212),
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: Color(0xFF121212),
      ),
      // ListTile — M3 yoğunluk ayarı
      listTileTheme: const ListTileThemeData(
        dense: false,
        titleTextStyle: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 16,
          color: Colors.white,
        ),
        subtitleTextStyle: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 13,
          color: Colors.white70,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: PageThemeColors.darkGray,
        foregroundColor: Colors.white,
      ),
      // Tarih seçici teması - Dark mode uyumlu
      datePickerTheme: DatePickerThemeData(
        backgroundColor: const Color(0xFF1A1A1A),
        headerBackgroundColor: const Color(0xFF2A2A2A),
        headerForegroundColor: Colors.white,
        headerHeadlineStyle: const TextStyle(
          fontFamily: _fontFamily,
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        headerHelpStyle: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.white.withValues(alpha: 0.7),
        ),
        dayForegroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.black;
          }
          if (states.contains(WidgetState.disabled)) {
            return Colors.white.withValues(alpha: 0.3);
          }
          return Colors.white.withValues(alpha: 0.9);
        }),
        dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.white;
          }
          return Colors.transparent;
        }),
        todayForegroundColor: WidgetStateProperty.all(Colors.white),
        todayBackgroundColor: WidgetStateProperty.all(
          Colors.white.withValues(alpha: 0.15),
        ),
        todayBorder: const BorderSide(color: Colors.white, width: 1.5),
        yearForegroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.black;
          }
          return Colors.white.withValues(alpha: 0.8);
        }),
        yearBackgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.white;
          }
          return Colors.transparent;
        }),
        yearOverlayColor: WidgetStateProperty.all(
          Colors.white.withValues(alpha: 0.1),
        ),
        weekdayStyle: TextStyle(
          fontFamily: _fontFamily,
          color: Colors.white.withValues(alpha: 0.6),
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
        dayStyle: const TextStyle(
          fontFamily: _fontFamily,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
        dividerColor: Colors.white.withValues(alpha: 0.1),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        cancelButtonStyle: TextButton.styleFrom(
          foregroundColor: Colors.white60,
          textStyle: const TextStyle(
            fontFamily: _fontFamily,
            fontWeight: FontWeight.w500,
            fontSize: 15,
          ),
        ),
        confirmButtonStyle: TextButton.styleFrom(
          foregroundColor: Colors.white,
          textStyle: const TextStyle(
            fontFamily: _fontFamily,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.1),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.white),
          ),
        ),
      ),
      // M3 Button tema ayarları — basıklık sorununu önle
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: PageThemeColors.darkGray,
          textStyle: const TextStyle(
            fontFamily: _fontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          minimumSize: const Size(64, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: Colors.white70,
          textStyle: const TextStyle(
            fontFamily: _fontFamily,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          minimumSize: const Size(48, 40),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          textStyle: const TextStyle(
            fontFamily: _fontFamily,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          minimumSize: const Size(64, 44),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      // Input alanları — M3 varsayılan yoğunluğu normalize et
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.06),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white54),
        ),
        labelStyle: const TextStyle(
          fontFamily: _fontFamily,
          color: Colors.white54,
        ),
        hintStyle: const TextStyle(
          fontFamily: _fontFamily,
          color: Colors.white30,
        ),
      ),
      // Chip tema — M3 padding düzeltmesi
      chipTheme: ChipThemeData(
        backgroundColor: Colors.white.withValues(alpha: 0.08),
        selectedColor: Colors.white.withValues(alpha: 0.2),
        labelStyle: const TextStyle(
          fontFamily: _fontFamily,
          fontSize: 13,
          color: Colors.white,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
    final noSplash = theme.copyWith(
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
    // copyWith sonrası font korunması
    return noSplash.copyWith(
      textTheme: _interTextTheme(noSplash.textTheme),
      primaryTextTheme: _interTextTheme(noSplash.primaryTextTheme),
    );
  }

  /// Tema adına göre tema getir (her zaman varsayılan döner)
  static ThemeData getThemeByName(String name) {
    return getThemeByIndex(0);
  }
}
