// Cashly Entegrasyon Testleri
// Uygulama akışlarını gerçek cihaz/emülatörde test eder
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
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // MaterialApp bulunmalı
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('Splash screen veya login sayfası görünmeli', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Scaffold (herhangi bir sayfa) bulunmalı
      expect(find.byType(Scaffold), findsWidgets);
    });
  });

  group('Temel Navigasyon Testleri', () {
    testWidgets('Uygulama widget ağacı oluşturulmalı', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Widget ağacı var mı kontrol et
      final finder = find.byType(Scaffold);
      expect(finder, findsWidgets);
    });
  });
}
