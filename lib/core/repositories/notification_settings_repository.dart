import 'package:hive_flutter/hive_flutter.dart';
import '../domain/notification_types.dart';

/// Bildirim ayarlarını Hive'da saklayan repository
class NotificationSettingsRepository {
  static const String _boxName = 'notification_settings';
  static const String _settingsKey = 'settings';

  Box? _box;

  /// Box'ı başlat
  Future<void> init() async {
    if (_box == null || !_box!.isOpen) {
      _box = await Hive.openBox(_boxName);
    }
  }

  /// Mevcut ayarları getir
  NotificationSettings getSettings() {
    if (_box == null || !_box!.isOpen) {
      return NotificationSettings.defaults();
    }

    final data = _box!.get(_settingsKey);
    if (data == null) {
      return NotificationSettings.defaults();
    }

    return NotificationSettings.fromMap(Map<String, dynamic>.from(data));
  }

  /// Ayarları kaydet
  Future<void> saveSettings(NotificationSettings settings) async {
    await init();
    await _box!.put(_settingsKey, settings.toMap());
  }

  /// Tek bir ayarı güncelle
  Future<void> updateSetting(String key, dynamic value) async {
    await init();
    final current = getSettings();
    final map = current.toMap();
    map[key] = value;
    await _box!.put(_settingsKey, map);
  }

  /// Tekrarlayan işlem hatırlatıcı aktif mi
  bool isRecurringReminderEnabled() => getSettings().recurringReminderEnabled;

  /// Seri hatırlatıcı aktif mi
  bool isStreakReminderEnabled() => getSettings().streakReminderEnabled;

  /// Aylık özet aktif mi
  bool isMonthlySummaryEnabled() => getSettings().monthlySummaryEnabled;

  /// Seri hatırlatıcı saatini getir
  (int hour, int minute) getStreakReminderTime() {
    final settings = getSettings();
    return (settings.streakReminderHour, settings.streakReminderMinute);
  }

  /// Aylık özet saatini getir
  int getMonthlySummaryHour() {
    return getSettings().monthlySummaryHour;
  }

  /// Ayarları sıfırla
  Future<void> resetToDefaults() async {
    await saveSettings(NotificationSettings.defaults());
  }
}
