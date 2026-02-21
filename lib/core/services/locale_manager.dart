import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Dil yöneticisi — Kullanıcının seçtiği dili Hive'da saklar ve uygular.
class LocaleManager extends ChangeNotifier {
  static const String _boxName = 'settings';
  static const String _keyLocale = 'app_locale';

  static const Locale defaultLocale = Locale('tr', 'TR');

  static const List<Locale> supportedLocales = [
    Locale('tr', 'TR'),
    Locale('en', 'US'),
  ];

  Locale _locale = defaultLocale;
  late Box _box;

  LocaleManager() {
    _box = Hive.box(_boxName);
    final savedLang = _box.get(_keyLocale, defaultValue: 'tr');
    _locale = _localeFromCode(savedLang);
  }

  Locale get locale => _locale;

  String get languageCode => _locale.languageCode;

  /// Display name for current locale
  String get displayName => getDisplayName(_locale);

  /// Dili değiştirir ve Hive'a kaydeder
  Future<void> setLocale(Locale newLocale) async {
    if (_locale == newLocale) return;
    _locale = newLocale;
    await _box.put(_keyLocale, newLocale.languageCode);
    notifyListeners();
  }

  /// Dil koduna göre Locale döndürür
  Locale _localeFromCode(String code) {
    switch (code) {
      case 'en':
        return const Locale('en', 'US');
      case 'tr':
      default:
        return const Locale('tr', 'TR');
    }
  }

  /// Locale için görünen ad
  static String getDisplayName(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'English';
      case 'tr':
      default:
        return 'Türkçe';
    }
  }

  /// Locale için bayrak emojisi
  static String getFlagEmoji(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return '🇺🇸';
      case 'tr':
      default:
        return '🇹🇷';
    }
  }
}
