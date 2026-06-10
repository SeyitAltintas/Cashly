import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PageThemeColors {
  // Common
  static const Color darkGray = Color(0xFF2D2D2D); 
  static const Color lightGray = Color(0xFFE0E0E0);
  
  // Specific
  static const Color expensePrimary = darkGray;
  static const Color expenseSecondary = lightGray;
  static const Color incomePrimary = Color(0xFF4CAF50);
  static const Color incomeSecondary = Color(0xFF81C784);
  static const Color assetsPrimary = Color(0xFF1A237E);
  static const Color assetsSecondary = Color(0xFF3949AB);
  static const Color defaultPrimary = darkGray;
  static const Color defaultSecondary = lightGray;

  static const List<Color> iconColors = [
    Color(0xFFE91E63), Color(0xFF9C27B0), Color(0xFF673AB7), Color(0xFF3F51B5),
    Color(0xFF2196F3), Color(0xFF00BCD4), Color(0xFF009688), Color(0xFF4CAF50),
    Color(0xFFFF9800), Color(0xFFF44336), Color(0xFF8BC34A), Color(0xFFCDDC39),
    Color(0xFFFFEB3B), Color(0xFFFF5722), Color(0xFF795548), Color(0xFF607D8B),
    Color(0xFFE040FB), Color(0xFF00E676), Color(0xFFFF4081), Color(0xFF536DFE),
  ];

  static Color getIconColor(int index) {
    return iconColors[index % iconColors.length];
  }
}

class AppTheme {
  AppTheme._();

  static const String _fontFamily = 'Inter';

  static TextTheme _interTextTheme(TextTheme base) {
    return GoogleFonts.interTextTheme(base);
  }

