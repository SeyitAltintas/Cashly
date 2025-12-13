import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app_theme.dart';

class ThemeManager extends ChangeNotifier {
  static const String _boxName = 'settings';
  static const String _keyThemeIndex = 'themeIndex';
  static const String _keyMoneyAnimation = 'moneyAnimation';

  int _themeIndex = 0; // Varsayılan tema: Varsayılan (index 0)
  bool _isMoneyAnimationEnabled = true;
  late Box _box;

  ThemeManager() {
    _init();
  }

  Future<void> _init() async {
    _box = await Hive.openBox(_boxName);
    _themeIndex = _box.get(
      _keyThemeIndex,
      defaultValue: 0,
    ); // Varsayılan tema: Varsayılan
    _isMoneyAnimationEnabled = _box.get(_keyMoneyAnimation, defaultValue: true);
    notifyListeners();
  }

  ThemeData get currentTheme => AppTheme.getThemeByIndex(_themeIndex);
  int get themeIndex => _themeIndex;
  bool get isMoneyAnimationEnabled => _isMoneyAnimationEnabled;

  /// Varsayılan tema mı kontrol et
  bool get isDefaultTheme => _themeIndex == 0;

  Future<void> setTheme(int index) async {
    if (index < 0 || index >= AppTheme.allThemes.length) return;

    _themeIndex = index;
    await _box.put(_keyThemeIndex, index);
    notifyListeners();
  }

  Future<void> toggleMoneyAnimation(bool value) async {
    _isMoneyAnimationEnabled = value;
    await _box.put(_keyMoneyAnimation, value);
    notifyListeners();
  }
}
