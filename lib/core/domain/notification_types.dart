/// Bildirim tipleri ve modelleri
/// Cashly uygulaması için yerel bildirim tanımlamaları

/// Bildirim türlerini tanımlayan enum
/// Sadece zamanlanabilir bildirimler (uygulama kapalıyken de çalışır)
enum NotificationType {
  /// Tekrarlayan işlem hatırlatıcısı (1 gün önce)
  recurringReminder,

  /// Günlük seri hatırlatıcısı
  streakReminder,

  /// Aylık finansal özet (ayın son günü)
  monthlySummary,
}

/// Bildirim ID'leri için sabitler
/// Her bildirim tipi için benzersiz ID aralıkları
class NotificationIds {
  NotificationIds._();

  /// Seri hatırlatıcı ID
  static const int streakReminder = 1000;

  /// Aylık özet ID
  static const int monthlySummary = 1001;

  /// Tekrarlayan işlem hatırlatıcıları için başlangıç ID
  static const int recurringReminderBase = 4000;
}

/// Bildirim kanalları (Android için)
class NotificationChannels {
  NotificationChannels._();

  static const String remindersId = 'reminders';
  static const String remindersName = 'Hatırlatıcılar';
  static const String remindersDesc =
      'Seri ve tekrarlayan işlem hatırlatıcıları';

  static const String summaryId = 'summary';
  static const String summaryName = 'Özetler';
  static const String summaryDesc = 'Aylık finansal özetler';
}

/// Bildirim ayarları modeli
class NotificationSettings {
  /// Tekrarlayan işlem hatırlatıcı aktif mi
  final bool recurringReminderEnabled;

  /// Seri hatırlatıcı aktif mi
  final bool streakReminderEnabled;

  /// Aylık özet aktif mi
  final bool monthlySummaryEnabled;

  /// Seri hatırlatıcı saati (saat)
  final int streakReminderHour;

  /// Seri hatırlatıcı saati (dakika)
  final int streakReminderMinute;

  /// Aylık özet saati (saat)
  final int monthlySummaryHour;

  /// Aylık özet saati (dakika)
  final int monthlySummaryMinute;

  const NotificationSettings({
    this.recurringReminderEnabled = true,
    this.streakReminderEnabled = true,
    this.monthlySummaryEnabled = true,
    this.streakReminderHour = 20,
    this.streakReminderMinute = 0,
    this.monthlySummaryHour = 10,
    this.monthlySummaryMinute = 0,
  });

  /// Varsayılan ayarlar
  factory NotificationSettings.defaults() => const NotificationSettings();

  /// Map'ten oluştur
  factory NotificationSettings.fromMap(Map<String, dynamic> map) {
    return NotificationSettings(
      recurringReminderEnabled: map['recurringReminderEnabled'] ?? true,
      streakReminderEnabled: map['streakReminderEnabled'] ?? true,
      monthlySummaryEnabled:
          map['monthlySummaryEnabled'] ??
          map['weeklySummaryEnabled'] ??
          true, // Geriye uyumluluk
      streakReminderHour: map['streakReminderHour'] ?? 20,
      streakReminderMinute: map['streakReminderMinute'] ?? 0,
      monthlySummaryHour:
          map['monthlySummaryHour'] ??
          map['weeklySummaryHour'] ??
          10, // Geriye uyumluluk
      monthlySummaryMinute: map['monthlySummaryMinute'] ?? 0,
    );
  }

  /// Map'e dönüştür
  Map<String, dynamic> toMap() {
    return {
      'recurringReminderEnabled': recurringReminderEnabled,
      'streakReminderEnabled': streakReminderEnabled,
      'monthlySummaryEnabled': monthlySummaryEnabled,
      'streakReminderHour': streakReminderHour,
      'streakReminderMinute': streakReminderMinute,
      'monthlySummaryHour': monthlySummaryHour,
      'monthlySummaryMinute': monthlySummaryMinute,
    };
  }

  /// Ayarları kopyala ve güncelle
  NotificationSettings copyWith({
    bool? recurringReminderEnabled,
    bool? streakReminderEnabled,
    bool? monthlySummaryEnabled,
    int? streakReminderHour,
    int? streakReminderMinute,
    int? monthlySummaryHour,
    int? monthlySummaryMinute,
  }) {
    return NotificationSettings(
      recurringReminderEnabled:
          recurringReminderEnabled ?? this.recurringReminderEnabled,
      streakReminderEnabled:
          streakReminderEnabled ?? this.streakReminderEnabled,
      monthlySummaryEnabled:
          monthlySummaryEnabled ?? this.monthlySummaryEnabled,
      streakReminderHour: streakReminderHour ?? this.streakReminderHour,
      streakReminderMinute: streakReminderMinute ?? this.streakReminderMinute,
      monthlySummaryHour: monthlySummaryHour ?? this.monthlySummaryHour,
      monthlySummaryMinute: monthlySummaryMinute ?? this.monthlySummaryMinute,
    );
  }
}
