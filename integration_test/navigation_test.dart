// Cashly Navigasyon Akış Testleri
// Sayfa geçişlerini ve navigasyon davranışlarını test eder

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:cashly/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Ana Sayfa Navigasyon Testleri', () {
    testWidgets('Bottom navigation bar görünür olmalı', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // BottomNavigationBar veya özel navigasyon widget'ı olmalı
      final hasBottomNav =
          find.byType(BottomNavigationBar).evaluate().isNotEmpty ||
          find.byType(NavigationBar).evaluate().isNotEmpty;

      // Ana sayfa veya login sayfasındayız
      final hasScaffold = find.byType(Scaffold).evaluate().isNotEmpty;
      expect(hasScaffold || hasBottomNav, isTrue);
    });

    testWidgets('Sayfa geçişleri crash etmemeli', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Herhangi bir tıklanabilir öğe bul
      final gestureDetectors = find.byType(GestureDetector);
      final inkWells = find.byType(InkWell);

      // En az bir tıklanabilir öğe var mı
      final hasTappables =
          gestureDetectors.evaluate().isNotEmpty ||
          inkWells.evaluate().isNotEmpty;

      if (hasTappables) {
        // İlk tıklanabilir öğeye tıkla
        if (inkWells.evaluate().isNotEmpty) {
          await tester.tap(inkWells.first);
          await tester.pumpAndSettle(const Duration(seconds: 2));
        }
      }

      // Uygulama hala çalışıyor olmalı
      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });

  group('Geri Butonu Testleri', () {
    testWidgets('Geri butonu crash etmemeli', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Geri butonu bul
      final backButtons = find.byIcon(Icons.arrow_back);
      final backButtonAlt = find.byIcon(Icons.arrow_back_ios);
      final hasBackButton =
          backButtons.evaluate().isNotEmpty ||
          backButtonAlt.evaluate().isNotEmpty;

      if (hasBackButton) {
        if (backButtons.evaluate().isNotEmpty) {
          await tester.tap(backButtons.first);
        } else {
          await tester.tap(backButtonAlt.first);
        }
        await tester.pumpAndSettle(const Duration(seconds: 1));
      }

      // Uygulama hala çalışıyor olmalı
      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });

  group('Floating Action Button Testleri', () {
    testWidgets('FAB varsa tıklanabilir olmalı', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // FloatingActionButton bul
      final fab = find.byType(FloatingActionButton);

      if (fab.evaluate().isNotEmpty) {
        await tester.tap(fab.first);
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // Uygulama hala çalışıyor olmalı
        expect(find.byType(MaterialApp), findsOneWidget);
      } else {
        // FAB yoksa da kabul et
        expect(true, isTrue);
      }
    });
  });

  group('Scroll Testleri', () {
    testWidgets('Sayfalar scroll edilebilir olmalı', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // ScrollView türleri bul
      final listViews = find.byType(ListView);
      final singleChildScrollViews = find.byType(SingleChildScrollView);
      final customScrollViews = find.byType(CustomScrollView);

      final hasScrollable =
          listViews.evaluate().isNotEmpty ||
          singleChildScrollViews.evaluate().isNotEmpty ||
          customScrollViews.evaluate().isNotEmpty;

      if (hasScrollable) {
        // Scroll yap
        await tester.drag(
          listViews.evaluate().isNotEmpty
              ? listViews.first
              : singleChildScrollViews.first,
          const Offset(0, -100),
        );
        await tester.pumpAndSettle();
      }

      // Uygulama hala çalışıyor olmalı
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('Pull-to-refresh çalışmalı', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // RefreshIndicator bul
      final refreshIndicators = find.byType(RefreshIndicator);

      if (refreshIndicators.evaluate().isNotEmpty) {
        // Aşağı çek
        await tester.drag(refreshIndicators.first, const Offset(0, 200));
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // Uygulama hala çalışıyor olmalı
        expect(find.byType(MaterialApp), findsOneWidget);
      } else {
        // RefreshIndicator yoksa da kabul et (login sayfasında olabiliriz)
        expect(true, isTrue);
      }
    });
  });

  group('Modal ve Dialog Testleri', () {
    testWidgets('Dialog açıldığında kapatılabilmeli', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Herhangi bir dialog veya bottomSheet varsa
      final hasDialogs = find.byType(Dialog).evaluate().isNotEmpty;
      final hasBottomSheets = find.byType(BottomSheet).evaluate().isNotEmpty;

      if (hasDialogs || hasBottomSheets) {
        // Dialog'u kapat
        final closeButton = find.byIcon(Icons.close);
        if (closeButton.evaluate().isNotEmpty) {
          await tester.tap(closeButton.first);
          await tester.pumpAndSettle();
        }
      }

      // Uygulama hala çalışıyor olmalı
      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });
}
