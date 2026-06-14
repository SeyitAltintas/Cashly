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

  
  static TextTheme _ibmTextTheme(TextTheme base) {
    return GoogleFonts.ibmPlexSansTextTheme(base);
  }

  // --- DARK THEME ---
  static ThemeData get darkTheme {
    final base = ThemeData(useMaterial3: true, brightness: Brightness.dark);
    final m2021 = Typography.material2021(platform: TargetPlatform.android);
    final interTypography = m2021.copyWith(
      black: _ibmTextTheme(m2021.black),
      white: _ibmTextTheme(m2021.white),
      dense: _ibmTextTheme(m2021.dense),
      tall: _ibmTextTheme(m2021.tall),
    );

    final interTextTheme = _ibmTextTheme(base.textTheme);
    final interPrimaryTextTheme = _ibmTextTheme(base.primaryTextTheme);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      /* fontFamily: _fontFamily, */
      typography: interTypography,
      textTheme: interTextTheme,
      primaryTextTheme: interPrimaryTextTheme,
      scaffoldBackgroundColor: const Color(0xFF121212),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      splashFactory: NoSplash.splashFactory,
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFFC8D96F),
        onPrimary: Colors.black,
        secondary: Color(0xFFE5F0B5),
        onSecondary: Colors.black,
        surface: Color(0xFF1E1E1E),
        onSurface: Colors.white,
        error: Color(0xFFCF6679),
        onError: Colors.black,
        surfaceContainerHighest: Color(0xFF2A2A2A),
        brightness: Brightness.dark,
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: Colors.white,
        selectionColor: Colors.white.withValues(alpha: 0.4),
        selectionHandleColor: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF121212),
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        toolbarHeight: kToolbarHeight,
        titleTextStyle: TextStyle(/* fontFamily: _fontFamily, */ fontSize: 20, fontWeight: FontWeight.w500, color: Colors.white),
        iconTheme: IconThemeData(color: PageThemeColors.lightGray),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF121212),
        elevation: 0,
        selectedItemColor: Color(0xFFC8D96F),
        unselectedItemColor: Color(0xFF757575),
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(/* fontFamily: _fontFamily, */ fontSize: 12),
        unselectedLabelStyle: TextStyle(/* fontFamily: _fontFamily, */ fontSize: 12),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(0xFF121212),
        surfaceTintColor: Colors.transparent,
        indicatorColor: const Color(0xFFC8D96F).withValues(alpha: 0.2),
        elevation: 0,
        height: 65,
        labelTextStyle: const WidgetStatePropertyAll(TextStyle(/* fontFamily: _fontFamily, */ fontSize: 12)),
      ),
      cardTheme: const CardThemeData(
        color: Color(0xFF1E1E1E),
        elevation: 8,
        shadowColor: Color(0x4D000000), // Koyu temaya uygun yumuşak gölge
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: Color(0xFF1A1A1A),
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(/* fontFamily: _fontFamily, */ fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
        contentTextStyle: TextStyle(/* fontFamily: _fontFamily, */ fontSize: 14, color: Colors.white70),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Color(0xFF121212),
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: Color(0xFF121212),
      ),
      listTileTheme: const ListTileThemeData(
        dense: false,
        titleTextStyle: TextStyle(/* fontFamily: _fontFamily, */ fontSize: 16, color: Colors.white),
        subtitleTextStyle: TextStyle(/* fontFamily: _fontFamily, */ fontSize: 13, color: Colors.white70),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFFC8D96F),
        foregroundColor: Colors.black,
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: const Color(0xFF1A1A1A),
        headerBackgroundColor: const Color(0xFF2A2A2A),
        headerForegroundColor: Colors.white,
        headerHeadlineStyle: const TextStyle(/* fontFamily: _fontFamily, */ fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
        headerHelpStyle: const TextStyle(/* fontFamily: _fontFamily, */ fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white70),
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
        weekdayStyle: TextStyle(/* fontFamily: _fontFamily, */ color: Colors.white.withValues(alpha: 0.6), fontWeight: FontWeight.w600, fontSize: 13),
        dayStyle: const TextStyle(/* fontFamily: _fontFamily, */ color: Colors.white, fontWeight: FontWeight.w500),
        dividerColor: Colors.white.withValues(alpha: 0.1),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        cancelButtonStyle: TextButton.styleFrom(
          foregroundColor: Colors.white60,
          textStyle: const TextStyle(/* fontFamily: _fontFamily, */ fontWeight: FontWeight.w500, fontSize: 15),
        ),
        confirmButtonStyle: TextButton.styleFrom(
          foregroundColor: Colors.black,
          textStyle: const TextStyle(/* fontFamily: _fontFamily, */ fontWeight: FontWeight.bold, fontSize: 15),
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
          splashFactory: NoSplash.splashFactory,
          foregroundColor: Colors.black,
          backgroundColor: const Color(0xFFC8D96F),
          textStyle: const TextStyle(/* fontFamily: _fontFamily, */ fontSize: 16, fontWeight: FontWeight.w600),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          minimumSize: const Size(64, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          splashFactory: NoSplash.splashFactory,
          foregroundColor: Colors.white70,
          textStyle: const TextStyle(/* fontFamily: _fontFamily, */ fontSize: 14, fontWeight: FontWeight.w500),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          minimumSize: const Size(48, 40),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          splashFactory: NoSplash.splashFactory,
          foregroundColor: Colors.black,
          textStyle: const TextStyle(/* fontFamily: _fontFamily, */ fontSize: 14, fontWeight: FontWeight.w500),
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
        labelStyle: const TextStyle(/* fontFamily: _fontFamily, */ color: Colors.white54),
        hintStyle: const TextStyle(/* fontFamily: _fontFamily, */ color: Colors.white30),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.white.withValues(alpha: 0.08),
        selectedColor: Colors.white.withValues(alpha: 0.2),
        labelStyle: const TextStyle(/* fontFamily: _fontFamily, */ fontSize: 13, color: Colors.white),
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
      black: _ibmTextTheme(m2021.black),
      white: _ibmTextTheme(m2021.white),
      dense: _ibmTextTheme(m2021.dense),
      tall: _ibmTextTheme(m2021.tall),
    );

    final interTextTheme = _ibmTextTheme(base.textTheme);
    final interPrimaryTextTheme = _ibmTextTheme(base.primaryTextTheme);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      /* fontFamily: _fontFamily, */
      typography: interTypography,
      textTheme: interTextTheme,
      primaryTextTheme: interPrimaryTextTheme,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      splashFactory: NoSplash.splashFactory,
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF1E1E2C), // Premium Corporate Indigo
        onPrimary: Colors.white,
        secondary: Color(0xFFC8D96F), // Brand Pistachio Green
        onSecondary: Color(0xFF1E1E2C), // Text on secondary should be dark
        surface: Color(0xFFFAFAFA), // Off-white background
        onSurface: Color(0xFF1E1E2C), // Text on background
        error: Color(0xFFB00020),
        onError: Colors.white,
        surfaceContainerHighest: Color(0xFFE0E0E0),
        brightness: Brightness.light,
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: Color(0xFF1E1E2C),
        selectionColor: const Color(0xFF1E1E2C).withValues(alpha: 0.3),
        selectionHandleColor: const Color(0xFF1E1E2C),
      ),
      scaffoldBackgroundColor: const Color(0xFFFAFAFA),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFFAFAFA),
        foregroundColor: Color(0xFF1E1E2C),
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        toolbarHeight: kToolbarHeight,
        titleTextStyle: TextStyle(/* fontFamily: _fontFamily, */ fontSize: 20, fontWeight: FontWeight.w500, color: Color(0xDD1E1E2C)),
        iconTheme: IconThemeData(color: Color(0xDD1E1E2C)),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        elevation: 8,
        selectedItemColor: Color(0xDD1E1E2C),
        unselectedItemColor: Color(0x611E1E2C),
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(/* fontFamily: _fontFamily, */ fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(/* fontFamily: _fontFamily, */ fontSize: 12),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        indicatorColor: Color(0x4DC8D96F),
        elevation: 4,
        height: 65,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(/* fontFamily: _fontFamily, */ fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xDD1E1E2C));
          }
          return const TextStyle(/* fontFamily: _fontFamily, */ fontSize: 12, color: Color(0x8A1E1E2C));
        }),
      ),
      cardTheme: const CardThemeData(
        color: Colors.white,
        elevation: 8,
        shadowColor: Color(0x1A000000), // Yumuşak geniş gölge efekti (Neo-morphism)
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(/* fontFamily: _fontFamily, */ fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xDD1E1E2C)),
        contentTextStyle: TextStyle(/* fontFamily: _fontFamily, */ fontSize: 14, color: Color(0x8A1E1E2C)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: Colors.white,
      ),
      listTileTheme: const ListTileThemeData(
        dense: false,
        titleTextStyle: TextStyle(/* fontFamily: _fontFamily, */ fontSize: 16, color: Color(0xDD1E1E2C)),
        subtitleTextStyle: TextStyle(/* fontFamily: _fontFamily, */ fontSize: 13, color: Color(0x8A1E1E2C)),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFFC8D96F),
        foregroundColor: Color(0xFF1E1E2C),
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: Colors.white,
        headerBackgroundColor: Colors.white,
        headerForegroundColor: Color(0xDD1E1E2C),
        headerHeadlineStyle: const TextStyle(/* fontFamily: _fontFamily, */ fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xDD1E1E2C)),
        headerHelpStyle: const TextStyle(/* fontFamily: _fontFamily, */ fontSize: 14, fontWeight: FontWeight.w500, color: Color(0x8A1E1E2C)),
        dayForegroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          if (states.contains(WidgetState.disabled)) return Color(0x421E1E2C);
          return Color(0xDD1E1E2C);
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
          return Color(0xDD1E1E2C);
        }),
        yearBackgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return PageThemeColors.darkGray;
          return Colors.transparent;
        }),
        yearOverlayColor: WidgetStateProperty.all(Color(0xFF1E1E2C).withValues(alpha: 0.05)),
        weekdayStyle: const TextStyle(/* fontFamily: _fontFamily, */ color: Color(0x8A1E1E2C), fontWeight: FontWeight.w600, fontSize: 13),
        dayStyle: const TextStyle(/* fontFamily: _fontFamily, */ color: Color(0xDD1E1E2C), fontWeight: FontWeight.w500),
        dividerColor: Color(0x1F1E1E2C),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        cancelButtonStyle: TextButton.styleFrom(
          foregroundColor: Color(0x8A1E1E2C),
          textStyle: const TextStyle(/* fontFamily: _fontFamily, */ fontWeight: FontWeight.w500, fontSize: 15),
        ),
        confirmButtonStyle: TextButton.styleFrom(
          foregroundColor: PageThemeColors.darkGray,
          textStyle: const TextStyle(/* fontFamily: _fontFamily, */ fontWeight: FontWeight.bold, fontSize: 15),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFF1E1E2C).withValues(alpha: 0.05),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: PageThemeColors.darkGray)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          splashFactory: NoSplash.splashFactory,
          foregroundColor: Color(0xFF1E1E2C),
          backgroundColor: const Color(0xFFC8D96F),
          textStyle: const TextStyle(/* fontFamily: _fontFamily, */ fontSize: 16, fontWeight: FontWeight.w600),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          minimumSize: const Size(64, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          splashFactory: NoSplash.splashFactory,
          foregroundColor: Color(0x8A1E1E2C),
          textStyle: const TextStyle(/* fontFamily: _fontFamily, */ fontSize: 14, fontWeight: FontWeight.w500),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          minimumSize: const Size(48, 40),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          splashFactory: NoSplash.splashFactory,
          foregroundColor: Color(0xDD1E1E2C),
          textStyle: const TextStyle(/* fontFamily: _fontFamily, */ fontSize: 14, fontWeight: FontWeight.w500),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          minimumSize: const Size(64, 44),
          side: BorderSide(color: Color(0xFF1E1E2C).withValues(alpha: 0.2)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Color(0xFF1E1E2C).withValues(alpha: 0.04),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: PageThemeColors.darkGray)),
        labelStyle: const TextStyle(/* fontFamily: _fontFamily, */ color: Color(0x8A1E1E2C)),
        hintStyle: const TextStyle(/* fontFamily: _fontFamily, */ color: Color(0x611E1E2C)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Color(0xFF1E1E2C).withValues(alpha: 0.06),
        selectedColor: PageThemeColors.darkGray.withValues(alpha: 0.15),
        labelStyle: const TextStyle(/* fontFamily: _fontFamily, */ fontSize: 13, color: Color(0xDD1E1E2C)),
        secondaryLabelStyle: const TextStyle(/* fontFamily: _fontFamily, */ fontSize: 13, color: PageThemeColors.darkGray),
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
      textTheme: _ibmTextTheme(noSplash.textTheme),
      primaryTextTheme: _ibmTextTheme(noSplash.primaryTextTheme),
    );
  }

  static ThemeData getThemeByName(String name) {
    if (name == 'Açık Tema') return _applyNoSplash(lightTheme);
    return _applyNoSplash(darkTheme);
  }
}
