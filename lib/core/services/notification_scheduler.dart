import 'package:timezone/timezone.dart' as tz;
import '../domain/notification_types.dart';
import '../repositories/notification_settings_repository.dart';
import '../repositories/expense_repository.dart';
import '../di/injection_container.dart';
import '../utils/notification_logger.dart';
import '../../features/streak/domain/repositories/streak_repository.dart';
import 'currency_service.dart';
import 'notification_service.dart';

/// Zamanlanmış bildirimlerin yönetimi
/// Seri hatırlatıcı, aylık özet, tekrarlayan işlem hatırlatıcıları
class NotificationScheduler {
  final NotificationService _notificationService;
  final NotificationSettingsRepository _settingsRepo;
  final StreakRepository? _streakRepo;

  NotificationScheduler({
    NotificationService? notificationService,
    NotificationSettingsRepository? settingsRepo,
    StreakRepository? streakRepo,
  }) : _notificationService =
           notificationService ?? getIt<NotificationService>(),
       _settingsRepo = settingsRepo ?? getIt<NotificationSettingsRepository>(),
       _streakRepo =
           streakRepo ??
           (getIt.isRegistered<StreakRepository>()
               ? getIt<StreakRepository>()
               : null);

  /// Seri hatırlatıcısını planla
  /// Her gün belirlenen saatte "Bugün işlem girmediniz" hatırlatması
  Future<void> scheduleStreakReminder() async {
    if (!_settingsRepo.isStreakReminderEnabled()) {
      notificationLogger.debug('Seri hatırlatıcı devre dışı');
      return;
    }

    final (hour, minute) = _settingsRepo.getStreakReminderTime();

    // Dinamik seri gün sayısını al ve bugün işlem kontrolü
    int streakDays = 0;
    bool todayHasTransaction = false;
    if (_streakRepo != null) {
      try {
        final streakData = _streakRepo.getStreakData('user');
        streakDays = streakData.currentStreak;

        // Bugün işlem girilmiş mi kontrol et
        final today = DateTime.now();
        final lastLoginStr = streakData.lastLoginDate;
        if (lastLoginStr.isNotEmpty) {
          final lastLogin = DateTime.tryParse(lastLoginStr);
          if (lastLogin != null &&
              lastLogin.year == today.year &&
              lastLogin.month == today.month &&
              lastLogin.day == today.day) {
            todayHasTransaction = true;
          }
        }
      } catch (e) {
        notificationLogger.warning(
          'Seri verisi alınamadı',
          data: {'error': e.toString()},
        );
      }
    }

    // Bugün işlem girilmişse hatırlatma gönderme
    if (todayHasTransaction) {
      notificationLogger.debug(
        'Seri hatırlatıcı atlandı: Bugün işlem girilmiş',
      );
      return;
    }

    // Mesajı seri durumuna göre ayarla
    final String body = streakDays > 0
        ? 'Bugün henüz işlem girmediniz. $streakDays günlük serinizi kaybetmeyin!'
        : 'Bugün henüz işlem girmediniz. Serinizi başlatın!';

    await _notificationService.scheduleDailyNotification(
      id: NotificationIds.streakReminder,
      title: '🔥 Serinizi Koruyun!',
      body: body,
      hour: hour,
      minute: minute,
      type: NotificationType.streakReminder,
      payload: 'streak_reminder',
    );

    notificationLogger.logSchedule(
      scheduleName: 'streakReminder',
      scheduledTime: DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
        hour,
        minute,
      ),
      notificationId: NotificationIds.streakReminder,
      success: true,
    );
  }

  /// Seri hatırlatıcısını iptal et
  Future<void> cancelStreakReminder() async {
    await _notificationService.cancelNotification(
      NotificationIds.streakReminder,
    );
    notificationLogger.logOperation(
      operation: 'cancelStreakReminder',
      notificationId: NotificationIds.streakReminder,
      success: true,
    );
  }

  /// Aylık özet bildirimini planla
  /// Her ayın son günü belirlenen saatte finansal özet
  Future<void> scheduleMonthlySummary() async {
    if (!_settingsRepo.isMonthlySummaryEnabled()) {
      notificationLogger.debug('Aylık özet devre dışı');
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

    // Dinamik aylık toplam harcamayı hesapla
    double monthlyTotal = 0;
    try {
      final harcamalar = ExpenseRepository.harcamalariGetir('user');
      final currentMonth = now.month;
      final currentYear = now.year;

      for (final harcama in harcamalar) {
        final tarihStr = harcama['tarih'] as String? ?? '';
        if (tarihStr.isNotEmpty) {
          final tarih = DateTime.tryParse(tarihStr);
          if (tarih != null &&
              tarih.month == currentMonth &&
              tarih.year == currentYear) {
            monthlyTotal += (harcama['tutar'] as num?)?.toDouble() ?? 0;
          }
        }
      }
    } catch (e) {
      notificationLogger.warning(
        'Aylık harcama hesaplanamadı',
        data: {'error': e.toString()},
      );
    }

    // Mesajı duruma göre ayarla
    final String body = monthlyTotal > 0
        ? 'Bu ay ${getIt<CurrencyService>().currentSymbol}${monthlyTotal.toStringAsFixed(0)} harcadınız. Detaylar için tıklayın.'
        : 'Bu ayki finansal durumunuzu görüntülemek için tıklayın.';

    await _notificationService.scheduleNotification(
      id: NotificationIds.monthlySummary,
      title: '📊 Aylık Özet Hazır',
      body: body,
      scheduledDate: scheduledDate,
      type: NotificationType.monthlySummary,
      payload: 'monthly_summary',
    );

    notificationLogger.logSchedule(
      scheduleName: 'monthlySummary',
      scheduledTime: scheduledDate,
      notificationId: NotificationIds.monthlySummary,
      success: true,
    );
  }

  /// Aylık özet bildirimini iptal et
  Future<void> cancelMonthlySummary() async {
    await _notificationService.cancelNotification(
      NotificationIds.monthlySummary,
    );
    notificationLogger.logOperation(
      operation: 'cancelMonthlySummary',
      notificationId: NotificationIds.monthlySummary,
      success: true,
    );
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
      notificationLogger.debug('Tekrarlayan işlem hatırlatıcı devre dışı');
      return;
    }

    final now = DateTime.now();

    // Hatırlatma gününü hesapla (1 gün önce)
    int reminderDay;
    int targetMonth = now.month;
    int targetYear = now.year;

    if (dayOfMonth == 1) {
      // Ayın 1'i ise, bir önceki ayın son gününe hatırlatma
      final prevMonth = now.month == 1 ? 12 : now.month - 1;
      final prevYear = now.month == 1 ? now.year - 1 : now.year;
      final lastDayOfPrevMonth = DateTime(prevYear, prevMonth + 1, 0).day;
      reminderDay = lastDayOfPrevMonth;
      targetMonth = prevMonth;
      targetYear = prevYear;
    } else {
      reminderDay = dayOfMonth - 1;
    }

    // Hedef ay için maksimum gün sayısını kontrol et
    final maxDayInMonth = DateTime(targetYear, targetMonth + 1, 0).day;
    if (reminderDay > maxDayInMonth) {
      reminderDay = maxDayInMonth; // Ayın son günü
    }

    // Bu ay için planla
    var scheduledDate = DateTime(targetYear, targetMonth, reminderDay, 10, 0);

    // Eğer tarih geçtiyse gelecek aya planla
    if (scheduledDate.isBefore(now)) {
      final nextMonth = now.month == 12 ? 1 : now.month + 1;
      final nextYear = now.month == 12 ? now.year + 1 : now.year;

      // Gelecek ay için hatırlatma gününü yeniden hesapla
      if (dayOfMonth == 1) {
        final nextMaxDay = DateTime(nextYear, nextMonth + 1, 0).day;
        reminderDay = nextMaxDay;
        scheduledDate = DateTime(nextYear, nextMonth, reminderDay, 10, 0);
      } else {
        final nextMaxDay = DateTime(nextYear, nextMonth + 1, 0).day;
        reminderDay = (dayOfMonth - 1) > nextMaxDay
            ? nextMaxDay
            : dayOfMonth - 1;
        scheduledDate = DateTime(nextYear, nextMonth, reminderDay, 10, 0);
      }
    }

    // Benzersiz ID oluştur (hash'ten)
    final notificationId =
        NotificationIds.recurringReminderBase +
        transactionId.hashCode.abs() %
            10000; // 10000'e çıkardık, çakışma azaltma

    final formattedAmount = amount.toStringAsFixed(2);

    await _notificationService.scheduleNotification(
      id: notificationId,
      title: '💸 Ödeme Yaklaşıyor',
      body:
          '$transactionName için ${getIt<CurrencyService>().currentSymbol}$formattedAmount ödemeniz yarın.',
      scheduledDate: scheduledDate,
      type: NotificationType.recurringReminder,
      payload: 'recurring_$transactionId',
    );

    notificationLogger.logSchedule(
      scheduleName: 'recurringTransaction',
      scheduledTime: scheduledDate,
      notificationId: notificationId,
      success: true,
    );
  }

  /// Tekrarlayan işlem hatırlatıcısını iptal et
  Future<void> cancelRecurringTransactionReminder(String transactionId) async {
    final notificationId =
        NotificationIds.recurringReminderBase +
        transactionId.hashCode.abs() % 1000;
    await _notificationService.cancelNotification(notificationId);
    notificationLogger.logOperation(
      operation: 'cancelRecurringTransaction',
      notificationId: notificationId,
      details: transactionId,
      success: true,
    );
  }

  /// Seri kırılma uyarısını zamanla (her gün 22:00)
  /// Sadece aktif seri varsa gönderilir
  Future<void> scheduleStreakBreakWarning() async {
    if (!_settingsRepo.isStreakBreakWarningEnabled()) {
      notificationLogger.debug('Seri kırılma uyarısı devre dışı');
      return;
    }

    // Seri kontrolü - seri yoksa uyarı gönderme
    int streakDays = 0;
    bool todayHasTransaction = false;
    if (_streakRepo != null) {
      try {
        final streakData = _streakRepo.getStreakData('user');
        streakDays = streakData.currentStreak;

        // Bugün işlem girilmiş mi kontrol et
        final today = DateTime.now();
        final lastLoginStr = streakData.lastLoginDate;
        if (lastLoginStr.isNotEmpty) {
          final lastLogin = DateTime.tryParse(lastLoginStr);
          if (lastLogin != null &&
              lastLogin.year == today.year &&
              lastLogin.month == today.month &&
              lastLogin.day == today.day) {
            todayHasTransaction = true;
          }
        }
      } catch (e) {
        notificationLogger.warning(
          'Seri verisi alınamadı',
          data: {'error': e.toString()},
        );
      }
    }

    // Seri 0 ise veya bugün işlem girilmişse uyarı gönderme
    if (streakDays == 0) {
      notificationLogger.debug('Seri kırılma uyarısı atlandı: Aktif seri yok');
      return;
    }

    if (todayHasTransaction) {
      notificationLogger.debug(
        'Seri kırılma uyarısı atlandı: Bugün işlem girilmiş',
      );
      return;
    }

    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      22, // 22:00
      0,
    );

    // Eğer saat geçtiyse yarına planla
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _notificationService.scheduleNotification(
      id: NotificationIds.streakBreakWarning,
      title: '🚨 Son Şans!',
      body: 'Seriniz kırılmak üzere! Bugün işlem girmeyi unutmayın.',
      scheduledDate: scheduledDate,
      type: NotificationType.streakBreakWarning,
      payload: 'streak_break_warning',
    );

    notificationLogger.logSchedule(
      scheduleName: 'streakBreakWarning',
      scheduledTime: scheduledDate,
      notificationId: NotificationIds.streakBreakWarning,
      success: true,
    );
  }

  /// Haftalık mini özet zamanla (her Pazar 18:00)
  Future<void> scheduleWeeklyMiniSummary() async {
    if (!_settingsRepo.isWeeklyMiniSummaryEnabled()) {
      notificationLogger.debug('Haftalık mini özet devre dışı');
      return;
    }

    final now = tz.TZDateTime.now(tz.local);

    // Bir sonraki Pazar gününü bul
    int daysUntilSunday = DateTime.sunday - now.weekday;
    if (daysUntilSunday <= 0) {
      daysUntilSunday += 7; // Gelecek Pazar
    }

    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day + daysUntilSunday,
      18, // 18:00
      0,
    );

    // Dinamik haftalık kategori verisi hesapla
    String topCategory = '';
    double topAmount = 0;
    try {
      final harcamalar = ExpenseRepository.harcamalariGetir('user');
      final weekStart = DateTime.now().subtract(const Duration(days: 7));

      // Kategoriye göre harcamaları grupla
      final Map<String, double> categoryTotals = {};

      for (final harcama in harcamalar) {
        final tarihStr = harcama['tarih'] as String? ?? '';
        if (tarihStr.isNotEmpty) {
          final tarih = DateTime.tryParse(tarihStr);
          if (tarih != null && tarih.isAfter(weekStart)) {
            final kategori = harcama['kategori'] as String? ?? 'Diğer';
            final tutar = (harcama['tutar'] as num?)?.toDouble() ?? 0;
            categoryTotals[kategori] = (categoryTotals[kategori] ?? 0) + tutar;
          }
        }
      }

      // En yüksek tutarlı kategoriyi bul
      if (categoryTotals.isNotEmpty) {
        final sorted = categoryTotals.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        topCategory = sorted.first.key;
        topAmount = sorted.first.value;
      }
    } catch (e) {
      notificationLogger.warning(
        'Haftalık kategori hesaplanamadı',
        data: {'error': e.toString()},
      );
    }

    // Mesajı duruma göre ayarla
    final String body = topCategory.isNotEmpty && topAmount > 0
        ? 'Bu hafta en çok $topCategory kategorisine ${getIt<CurrencyService>().currentSymbol}${topAmount.toStringAsFixed(0)} harcadınız.'
        : 'Bu hafta en çok hangi kategoride harcama yaptığınızı görün!';

    await _notificationService.scheduleNotification(
      id: NotificationIds.weeklyMiniSummary,
      title: '🗓️ Haftalık Rapor',
      body: body,
      scheduledDate: scheduledDate,
      type: NotificationType.weeklyMiniSummary,
      payload: 'weekly_mini_summary',
    );

    notificationLogger.logSchedule(
      scheduleName: 'weeklyMiniSummary',
      scheduledTime: scheduledDate,
      notificationId: NotificationIds.weeklyMiniSummary,
      success: true,
    );
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

    // Seri kırılma uyarısı
    if (_settingsRepo.isStreakBreakWarningEnabled()) {
      await scheduleStreakBreakWarning();
    }

    // Haftalık mini özet
    if (_settingsRepo.isWeeklyMiniSummaryEnabled()) {
      await scheduleWeeklyMiniSummary();
    }

    notificationLogger.info('Tüm zamanlanmış bildirimler yeniden planlandı');
  }
}
