import 'package:flutter_test/flutter_test.dart';
import 'package:cashly/core/domain/notification_exception.dart';

void main() {
  group('NotificationException', () {
    test('mesaj ve kod do\u011fru olmal\u0131', () {
      const exception = NotificationException(
        'Test mesaj\u0131',
        code: 'TEST_CODE',
      );

      expect(exception.message, 'Test mesaj\u0131');
      expect(exception.code, 'TEST_CODE');
      expect(exception.toString(), contains('NotificationException'));
      expect(exception.toString(), contains('Test mesaj\u0131'));
      expect(exception.toString(), contains('TEST_CODE'));
    });

    test('kod olmadan \u00e7al\u0131\u015fmal\u0131', () {
      const exception = NotificationException('Basit mesaj');

      expect(exception.message, 'Basit mesaj');
      expect(exception.code, isNull);
      expect(exception.toString(), isNot(contains('code:')));
    });

    test('originalError saklanmal\u0131', () {
      final originalError = Exception('Orijinal hata');
      final exception = NotificationException(
        'Wrapped error',
        originalError: originalError,
      );

      expect(exception.originalError, originalError);
    });
  });

  group('NotificationPermissionDeniedException', () {
    test('varsay\u0131lan mesaj ve kod do\u011fru olmal\u0131', () {
      const exception = NotificationPermissionDeniedException();

      expect(exception.message, 'Bildirim izni reddedildi');
      expect(exception.code, 'PERMISSION_DENIED');
    });

    test('\u00f6zel mesaj kabul etmeli', () {
      const exception = NotificationPermissionDeniedException(
        '\u00d6zel izin mesaj\u0131',
      );

      expect(exception.message, '\u00d6zel izin mesaj\u0131');
      expect(exception.code, 'PERMISSION_DENIED');
    });
  });

  group('NotificationScheduleException', () {
    test('notificationId saklanmal\u0131', () {
      const exception = NotificationScheduleException(
        'Zamanlama hatas\u0131',
        notificationId: 1001,
      );

      expect(exception.message, 'Zamanlama hatas\u0131');
      expect(exception.code, 'SCHEDULE_ERROR');
      expect(exception.notificationId, 1001);
      expect(exception.toString(), contains('id: 1001'));
    });

    test('notificationId olmadan \u00e7al\u0131\u015fmal\u0131', () {
      const exception = NotificationScheduleException(
        'Basit zamanlama hatas\u0131',
      );

      expect(exception.notificationId, isNull);
      expect(exception.toString(), isNot(contains('id:')));
    });
  });

  group('NotificationPlatformException', () {
    test('platform bilgisi saklanmal\u0131', () {
      const exception = NotificationPlatformException(
        'Android kanal hatas\u0131',
        platform: 'android',
      );

      expect(exception.message, 'Android kanal hatas\u0131');
      expect(exception.code, 'PLATFORM_ERROR');
      expect(exception.platform, 'android');
      expect(exception.toString(), contains('[android]'));
    });

    test('iOS platform testi', () {
      const exception = NotificationPlatformException(
        'iOS izin hatas\u0131',
        platform: 'ios',
      );

      expect(exception.platform, 'ios');
      expect(exception.toString(), contains('[ios]'));
    });
  });

  group('NotificationCancelException', () {
    test('notificationId saklanmal\u0131', () {
      const exception = NotificationCancelException(
        '\u0130ptal hatas\u0131',
        notificationId: 2000,
      );

      expect(exception.message, '\u0130ptal hatas\u0131');
      expect(exception.code, 'CANCEL_ERROR');
      expect(exception.notificationId, 2000);
    });

    test('originalError saklanmal\u0131', () {
      final originalError = Exception('Platform error');
      final exception = NotificationCancelException(
        'Cancel failed',
        originalError: originalError,
      );

      expect(exception.originalError, originalError);
    });
  });
}
