import 'package:flutter/foundation.dart';
import '../domain/notification_types.dart';
import '../repositories/notification_settings_repository.dart';
import '../di/injection_container.dart';
import 'notification_service.dart';

/// Zamanlanmış bildirimlerin yönetimi
/// Seri hatırlatıcı, aylık özet, tekrarlayan işlem hatırlatıcıları
class NotificationScheduler {
  final NotificationService _notificationService;
  final NotificationSettingsRepository _settingsRepo;

  NotificationScheduler({
    NotificationService? notificationService,
    NotificationSettingsRepository? settingsRepo,
  }) : _notificationService =
           notificationService ?? getIt<NotificationService>(),
       _settingsRepo = settingsRepo ?? getIt<NotificationSettingsRepository>();

  /// Seri hatırlatıcısını planla
  /// Her gün belirlenen saatte "Bugün işlem girmediniz" hatırlatması
  Future<void> scheduleStreakReminder() async {
    if (!_settingsRepo.isStreakReminderEnabled()) {
      debugPrint('Seri hatırlatıcı devre dışı');
      return;
    }

    final (hour, minute) = _settingsRepo.getStreakReminderTime();

    await _notificationService.scheduleDailyNotification(
      id: NotificationIds.streakReminder,
      title: '📊 Günlük Hatırlatma',
      body: 'Bugün henüz gelir veya gider girmediniz. Serinizi koruyun!',
      hour: hour,
      minute: minute,
      type: NotificationType.streakReminder,
      payload: 'streak_reminder',
    );

    debugPrint('Seri hatırlatıcı planlandı: $hour:$minute');
  }

  /// Seri hatırlatıcısını iptal et
  Future<void> cancelStreakReminder() async {
    await _notificationService.cancelNotification(
      NotificationIds.streakReminder,
    );
    debugPrint('Seri hatırlatıcı iptal edildi');
  }

  /// Aylık özet bildirimini planla
  /// Her ayın son günü belirlenen saatte finansal özet
  Future<void> scheduleMonthlySummary() async {
    if (!_settingsRepo.isMonthlySummaryEnabled()) {
      debugPrint('Aylık özet devre dışı');
      return;
    }

    final hour = _settingsRepo.getMonthlySummaryHour();

    // Ayın son gününü hesapla
    final now = DateTime.now();
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
    var scheduledDate = DateTime(
      lastDayOfMonth.year,
      lastDayOfMonth.month,
      lastDayOfMonth.day,
      hour,
      0,
    );

    // Eğer bu ayın son günü geçtiyse, gelecek ayın son gününe planla
    if (scheduledDate.isBefore(now)) {
      final nextMonthLastDay = DateTime(now.year, now.month + 2, 0);
      scheduledDate = DateTime(
        nextMonthLastDay.year,
        nextMonthLastDay.month,
        nextMonthLastDay.day,
        hour,
        0,
      );
    }

    await _notificationService.scheduleNotification(
      id: NotificationIds.monthlySummary,
      title: '📈 Aylık Özet',
      body: 'Bu ayki finansal durumunuzu görüntülemek için tıklayın.',
      scheduledDate: scheduledDate,
      type: NotificationType.monthlySummary,
      payload: 'monthly_summary',
    );

    debugPrint(
      'Aylık özet planlandı: ${scheduledDate.day}/${scheduledDate.month}, Saat $hour',
    );
  }

  /// Aylık özet bildirimini iptal et
  Future<void> cancelMonthlySummary() async {
    await _notificationService.cancelNotification(
      NotificationIds.monthlySummary,
    );
    debugPrint('Aylık özet iptal edildi');
  }

  /// Tekrarlayan işlem hatırlatıcısı planla
  /// İşlem gününden 1 gün önce hatırlatma
  Future<void> scheduleRecurringTransactionReminder({
    required String transactionId,
    required String transactionName,
    required int dayOfMonth,
    required double amount,
    required bool isExpense,
  }) async {
    if (!_settingsRepo.isRecurringReminderEnabled()) {
      debugPrint('Tekrarlayan işlem hatırlatıcı devre dışı');
      return;
    }

    // 1 gün öncesi için hatırlatma
    final reminderDay = dayOfMonth == 1 ? 28 : dayOfMonth - 1;
    final now = DateTime.now();

    // Bu ay için planla
    var scheduledDate = DateTime(now.year, now.month, reminderDay, 10, 0);

    // Eğer tarih geçtiyse gelecek aya planla
    if (scheduledDate.isBefore(now)) {
      scheduledDate = DateTime(
        now.month == 12 ? now.year + 1 : now.year,
        now.month == 12 ? 1 : now.month + 1,
        reminderDay,
        10,
        0,
      );
    }

    // Benzersiz ID oluştur (hash'ten)
    final notificationId =
        NotificationIds.recurringReminderBase +
        transactionId.hashCode.abs() % 1000;

    final typeText = isExpense ? 'ödeme' : 'gelir';
    final formattedAmount = amount.toStringAsFixed(2);

    await _notificationService.scheduleNotification(
      id: notificationId,
      title: '🔔 Yarın $typeText Günü',
      body: '$transactionName: ₺$formattedAmount',
      scheduledDate: scheduledDate,
      type: NotificationType.recurringReminder,
      payload: 'recurring_$transactionId',
    );

    debugPrint('Tekrarlayan işlem hatırlatıcı planlandı: $transactionName');
  }

  /// Tekrarlayan işlem hatırlatıcısını iptal et
  Future<void> cancelRecurringTransactionReminder(String transactionId) async {
    final notificationId =
        NotificationIds.recurringReminderBase +
        transactionId.hashCode.abs() % 1000;
    await _notificationService.cancelNotification(notificationId);
    debugPrint('Tekrarlayan işlem hatırlatıcı iptal edildi: $transactionId');
  }

  /// Tüm zamanlanmış bildirimleri yeniden planla
  /// Ayarlar değiştiğinde veya uygulama başladığında çağrılır
  Future<void> rescheduleAll() async {
    // Önce tüm zamanlanmış bildirimleri iptal et
    await _notificationService.cancelAllNotifications();

    // Seri hatırlatıcı
    if (_settingsRepo.isStreakReminderEnabled()) {
      await scheduleStreakReminder();
    }

    // Aylık özet
    if (_settingsRepo.isMonthlySummaryEnabled()) {
      await scheduleMonthlySummary();
    }

    debugPrint('Tüm zamanlanmış bildirimler yeniden planlandı');
  }
}