  // --- DARK THEME ---
  static ThemeData get darkTheme {
    final base = ThemeData(useMaterial3: true, brightness: Brightness.dark);
    final m2021 = Typography.material2021(platform: TargetPlatform.android);
    final interTypography = m2021.copyWith(
      black: _interTextTheme(m2021.black),
      white: _interTextTheme(m2021.white),
      dense: _interTextTheme(m2021.dense),
      tall: _interTextTheme(m2021.tall),
    );

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
        secondary: const Color(0xFF616161),
        surface: Color(0xFF121212),
        error: Color(0xFFCF6679),
        surfaceContainerHighest: Color(0xFF2A2A2A),
        brightness: Brightness.dark,
      ),
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
        titleTextStyle: TextStyle(fontFamily: _fontFamily, fontSize: 20, fontWeight: FontWeight.w500, color: Colors.white),
        iconTheme: IconThemeData(color: PageThemeColors.lightGray),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF000000),
        elevation: 0,
        selectedItemColor: Colors.white,
        unselectedItemColor: Color(0xFF757575),
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(fontFamily: _fontFamily, fontSize: 12),
        unselectedLabelStyle: TextStyle(fontFamily: _fontFamily, fontSize: 12),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(0xFF000000),
        surfaceTintColor: Colors.transparent,
        indicatorColor: Colors.white.withValues(alpha: 0.1),
        elevation: 0,
        height: 65,
        labelTextStyle: const WidgetStatePropertyAll(TextStyle(fontFamily: _fontFamily, fontSize: 12)),
      ),
      cardTheme: const CardThemeData(
        color: Color(0xFF121212),
        elevation: 4,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: Color(0xFF1A1A1A),
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(fontFamily: _fontFamily, fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
        contentTextStyle: TextStyle(fontFamily: _fontFamily, fontSize: 14, color: Colors.white70),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Color(0xFF121212),
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: Color(0xFF121212),
      ),
      listTileTheme: const ListTileThemeData(
        dense: false,
        titleTextStyle: TextStyle(fontFamily: _fontFamily, fontSize: 16, color: Colors.white),
        subtitleTextStyle: TextStyle(fontFamily: _fontFamily, fontSize: 13, color: Colors.white70),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: PageThemeColors.darkGray,
        foregroundColor: Colors.white,
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: const Color(0xFF1A1A1A),
        headerBackgroundColor: const Color(0xFF2A2A2A),
        headerForegroundColor: Colors.white,
        headerHeadlineStyle: const TextStyle(fontFamily: _fontFamily, fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
        headerHelpStyle: const TextStyle(fontFamily: _fontFamily, fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white70),
        dayForegroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.black;
          if (states.contains(WidgetState.disabled)) return Colors.white30;
          return Colors.white.withValues(alpha: 0.9);
        }),
        dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          return Colors.transparent;
        }),
        todayForegroundColor: WidgetStateProperty.all(Colors.white),
        todayBackgroundColor: WidgetStateProperty.all(Colors.white.withValues(alpha: 0.15)),
        todayBorder: const BorderSide(color: Colors.white, width: 1.5),
        yearForegroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.black;
          return Colors.white.withValues(alpha: 0.8);
        }),
        yearBackgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          return Colors.transparent;
        }),
        yearOverlayColor: WidgetStateProperty.all(Colors.white.withValues(alpha: 0.1)),
        weekdayStyle: TextStyle(fontFamily: _fontFamily, color: Colors.white.withValues(alpha: 0.6), fontWeight: FontWeight.w600, fontSize: 13),
        dayStyle: const TextStyle(fontFamily: _fontFamily, color: Colors.white, fontWeight: FontWeight.w500),
        dividerColor: Colors.white.withValues(alpha: 0.1),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        cancelButtonStyle: TextButton.styleFrom(
          foregroundColor: Colors.white60,
          textStyle: const TextStyle(fontFamily: _fontFamily, fontWeight: FontWeight.w500, fontSize: 15),
        ),
        confirmButtonStyle: TextButton.styleFrom(
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontFamily: _fontFamily, fontWeight: FontWeight.bold, fontSize: 15),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.1),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: PageThemeColors.darkGray,
          textStyle: const TextStyle(fontFamily: _fontFamily, fontSize: 16, fontWeight: FontWeight.w600),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          minimumSize: const Size(64, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: Colors.white70,
          textStyle: const TextStyle(fontFamily: _fontFamily, fontSize: 14, fontWeight: FontWeight.w500),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          minimumSize: const Size(48, 40),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontFamily: _fontFamily, fontSize: 14, fontWeight: FontWeight.w500),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          minimumSize: const Size(64, 44),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.06),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white54)),
        labelStyle: const TextStyle(fontFamily: _fontFamily, color: Colors.white54),
        hintStyle: const TextStyle(fontFamily: _fontFamily, color: Colors.white30),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.white.withValues(alpha: 0.08),
        selectedColor: Colors.white.withValues(alpha: 0.2),
        labelStyle: const TextStyle(fontFamily: _fontFamily, fontSize: 13, color: Colors.white),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  // --- LIGHT THEME ---
  static ThemeData get lightTheme {
    final base = ThemeData(useMaterial3: true, brightness: Brightness.light);
    final m2021 = Typography.material2021(platform: TargetPlatform.android);
    final interTypography = m2021.copyWith(
      black: _interTextTheme(m2021.black),
      white: _interTextTheme(m2021.white),
      dense: _interTextTheme(m2021.dense),
      tall: _interTextTheme(m2021.tall),
    );

    final interTextTheme = _interTextTheme(base.textTheme);
    final interPrimaryTextTheme = _interTextTheme(base.primaryTextTheme);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: _fontFamily,
      typography: interTypography,
      textTheme: interTextTheme,
      primaryTextTheme: interPrimaryTextTheme,
      scaffoldBackgroundColor: const Color(0xFFF5F5F5),
      colorScheme: const ColorScheme.light(
        primary: PageThemeColors.darkGray,
        secondary: const Color(0xFF616161),
        surface: Colors.white,
        error: Color(0xFFB00020),
        surfaceContainerHighest: Color(0xFFE0E0E0),
        brightness: Brightness.light,
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: Colors.black,
        selectionColor: Colors.black.withValues(alpha: 0.2),
        selectionHandleColor: Colors.black,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFF5F5F5),
        foregroundColor: Colors.black87,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        toolbarHeight: kToolbarHeight,
        titleTextStyle: TextStyle(fontFamily: _fontFamily, fontSize: 20, fontWeight: FontWeight.w500, color: Colors.black87),
        iconTheme: IconThemeData(color: Colors.black87),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        elevation: 8,
        selectedItemColor: Colors.black87,
        unselectedItemColor: Colors.black38,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(fontFamily: _fontFamily, fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontFamily: _fontFamily, fontSize: 12),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        indicatorColor: Colors.black.withValues(alpha: 0.08),
        elevation: 4,
        height: 65,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(fontFamily: _fontFamily, fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87);
          }
          return const TextStyle(fontFamily: _fontFamily, fontSize: 12, color: Colors.black54);
        }),
      ),
      cardTheme: const CardThemeData(
        color: Colors.white,
        elevation: 2,
        shadowColor: Colors.black12,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(fontFamily: _fontFamily, fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black87),
        contentTextStyle: TextStyle(fontFamily: _fontFamily, fontSize: 14, color: Colors.black54),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: Colors.white,
      ),
      listTileTheme: const ListTileThemeData(
        dense: false,
        titleTextStyle: TextStyle(fontFamily: _fontFamily, fontSize: 16, color: Colors.black87),
        subtitleTextStyle: TextStyle(fontFamily: _fontFamily, fontSize: 13, color: Colors.black54),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: PageThemeColors.darkGray,
        foregroundColor: Colors.white,
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: Colors.white,
        headerBackgroundColor: const Color(0xFFF0F0F0),
        headerForegroundColor: Colors.black87,
        headerHeadlineStyle: const TextStyle(fontFamily: _fontFamily, fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
        headerHelpStyle: const TextStyle(fontFamily: _fontFamily, fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black54),
        dayForegroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          if (states.contains(WidgetState.disabled)) return Colors.black26;
          return Colors.black87;
        }),
        dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return PageThemeColors.darkGray;
          return Colors.transparent;
        }),
        todayForegroundColor: WidgetStateProperty.all(PageThemeColors.darkGray),
        todayBackgroundColor: WidgetStateProperty.all(PageThemeColors.darkGray.withValues(alpha: 0.1)),
        todayBorder: const BorderSide(color: PageThemeColors.darkGray, width: 1.5),
        yearForegroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          return Colors.black87;
        }),
        yearBackgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return PageThemeColors.darkGray;
          return Colors.transparent;
        }),
        yearOverlayColor: WidgetStateProperty.all(Colors.black.withValues(alpha: 0.05)),
        weekdayStyle: const TextStyle(fontFamily: _fontFamily, color: Colors.black54, fontWeight: FontWeight.w600, fontSize: 13),
        dayStyle: const TextStyle(fontFamily: _fontFamily, color: Colors.black87, fontWeight: FontWeight.w500),
        dividerColor: Colors.black12,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        cancelButtonStyle: TextButton.styleFrom(
          foregroundColor: Colors.black54,
          textStyle: const TextStyle(fontFamily: _fontFamily, fontWeight: FontWeight.w500, fontSize: 15),
        ),
        confirmButtonStyle: TextButton.styleFrom(
          foregroundColor: PageThemeColors.darkGray,
          textStyle: const TextStyle(fontFamily: _fontFamily, fontWeight: FontWeight.bold, fontSize: 15),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.black.withValues(alpha: 0.05),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: PageThemeColors.darkGray)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: PageThemeColors.darkGray,
          textStyle: const TextStyle(fontFamily: _fontFamily, fontSize: 16, fontWeight: FontWeight.w600),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          minimumSize: const Size(64, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: Colors.black54,
          textStyle: const TextStyle(fontFamily: _fontFamily, fontSize: 14, fontWeight: FontWeight.w500),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          minimumSize: const Size(48, 40),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.black87,
          textStyle: const TextStyle(fontFamily: _fontFamily, fontSize: 14, fontWeight: FontWeight.w500),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          minimumSize: const Size(64, 44),
          side: BorderSide(color: Colors.black.withValues(alpha: 0.2)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.black.withValues(alpha: 0.04),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: PageThemeColors.darkGray)),
        labelStyle: const TextStyle(fontFamily: _fontFamily, color: Colors.black54),
        hintStyle: const TextStyle(fontFamily: _fontFamily, color: Colors.black38),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.black.withValues(alpha: 0.06),
        selectedColor: PageThemeColors.darkGray.withValues(alpha: 0.15),
        labelStyle: const TextStyle(fontFamily: _fontFamily, fontSize: 13, color: Colors.black87),
        secondaryLabelStyle: const TextStyle(fontFamily: _fontFamily, fontSize: 13, color: PageThemeColors.darkGray),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  // --- COMPATIBILITY & HELPER METHODS ---
  static ThemeData get defaultTheme => _applyNoSplash(darkTheme);

  static List<ThemeData> get allThemes => [_applyNoSplash(darkTheme), _applyNoSplash(lightTheme)];
  static List<String> get themeNames => ['Koyu Tema', 'Açık Tema'];

  static ThemeData getThemeByIndex(int index) {
    // Legacy support for theme index
    return _applyNoSplash(darkTheme);
  }

  static bool isDefaultTheme(int index) => true;

  static ThemeData _applyNoSplash(ThemeData theme) {
    final noSplash = theme.copyWith(
      splashFactory: NoSplash.splashFactory,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(splashFactory: NoSplash.splashFactory).merge(theme.elevatedButtonTheme.style),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(splashFactory: NoSplash.splashFactory).merge(theme.textButtonTheme.style),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(splashFactory: NoSplash.splashFactory).merge(theme.outlinedButtonTheme.style),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(splashFactory: NoSplash.splashFactory).merge(theme.iconButtonTheme.style),
      ),
    );
    return noSplash.copyWith(
      textTheme: _interTextTheme(noSplash.textTheme),
      primaryTextTheme: _interTextTheme(noSplash.primaryTextTheme),
    );
  }

  static ThemeData getThemeByName(String name) {
    if (name == 'Açık Tema') return _applyNoSplash(lightTheme);
    return _applyNoSplash(darkTheme);
  }
}
