import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app_theme.dart';

/// Tema yöneticisi - Artık sadece varsayılan tema destekleniyor
class ThemeManager extends ChangeNotifier {
  static const String _boxName = 'settings';
  static const String _keyMoneyAnimation = 'moneyAnimation';

  bool _isMoneyAnimationEnabled = true;
  late Box _box;

  ThemeManager() {
    _init();
  }

  Future<void> _init() async {
    _box = await Hive.openBox(_boxName);
    _isMoneyAnimationEnabled = _box.get(_keyMoneyAnimation, defaultValue: true);
    notifyListeners();
  }

  /// Mevcut tema (her zaman varsayılan tema)
  ThemeData get currentTheme => AppTheme.getThemeByIndex(0);

  /// Tema index'i (artık her zaman 0)
  int get themeIndex => 0;

  /// Para animasyonu aktif mi?
  bool get isMoneyAnimationEnabled => _isMoneyAnimationEnabled;

  /// Varsayılan tema mı kontrol et (artık her zaman true)
  bool get isDefaultTheme => true;

  /// Para animasyonunu aç/kapat
  Future<void> toggleMoneyAnimation(bool value) async {
    _isMoneyAnimationEnabled = value;
    await _box.put(_keyMoneyAnimation, value);
    notifyListeners();
  }
}
