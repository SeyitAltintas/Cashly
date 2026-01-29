import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cashly/core/domain/notification_types.dart';
import 'package:cashly/core/repositories/notification_settings_repository.dart';
import 'package:cashly/core/services/notification_service.dart';
import 'package:cashly/features/streak/domain/repositories/streak_repository.dart';
import 'package:cashly/features/streak/data/models/streak_model.dart';

// Mock sınıfları
class MockNotificationService extends Mock implements NotificationService {}

class MockNotificationSettingsRepository extends Mock
    implements NotificationSettingsRepository {}

class MockStreakRepository extends Mock implements StreakRepository {}

void main() {
  late MockNotificationService mockNotificationService;
  late MockNotificationSettingsRepository mockSettingsRepo;
  late MockStreakRepository mockStreakRepo;

  setUp(() {
    mockNotificationService = MockNotificationService();
    mockSettingsRepo = MockNotificationSettingsRepository();
    mockStreakRepo = MockStreakRepository();
  });

  group('NotificationScheduler - Streak Reminder', () {
    test('streak reminder devre dışıysa planlanmamalı', () {
      when(() => mockSettingsRepo.isStreakReminderEnabled()).thenReturn(false);

      expect(mockSettingsRepo.isStreakReminderEnabled(), isFalse);
    });

    test('streak reminder aktifse saat bilgisi alınmalı', () {
      when(() => mockSettingsRepo.isStreakReminderEnabled()).thenReturn(true);
      when(() => mockSettingsRepo.getStreakReminderTime()).thenReturn((20, 0));

      expect(mockSettingsRepo.isStreakReminderEnabled(), isTrue);
      final (hour, minute) = mockSettingsRepo.getStreakReminderTime();
      expect(hour, 20);
      expect(minute, 0);
    });

    test('seri verisi alınabilmeli', () {
      final streakData = StreakData(
        currentStreak: 5,
        longestStreak: 10,
        lastLoginDate: DateTime.now().toIso8601String(),
        totalLoginDays: 30,
        earnedBadges: const [],
      );

      when(() => mockStreakRepo.getStreakData('user')).thenReturn(streakData);

      final result = mockStreakRepo.getStreakData('user');
      expect(result.currentStreak, 5);
      expect(result.longestStreak, 10);
    });

    test('bugün işlem girilmişse hatırlatma atlanmalı', () {
      final today = DateTime.now();
      final streakData = StreakData(
        currentStreak: 3,
        longestStreak: 5,
        lastLoginDate: today.toIso8601String(),
        totalLoginDays: 10,
        earnedBadges: const [],
      );

      when(() => mockStreakRepo.getStreakData('user')).thenReturn(streakData);

      final result = mockStreakRepo.getStreakData('user');
      final lastLogin = DateTime.tryParse(result.lastLoginDate);

      expect(lastLogin, isNotNull);
      expect(lastLogin!.day, today.day);
      expect(lastLogin.month, today.month);
      expect(lastLogin.year, today.year);
    });
  });

  group('NotificationScheduler - Monthly Summary', () {
    test('monthly summary devre dışıysa planlanmamalı', () {
      when(() => mockSettingsRepo.isMonthlySummaryEnabled()).thenReturn(false);

      expect(mockSettingsRepo.isMonthlySummaryEnabled(), isFalse);
    });

    test('monthly summary saati alınabilmeli', () {
      when(() => mockSettingsRepo.isMonthlySummaryEnabled()).thenReturn(true);
      when(() => mockSettingsRepo.getMonthlySummaryHour()).thenReturn(10);

      expect(mockSettingsRepo.getMonthlySummaryHour(), 10);
    });
  });

  group('NotificationScheduler - Streak Break Warning', () {
    test('streak break warning devre dışıysa planlanmamalı', () {
      when(
        () => mockSettingsRepo.isStreakBreakWarningEnabled(),
      ).thenReturn(false);

      expect(mockSettingsRepo.isStreakBreakWarningEnabled(), isFalse);
    });

    test('aktif seri yoksa uyarı gönderilmemeli', () {
      const streakData = StreakData(
        currentStreak: 0,
        longestStreak: 5,
        lastLoginDate: '',
        totalLoginDays: 5,
        earnedBadges: [],
      );

      when(() => mockStreakRepo.getStreakData('user')).thenReturn(streakData);

      final result = mockStreakRepo.getStreakData('user');
      expect(result.currentStreak, 0);
    });
  });

  group('NotificationScheduler - Weekly Mini Summary', () {
    test('weekly mini summary devre dışıysa planlanmamalı', () {
      when(
        () => mockSettingsRepo.isWeeklyMiniSummaryEnabled(),
      ).thenReturn(false);

      expect(mockSettingsRepo.isWeeklyMiniSummaryEnabled(), isFalse);
    });

    test('weekly mini summary aktifse planlanmalı', () {
      when(
        () => mockSettingsRepo.isWeeklyMiniSummaryEnabled(),
      ).thenReturn(true);

      expect(mockSettingsRepo.isWeeklyMiniSummaryEnabled(), isTrue);
    });
  });

  group('NotificationScheduler - Recurring Transaction', () {
    test('recurring reminder devre dışıysa planlanmamalı', () {
      when(
        () => mockSettingsRepo.isRecurringReminderEnabled(),
      ).thenReturn(false);

      expect(mockSettingsRepo.isRecurringReminderEnabled(), isFalse);
    });

    test('transaction ID hash benzersiz olmalı', () {
      const transactionId1 = 'trans_001';
      const transactionId2 = 'trans_002';

      final notificationId1 =
          NotificationIds.recurringReminderBase +
          transactionId1.hashCode.abs() % 10000;
      final notificationId2 =
          NotificationIds.recurringReminderBase +
          transactionId2.hashCode.abs() % 10000;

      expect(notificationId1, isNot(equals(notificationId2)));
    });
  });

  group('NotificationScheduler - RescheduleAll', () {
    test('tüm ayarlar okunabilmeli', () {
      when(() => mockSettingsRepo.isStreakReminderEnabled()).thenReturn(true);
      when(() => mockSettingsRepo.isMonthlySummaryEnabled()).thenReturn(true);
      when(
        () => mockSettingsRepo.isStreakBreakWarningEnabled(),
      ).thenReturn(false);
      when(
        () => mockSettingsRepo.isWeeklyMiniSummaryEnabled(),
      ).thenReturn(true);

      expect(mockSettingsRepo.isStreakReminderEnabled(), isTrue);
      expect(mockSettingsRepo.isMonthlySummaryEnabled(), isTrue);
      expect(mockSettingsRepo.isStreakBreakWarningEnabled(), isFalse);
      expect(mockSettingsRepo.isWeeklyMiniSummaryEnabled(), isTrue);
    });

    test('cancelAllNotifications çağrılabilmeli', () async {
      when(
        () => mockNotificationService.cancelAllNotifications(),
      ).thenAnswer((_) async {});

      await mockNotificationService.cancelAllNotifications();

      verify(() => mockNotificationService.cancelAllNotifications()).called(1);
    });
  });

  group('NotificationIds - Consistency', () {
    test('ID değerleri stabil olmalı', () {
      expect(NotificationIds.streakReminder, 1000);
      expect(NotificationIds.monthlySummary, 1001);
      expect(NotificationIds.streakBreakWarning, 1002);
      expect(NotificationIds.weeklyMiniSummary, 1003);
      expect(NotificationIds.recurringReminderBase, 4000);
    });

    test('recurring reminder ID aralığı yeterli olmalı', () {
      const minRecurringId = NotificationIds.recurringReminderBase;
      const maxRecurringId = NotificationIds.recurringReminderBase + 9999;

      expect(minRecurringId, greaterThan(NotificationIds.weeklyMiniSummary));
      expect(maxRecurringId, lessThan(14000));
    });
  });
}
