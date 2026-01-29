import 'package:flutter_test/flutter_test.dart';
import 'package:cashly/core/domain/notification_types.dart';

void main() {
  group('NotificationSettings', () {
    test('varsay\u0131lan de\u011ferler do\u011fru olmal\u0131', () {
      final settings = NotificationSettings.defaults();

      expect(settings.recurringReminderEnabled, isTrue);
      expect(settings.streakReminderEnabled, isTrue);
      expect(settings.monthlySummaryEnabled, isTrue);
      expect(settings.streakBreakWarningEnabled, isTrue);
      expect(settings.weeklyMiniSummaryEnabled, isTrue);
      expect(settings.streakReminderHour, 20);
      expect(settings.streakReminderMinute, 0);
      expect(settings.monthlySummaryHour, 10);
      expect(settings.monthlySummaryMinute, 0);
    });

    test('toMap do\u011fru \u00e7\u0131kt\u0131 \u00fcretmeli', () {
      final settings = NotificationSettings.defaults();
      final map = settings.toMap();

      expect(map['recurringReminderEnabled'], isTrue);
      expect(map['streakReminderEnabled'], isTrue);
      expect(map['monthlySummaryEnabled'], isTrue);
      expect(map['streakBreakWarningEnabled'], isTrue);
      expect(map['weeklyMiniSummaryEnabled'], isTrue);
      expect(map['streakReminderHour'], 20);
      expect(map['streakReminderMinute'], 0);
    });

    test('fromMap varsay\u0131lan de\u011ferleri doldurmak', () {
      final map = <String, dynamic>{};
      final settings = NotificationSettings.fromMap(map);

      expect(settings.recurringReminderEnabled, isTrue);
      expect(settings.streakReminderEnabled, isTrue);
      expect(settings.streakReminderHour, 20);
    });

    test('fromMap -> toMap roundtrip \u00e7al\u0131\u015fmal\u0131', () {
      const original = NotificationSettings(
        recurringReminderEnabled: false,
        streakReminderEnabled: true,
        monthlySummaryEnabled: false,
        streakBreakWarningEnabled: true,
        weeklyMiniSummaryEnabled: false,
        streakReminderHour: 18,
        streakReminderMinute: 30,
        monthlySummaryHour: 9,
        monthlySummaryMinute: 15,
      );

      final map = original.toMap();
      final restored = NotificationSettings.fromMap(map);

      expect(
        restored.recurringReminderEnabled,
        original.recurringReminderEnabled,
      );
      expect(restored.streakReminderEnabled, original.streakReminderEnabled);
      expect(restored.monthlySummaryEnabled, original.monthlySummaryEnabled);
      expect(
        restored.streakBreakWarningEnabled,
        original.streakBreakWarningEnabled,
      );
      expect(
        restored.weeklyMiniSummaryEnabled,
        original.weeklyMiniSummaryEnabled,
      );
      expect(restored.streakReminderHour, original.streakReminderHour);
      expect(restored.streakReminderMinute, original.streakReminderMinute);
    });

    test('copyWith k\u0131smi g\u00fcncelleme yapmal\u0131', () {
      final original = NotificationSettings.defaults();
      final updated = original.copyWith(
        streakReminderEnabled: false,
        streakReminderHour: 19,
      );

      expect(updated.streakReminderEnabled, isFalse);
      expect(updated.streakReminderHour, 19);
      // Di\u011fer de\u011ferler de\u011fi\u015fmemeli
      expect(updated.recurringReminderEnabled, isTrue);
      expect(updated.monthlySummaryEnabled, isTrue);
      expect(updated.streakReminderMinute, 0);
    });

    test('copyWith t\u00fcm alanlar\u0131 g\u00fcncelleyebilmeli', () {
      final original = NotificationSettings.defaults();
      final updated = original.copyWith(
        recurringReminderEnabled: false,
        streakReminderEnabled: false,
        monthlySummaryEnabled: false,
        streakBreakWarningEnabled: false,
        weeklyMiniSummaryEnabled: false,
        streakReminderHour: 21,
        streakReminderMinute: 45,
        monthlySummaryHour: 8,
        monthlySummaryMinute: 30,
      );

      expect(updated.recurringReminderEnabled, isFalse);
      expect(updated.streakReminderEnabled, isFalse);
      expect(updated.monthlySummaryEnabled, isFalse);
      expect(updated.streakBreakWarningEnabled, isFalse);
      expect(updated.weeklyMiniSummaryEnabled, isFalse);
      expect(updated.streakReminderHour, 21);
      expect(updated.streakReminderMinute, 45);
      expect(updated.monthlySummaryHour, 8);
      expect(updated.monthlySummaryMinute, 30);
    });
  });

  group('NotificationType', () {
    test('t\u00fcm bildirim tipleri mevcut olmal\u0131', () {
      expect(NotificationType.values.length, 5);
      expect(
        NotificationType.values.contains(NotificationType.recurringReminder),
        isTrue,
      );
      expect(
        NotificationType.values.contains(NotificationType.streakReminder),
        isTrue,
      );
      expect(
        NotificationType.values.contains(NotificationType.monthlySummary),
        isTrue,
      );
      expect(
        NotificationType.values.contains(NotificationType.streakBreakWarning),
        isTrue,
      );
      expect(
        NotificationType.values.contains(NotificationType.weeklyMiniSummary),
        isTrue,
      );
    });
  });

  group('NotificationIds', () {
    test('sabitle\u015fmi\u015f ID de\u011ferleri do\u011fru olmal\u0131', () {
      expect(NotificationIds.streakReminder, 1000);
      expect(NotificationIds.monthlySummary, 1001);
      expect(NotificationIds.streakBreakWarning, 1002);
      expect(NotificationIds.weeklyMiniSummary, 1003);
      expect(NotificationIds.recurringReminderBase, 4000);
    });

    test('ID de\u011ferleri benzersiz olmal\u0131', () {
      final ids = [
        NotificationIds.streakReminder,
        NotificationIds.monthlySummary,
        NotificationIds.streakBreakWarning,
        NotificationIds.weeklyMiniSummary,
      ];

      expect(ids.toSet().length, ids.length);
    });
  });

  group('NotificationChannels', () {
    test('kanal sabitleri do\u011fru olmal\u0131', () {
      expect(NotificationChannels.remindersId, 'reminders');
      expect(
        NotificationChannels.remindersName,
        'Hat\u0131rlat\u0131c\u0131lar',
      );
      expect(NotificationChannels.summaryId, 'summary');
      expect(NotificationChannels.summaryName, '\u00d6zetler');
      expect(NotificationChannels.warningsId, 'warnings');
      expect(NotificationChannels.warningsName, 'Uyar\u0131lar');
    });
  });
}
