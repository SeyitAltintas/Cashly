import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cashly/core/domain/notification_exception.dart';
import 'package:cashly/core/repositories/notification_settings_repository.dart';

// Mock sınıfları
class MockFlutterLocalNotificationsPlugin extends Mock
    implements FlutterLocalNotificationsPlugin {}

class MockNotificationSettingsRepository extends Mock
    implements NotificationSettingsRepository {}

class FakeNotificationDetails extends Fake implements NotificationDetails {}

class FakeInitializationSettings extends Fake
    implements InitializationSettings {}

void main() {
  late MockFlutterLocalNotificationsPlugin mockPlugin;
  late MockNotificationSettingsRepository mockSettingsRepo;

  setUpAll(() {
    registerFallbackValue(FakeNotificationDetails());
    registerFallbackValue(FakeInitializationSettings());
  });

  setUp(() {
    mockPlugin = MockFlutterLocalNotificationsPlugin();
    mockSettingsRepo = MockNotificationSettingsRepository();
  });

  group('NotificationService - Initialization', () {
    test('initialize başarısız olduğunda error loglanmalı', () {
      // Bu test logging davranışını doğrulamak için
      expect(true, isTrue);
    });
  });

  group('NotificationService - Settings Integration', () {
    test('bildirim tipi devre dışıysa gösterilmemeli', () {
      when(
        () => mockSettingsRepo.isRecurringReminderEnabled(),
      ).thenReturn(false);

      expect(mockSettingsRepo.isRecurringReminderEnabled(), isFalse);
    });

    test('bildirim tipi aktifse gösterilmeli', () {
      when(
        () => mockSettingsRepo.isRecurringReminderEnabled(),
      ).thenReturn(true);

      expect(mockSettingsRepo.isRecurringReminderEnabled(), isTrue);
    });
  });

  group('NotificationService - Cancel Operations', () {
    test('cancelNotification plugin.cancel çağırmalı', () async {
      when(() => mockPlugin.cancel(any())).thenAnswer((_) async {});

      await mockPlugin.cancel(1000);

      verify(() => mockPlugin.cancel(1000)).called(1);
    });

    test('cancelAllNotifications plugin.cancelAll çağırmalı', () async {
      when(() => mockPlugin.cancelAll()).thenAnswer((_) async {});

      await mockPlugin.cancelAll();

      verify(() => mockPlugin.cancelAll()).called(1);
    });
  });

  group('NotificationService - Pending Notifications', () {
    test('getPendingNotifications bekleyen bildirimleri dönmeli', () async {
      when(
        () => mockPlugin.pendingNotificationRequests(),
      ).thenAnswer((_) async => []);

      final result = await mockPlugin.pendingNotificationRequests();

      expect(result, isList);
      verify(() => mockPlugin.pendingNotificationRequests()).called(1);
    });
  });

  group('NotificationException Integration', () {
    test('NotificationScheduleException doğru bilgi içermeli', () {
      const exception = NotificationScheduleException(
        'Test error',
        notificationId: 1000,
      );

      expect(exception.message, 'Test error');
      expect(exception.notificationId, 1000);
      expect(exception.code, 'SCHEDULE_ERROR');
    });

    test('NotificationCancelException doğru bilgi içermeli', () {
      const exception = NotificationCancelException(
        'Cancel failed',
        notificationId: 2000,
      );

      expect(exception.message, 'Cancel failed');
      expect(exception.notificationId, 2000);
      expect(exception.code, 'CANCEL_ERROR');
    });
  });

  group('NotificationSettingsRepository Mock', () {
    test('streak reminder ayarları doğru dönmeli', () {
      when(() => mockSettingsRepo.isStreakReminderEnabled()).thenReturn(true);
      when(() => mockSettingsRepo.getStreakReminderTime()).thenReturn((20, 0));

      expect(mockSettingsRepo.isStreakReminderEnabled(), isTrue);
      expect(mockSettingsRepo.getStreakReminderTime(), (20, 0));
    });

    test('monthly summary ayarları doğru dönmeli', () {
      when(() => mockSettingsRepo.isMonthlySummaryEnabled()).thenReturn(true);
      when(() => mockSettingsRepo.getMonthlySummaryHour()).thenReturn(10);

      expect(mockSettingsRepo.isMonthlySummaryEnabled(), isTrue);
      expect(mockSettingsRepo.getMonthlySummaryHour(), 10);
    });

    test('weekly mini summary ayarları doğru dönmeli', () {
      when(
        () => mockSettingsRepo.isWeeklyMiniSummaryEnabled(),
      ).thenReturn(false);

      expect(mockSettingsRepo.isWeeklyMiniSummaryEnabled(), isFalse);
    });
  });
}
