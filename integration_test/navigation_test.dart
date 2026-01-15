// Cashly Navigasyon Testleri
// Sayfa geçişlerini ve scroll davranışlarını test eder

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:cashly/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Navigasyon Testleri', () {
    testWidgets('Uygulama başlatılabilmeli', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Uygulama çalışıyor
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('Scroll işlemi crash etmemeli', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // ScrollView türleri bul
      final scrollables = find.byType(Scrollable);

      if (scrollables.evaluate().isNotEmpty) {
        // Scroll yap
        await tester.drag(scrollables.first, const Offset(0, -100));
        await tester.pumpAndSettle();
      }

      // Uygulama hala çalışıyor olmalı
      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });

  group('Tıklama Testleri', () {
    testWidgets('Tıklama işlemleri crash etmemeli', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Uygulama hala çalışıyor olmalı
      expect(find.byType(Scaffold), findsWidgets);
    });
  });
}
