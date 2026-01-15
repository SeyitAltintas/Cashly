// Cashly Entegrasyon Testleri
// Uygulama akışlarını gerçek cihaz/emülatörde test eder
//
// NOT: Bu testler gerçek cihaz/emülatörde çalışır.
// flutter test integration_test/ komutu ile çalıştırın.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:cashly/main.dart' as app;

void main() {
  // Entegrasyon test binding'i başlat
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Uygulama Başlatma Testleri', () {
    testWidgets('Uygulama başarıyla başlatılmalı', (tester) async {
      // Uygulamayı başlat
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // MaterialApp bulunmalı
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('Scaffold mevcut olmalı', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Scaffold (herhangi bir sayfa) bulunmalı
      expect(find.byType(Scaffold), findsWidgets);
    });
  });

  group('Temel UI Testleri', () {
    testWidgets('Text widget render edilmeli', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // En az bir Text widget'ı olmalı
      expect(find.byType(Text), findsWidgets);
    });
  });

  group('Performans Testleri', () {
    testWidgets('Uygulama 10 saniye içinde yüklenmeli', (tester) async {
      final stopwatch = Stopwatch()..start();

      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 10));

      stopwatch.stop();

      // Uygulama yüklenmiş olmalı
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(stopwatch.elapsedMilliseconds, lessThan(10000));
    });
  });
}
