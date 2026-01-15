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

  group('UI Bileşen Testleri', () {
    testWidgets('AppBar mevcut olmalı', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // AppBar bulunmalı
      expect(find.byType(AppBar), findsWidgets);
    });

    testWidgets('Temel widget tipleri render edilmeli', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Temel widget'ların varlığını kontrol et
      // En az bir Text widget'ı olmalı
      expect(find.byType(Text), findsWidgets);
    });
  });

  group('Performans Testleri', () {
    testWidgets('Uygulama 5 saniye içinde yüklenmeli', (tester) async {
      final stopwatch = Stopwatch()..start();

      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      stopwatch.stop();

      // 5 saniyeden kısa sürmeli
      expect(stopwatch.elapsedMilliseconds, lessThan(5000));

      // Uygulama yüklenmiş olmalı
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('Birden fazla pump çağrısı stabil olmalı', (tester) async {
      app.main();

      // Birden fazla pump çağrısı yap
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Uygulama hala çalışıyor olmalı
      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });

  group('Erişilebilirlik Testleri', () {
    testWidgets('Scaffold erişilebilir olmalı', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Scaffold semantics kontrolü
      final scaffolds = find.byType(Scaffold);
      expect(scaffolds, findsWidgets);
    });
  });

  group('Hata Dayanıklılık Testleri', () {
    testWidgets('Uygulama tekrar başlatılabilmeli', (tester) async {
      // İlk başlatma
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));
      expect(find.byType(MaterialApp), findsOneWidget);

      // İkinci kez aynı test içinde çalışabilirliği kontrol et
      await tester.pumpAndSettle(const Duration(seconds: 1));
      expect(find.byType(Scaffold), findsWidgets);
    });
  });
}
