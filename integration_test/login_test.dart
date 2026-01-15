// Cashly Login/Auth Testleri
// Kimlik doğrulama akışlarını test eder

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:cashly/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Auth Testleri', () {
    testWidgets('Uygulama başlatılabilmeli', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // MaterialApp bulunmalı
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('Login veya Ana sayfa görünmeli', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Scaffold bulunmalı (login veya ana sayfa)
      expect(find.byType(Scaffold), findsWidgets);
    });
  });
}
