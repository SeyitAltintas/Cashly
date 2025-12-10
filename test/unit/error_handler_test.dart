import 'package:flutter_test/flutter_test.dart';
import 'package:cashly/core/utils/error_handler.dart';

void main() {
  group('ErrorHandler', () {
    group('logError', () {
      test('debug mesajı yazdırır (hata atmaz)', () {
        // logError konsola yazdırır, hata atmadan çalışmalı
        expect(
          () => ErrorHandler.logError('Test Context', 'Test Error'),
          returnsNormally,
        );
      });

      test('stack trace ile çalışır', () {
        expect(
          () => ErrorHandler.logError(
            'Test Context',
            Exception('Test Exception'),
            StackTrace.current,
          ),
          returnsNormally,
        );
      });
    });
  });
}
