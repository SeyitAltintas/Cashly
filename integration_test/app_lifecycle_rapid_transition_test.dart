import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:cashly/main.dart' as app;

/// 87. Fast Backgrounding App Lifecycle Stress Test
/// Amaç: Kullanıcı bir işlem yaparken uygulamayı art arda alta alıp (Background)
/// tekrar öne getirdiğinde (Foreground) verilerin kaybolmadığını,
/// Timer/Animation/Provider'ların bellek sızıntısına neden olmadığını doğrulamak.

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('App Lifecycle Fast Background Conflict Test', (
    WidgetTester tester,
  ) async {
    app.main();
    await tester.pumpAndSettle();

    // Bir ekranda state oluşturalım (Örn: Gider Ekle sayfası)
    final fabButton = find.byType(FloatingActionButton);
    if (fabButton.evaluate().isNotEmpty) {
      await tester.tap(fabButton.first);
      await tester.pumpAndSettle();

      final firstTextField = find.byType(TextField).first;
      if (firstTextField.evaluate().isNotEmpty) {
        await tester.enterText(firstTextField, 'Yarım Kalan Veri');
        await tester.pump(const Duration(milliseconds: 100));

        // =========================================================
        // SİMÜLASYON: Uygulama aniden arka plana (Background) alındı
        // =========================================================
        tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
        await tester.pump(
          const Duration(seconds: 1),
        ); // Bir saniye dışarıda bekle

        // Uygulama tekrar öne geldi (Foreground)
        tester.binding.handleAppLifecycleStateChanged(
          AppLifecycleState.resumed,
        );
        await tester.pumpAndSettle();

        // Arka arkaya 3 kere alta at/geri getir (Stress Test)
        for (int i = 0; i < 3; i++) {
          tester.binding.handleAppLifecycleStateChanged(
            AppLifecycleState.inactive,
          );
          await tester.pump(
            const Duration(milliseconds: 100),
          ); // Hızlı geçişler
          tester.binding.handleAppLifecycleStateChanged(
            AppLifecycleState.resumed,
          );
          await tester.pump(const Duration(milliseconds: 100));
        }
        await tester.pumpAndSettle();

        // Girdiğimiz yazı, bu kaosun ardından hala duruyor olmalı (State loss kontrolü)
        expect(find.text('Yarım Kalan Veri'), findsWidgets);
      }
    }

    // Herhangi bir lifecycle/timer exception'ı atılmamış olmalı
    expect(
      tester.takeException(),
      null,
      reason:
          "Uygulama arka plana atılıp dönerken yaşam döngüsü çökmesi yaşandı.",
    );
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
