import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app_theme.dart';

class ThemeManager extends ChangeNotifier {
  static const String _boxName = 'settings';
  static const String _keyThemeIndex = 'themeIndex';

  int _themeIndex = 0;
  late Box _box;

  ThemeManager() {
    _init();
  }

  Future<void> _init() async {
    _box = await Hive.openBox(_boxName);
    _themeIndex = _box.get(_keyThemeIndex, defaultValue: 0);
    notifyListeners();
  }

  ThemeData get currentTheme => AppTheme.getThemeByIndex(_themeIndex);
  int get themeIndex => _themeIndex;

  Future<void> setTheme(int index) async {
    if (index < 0 || index >= AppTheme.allThemes.length) return;

    _themeIndex = index;
    await _box.put(_keyThemeIndex, index);
    notifyListeners();
  }
}
