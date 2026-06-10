import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app_theme.dart';
import 'package:cashly/core/mixins/safe_notifier_mixin.dart';

class ThemeManager extends ChangeNotifier with SafeNotifierMixin {
  static const String _boxName = 'settings';
  static const String _keyMoneyAnimation = 'moneyAnimation';
  static const String _keyThemeMode = 'themeMode';

  bool _isMoneyAnimationEnabled = true;
  ThemeMode _themeMode = ThemeMode.system;
  late Box _box;

  ThemeManager() {
    _box = Hive.box(_boxName);
    _isMoneyAnimationEnabled = _box.get(_keyMoneyAnimation, defaultValue: true);
    
    final themeModeStr = _box.get(_keyThemeMode, defaultValue: 'system');
    _themeMode = _parseThemeMode(themeModeStr);
  }

  ThemeMode get themeMode => _themeMode;

  ThemeData get currentTheme => AppTheme.darkTheme; // Fallback or direct use, but main.dart will use lightTheme/darkTheme

  bool get isMoneyAnimationEnabled => _isMoneyAnimationEnabled;

  ThemeMode _parseThemeMode(String value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    await _box.put(_keyThemeMode, _themeModeToString(mode));
    notifyListeners();
  }

  Future<void> toggleMoneyAnimation(bool value) async {
    _isMoneyAnimationEnabled = value;
    await _box.put(_keyMoneyAnimation, value);
    notifyListeners();
  }
}
