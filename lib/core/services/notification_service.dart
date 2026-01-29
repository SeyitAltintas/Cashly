import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import '../domain/notification_types.dart';
import '../domain/notification_exception.dart';
import '../repositories/notification_settings_repository.dart';
import '../di/injection_container.dart';
import '../utils/notification_logger.dart';

/// Ana bildirim servisi
/// Platform konfigürasyonu, izin yönetimi ve bildirim gönderme işlemlerini yönetir
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  /// Uygulama ön planda mı kontrolü için
  bool _isAppInForeground = true;

  /// Uygulama lifecycle durumunu güncelle
  void setAppInForeground(bool inForeground) {
    _isAppInForeground = inForeground;
  }

  /// Timezone'un initialize edilip edilmediğini kontrol et
  bool _timezoneInitialized = false;

  /// Timezone'u güvenli şekilde initialize et
  void _ensureTimezoneInitialized() {
    if (!_timezoneInitialized) {
      tz_data.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('Europe/Istanbul'));
      _timezoneInitialized = true;
    }
  }

  /// Servisi başlat
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Timezone verilerini yükle
      _ensureTimezoneInitialized();

      // Android ayarları
      const androidSettings = AndroidInitializationSettings(
        '@mipmap/launcher_icon',
      );

      // iOS ayarları
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      // Android bildirim kanallarını oluştur
      await _createNotificationChannels();

      _isInitialized = true;
      notificationLogger.info('NotificationService initialized successfully');
    } catch (e, stackTrace) {
      notificationLogger.error(
        'Failed to initialize NotificationService',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Bildirim kanallarını oluştur (Android)
  Future<void> _createNotificationChannels() async {
    if (!Platform.isAndroid) return;

    final androidPlugin = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidPlugin == null) return;

    // Hatırlatıcılar kanalı (özel ses ile)
    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        NotificationChannels.remindersId,
        NotificationChannels.remindersName,
        description: NotificationChannels.remindersDesc,
        importance: Importance.defaultImportance,
        sound: RawResourceAndroidNotificationSound(
          NotificationChannels.reminderSound,
        ),
        playSound: true,
      ),
    );

    // Özetler kanalı (başarı sesi ile)
    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        NotificationChannels.summaryId,
        NotificationChannels.summaryName,
        description: NotificationChannels.summaryDesc,
        importance: Importance.low,
        sound: RawResourceAndroidNotificationSound(
          NotificationChannels.successSound,
        ),
        playSound: true,
      ),
    );

    // Uyarılar kanalı (uyarı sesi ile)
    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        NotificationChannels.warningsId,
        NotificationChannels.warningsName,
        description: NotificationChannels.warningsDesc,
        importance: Importance.high,
        sound: RawResourceAndroidNotificationSound(
          NotificationChannels.warningSound,
        ),
        playSound: true,
      ),
    );
  }

  /// Navigasyon callback'i dışarıdan set edilebilir
  /// Main.dart'ta set edilir, böylece Navigator context'ine erişim sağlanır
  static Function(String payload)? onNotificationNavigate;

  /// Bildirime tıklandığında
  void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    debugPrint('Notification tapped: $payload');

    if (payload == null || payload.isEmpty) return;

    // Navigasyon callback'i varsa çağır
    if (onNotificationNavigate != null) {
      onNotificationNavigate!(payload);
    }
  }

  /// İzin durumunu kontrol et
  Future<bool> hasPermission() async {
    if (Platform.isAndroid) {
      final androidPlugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (androidPlugin != null) {
        return await androidPlugin.areNotificationsEnabled() ?? false;
      }
    } else if (Platform.isIOS) {
      final iosPlugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      if (iosPlugin != null) {
        final settings = await iosPlugin.checkPermissions();
        return settings?.isEnabled ?? false;
      }
    }
    return false;
  }

  /// İzin iste
  Future<bool> requestPermission() async {
    if (Platform.isAndroid) {
      final androidPlugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (androidPlugin != null) {
        final granted = await androidPlugin.requestNotificationsPermission();
        return granted ?? false;
      }
    } else if (Platform.isIOS) {
      final iosPlugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      if (iosPlugin != null) {
        final granted = await iosPlugin.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return granted ?? false;
      }
    }
    return false;
  }

  /// Anlık bildirim göster
  /// [showWhenInForeground] true ise uygulama ön plandayken de gösterir
  Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
    required NotificationType type,
    String? payload,
    bool showWhenInForeground = false,
  }) async {
    // Uygulama ön plandayken bildirim gösterme (kullanıcı isteği)
    if (_isAppInForeground && !showWhenInForeground) {
      notificationLogger.debug(
        'Bildirim engellendi: Uygulama ön planda',
        data: {'id': id},
      );
      return;
    }

    // Ayarlardan kontrol et
    final settingsRepo = getIt<NotificationSettingsRepository>();
    if (!_isNotificationTypeEnabled(type, settingsRepo)) {
      notificationLogger.debug(
        'Bildirim engellendi: $type devre dışı',
        data: {'id': id, 'type': type.name},
      );
      return;
    }

    try {
      final channelId = _getChannelIdForType(type);

      final androidDetails = AndroidNotificationDetails(
        channelId,
        _getChannelNameForType(type),
        channelDescription: _getChannelDescForType(type),
        importance: _getImportanceForType(type),
        priority: Priority.high,
        icon: '@mipmap/launcher_icon',
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notificationsPlugin.show(
        id,
        title,
        body,
        details,
        payload: payload,
      );

      notificationLogger.logOperation(
        operation: 'showInstant',
        notificationId: id,
        notificationType: type.name,
        success: true,
      );
    } catch (e, stackTrace) {
      notificationLogger.error(
        'Failed to show instant notification',
        error: e,
        stackTrace: stackTrace,
        data: {'id': id, 'type': type.name},
      );
      throw NotificationScheduleException(
        'İşlem başarısız: Anlık bildirim gösterilemedi',
        notificationId: id,
        originalError: e,
      );
    }
  }

  /// Zamanlanmış bildirim oluştur
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    required NotificationType type,
    String? payload,
  }) async {
    // Timezone'un initialize edildiğinden emin ol
    _ensureTimezoneInitialized();

    // Ayarlardan kontrol et
    final settingsRepo = getIt<NotificationSettingsRepository>();
    if (!_isNotificationTypeEnabled(type, settingsRepo)) {
      notificationLogger.debug(
        'Zamanlanmış bildirim engellendi: $type devre dışı',
        data: {'id': id},
      );
      return;
    }

    try {
      final channelId = _getChannelIdForType(type);

      final androidDetails = AndroidNotificationDetails(
        channelId,
        _getChannelNameForType(type),
        channelDescription: _getChannelDescForType(type),
        importance: _getImportanceForType(type),
        priority: Priority.high,
        icon: '@mipmap/launcher_icon',
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledDate, tz.local),
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );

      notificationLogger.logSchedule(
        scheduleName: 'scheduleNotification',
        scheduledTime: scheduledDate,
        notificationId: id,
        success: true,
      );
    } catch (e, stackTrace) {
      notificationLogger.error(
        'Failed to schedule notification',
        error: e,
        stackTrace: stackTrace,
        data: {
          'id': id,
          'type': type.name,
          'scheduledDate': scheduledDate.toIso8601String(),
        },
      );
      throw NotificationScheduleException(
        'Bildirim zamanlanamadı',
        notificationId: id,
        originalError: e,
      );
    }
  }

  /// Tekrarlayan bildirim oluştur (her gün belirli saatte)
  Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    required NotificationType type,
    String? payload,
  }) async {
    // Timezone'un initialize edildiğinden emin ol
    _ensureTimezoneInitialized();

    final now = DateTime.now();
    var scheduledDate = DateTime(now.year, now.month, now.day, hour, minute);

    // Eğer bugün için saat geçtiyse, yarına planla
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    final channelId = _getChannelIdForType(type);

    final androidDetails = AndroidNotificationDetails(
      channelId,
      _getChannelNameForType(type),
      channelDescription: _getChannelDescForType(type),
      importance: _getImportanceForType(type),
      priority: Priority.defaultPriority,
      icon: '@mipmap/launcher_icon',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // Her gün aynı saatte
      payload: payload,
    );
  }

  /// Haftalık bildirim oluştur
  Future<void> scheduleWeeklyNotification({
    required int id,
    required String title,
    required String body,
    required int dayOfWeek, // 1=Pazartesi, 7=Pazar
    required int hour,
    required NotificationType type,
    String? payload,
  }) async {
    // Timezone'un initialize edildiğinden emin ol
    _ensureTimezoneInitialized();

    final now = DateTime.now();
    var scheduledDate = DateTime(now.year, now.month, now.day, hour, 0);

    // Doğru günü bul
    while (scheduledDate.weekday != dayOfWeek || scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    final channelId = _getChannelIdForType(type);

    final androidDetails = AndroidNotificationDetails(
      channelId,
      _getChannelNameForType(type),
      channelDescription: _getChannelDescForType(type),
      importance: Importance.low,
      priority: Priority.low,
      icon: '@mipmap/launcher_icon',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      payload: payload,
    );
  }

  /// Bildirimi iptal et
  Future<void> cancelNotification(int id) async {
    try {
      await _notificationsPlugin.cancel(id);
      notificationLogger.logOperation(
        operation: 'cancelNotification',
        notificationId: id,
        success: true,
      );
    } catch (e, stackTrace) {
      notificationLogger.error(
        'Failed to cancel notification',
        error: e,
        stackTrace: stackTrace,
        data: {'id': id},
      );
      throw NotificationCancelException(
        'Bildirim iptal edilemedi',
        notificationId: id,
        originalError: e,
      );
    }
  }

  /// Tüm bildirimleri iptal et
  Future<void> cancelAllNotifications() async {
    try {
      await _notificationsPlugin.cancelAll();
      notificationLogger.logOperation(
        operation: 'cancelAllNotifications',
        success: true,
      );
    } catch (e, stackTrace) {
      notificationLogger.error(
        'Failed to cancel all notifications',
        error: e,
        stackTrace: stackTrace,
      );
      throw NotificationCancelException(
        'Tüm bildirimler iptal edilemedi',
        originalError: e,
      );
    }
  }

  /// Bekleyen bildirimleri getir
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notificationsPlugin.pendingNotificationRequests();
  }

  // ===== HELPER METHODS =====

  /// Bildirim tipine göre kanal ID'si
  String _getChannelIdForType(NotificationType type) {
    switch (type) {
      case NotificationType.recurringReminder:
      case NotificationType.streakReminder:
        return NotificationChannels.remindersId;
      case NotificationType.monthlySummary:
      case NotificationType.weeklyMiniSummary:
        return NotificationChannels.summaryId;
      case NotificationType.streakBreakWarning:
        return NotificationChannels.warningsId;
    }
  }

  String _getChannelNameForType(NotificationType type) {
    switch (type) {
      case NotificationType.recurringReminder:
      case NotificationType.streakReminder:
        return NotificationChannels.remindersName;
      case NotificationType.monthlySummary:
      case NotificationType.weeklyMiniSummary:
        return NotificationChannels.summaryName;
      case NotificationType.streakBreakWarning:
        return NotificationChannels.warningsName;
    }
  }

  String _getChannelDescForType(NotificationType type) {
    switch (type) {
      case NotificationType.recurringReminder:
      case NotificationType.streakReminder:
        return NotificationChannels.remindersDesc;
      case NotificationType.monthlySummary:
      case NotificationType.weeklyMiniSummary:
        return NotificationChannels.summaryDesc;
      case NotificationType.streakBreakWarning:
        return NotificationChannels.warningsDesc;
    }
  }

  Importance _getImportanceForType(NotificationType type) {
    switch (type) {
      case NotificationType.recurringReminder:
        return Importance.defaultImportance;
      case NotificationType.streakReminder:
      case NotificationType.monthlySummary:
      case NotificationType.weeklyMiniSummary:
        return Importance.low;
      case NotificationType.streakBreakWarning:
        return Importance.high; // Uyarılar için yüksek öncelik
    }
  }

  /// Bildirim tipi ayarlarda aktif mi kontrol et
  bool _isNotificationTypeEnabled(
    NotificationType type,
    NotificationSettingsRepository settingsRepo,
  ) {
    switch (type) {
      case NotificationType.recurringReminder:
        return settingsRepo.isRecurringReminderEnabled();
      case NotificationType.streakReminder:
        return settingsRepo.isStreakReminderEnabled();
      case NotificationType.monthlySummary:
        return settingsRepo.isMonthlySummaryEnabled();
      case NotificationType.streakBreakWarning:
        return settingsRepo.isStreakBreakWarningEnabled();
      case NotificationType.weeklyMiniSummary:
        return settingsRepo.isWeeklyMiniSummaryEnabled();
    }
  }
}
