import 'package:flutter_test/flutter_test.dart';
import 'package:cashly/core/utils/error_handler.dart';

import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:io';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  setUpAll(() {
    Hive.init(Directory.systemTemp.path);
    final Map<String, String> storage = {};
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
      (MethodCall methodCall) async {
        final args = methodCall.arguments as Map<dynamic, dynamic>?;
        final key = args?['key'] as String?;
        if (methodCall.method == 'read') return storage[key];
        if (methodCall.method == 'write') {
          storage[key!] = args?['value'] as String;
          return null;
        }
        if (methodCall.method == 'readAll') return storage;
        if (methodCall.method == 'containsKey') return storage.containsKey(key);
        return null;
      },
    );
  });

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
