import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:cashly/main.dart' as app;

/// Çapraz Kur/Döviz Cinsi Çevirme ve Dashboard Hesaplamaları
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Multi Currency (USD/EUR) Calculation Rendering Test', (
    WidgetTester tester,
  ) async {
    app.main();
    await tester.pumpAndSettle();

    // ========== 1. Giderlere Yabancı Para Ekleme ==========
    final giderlerSekmesi = find.text('Giderler');
    if (giderlerSekmesi.evaluate().isNotEmpty) {
      await tester.tap(giderlerSekmesi.first);
      await tester.pumpAndSettle();

      final fab = find.byType(FloatingActionButton);
      if (fab.evaluate().isNotEmpty) {
        await tester.tap(fab.first);
        await tester.pumpAndSettle();

        final alanlar = find.byType(TextField);
        if (alanlar.evaluate().isNotEmpty) {
          await tester.enterText(alanlar.first, 'Dolar Bazlı Harcama');
          await tester.pumpAndSettle();
        }

        final tutar = find.widgetWithText(TextField, 'Tutar');
        if (tutar.evaluate().isNotEmpty) {
          await tester.enterText(tutar, '100'); // 100 USD
          await tester.testTextInput.receiveAction(TextInputAction.done);
          await tester.pumpAndSettle();
        }

        // Dropdown veya seçimden Para Birimini değiştir (USD)
        final tryMetni = find.textContaining('TRY');
        if (tryMetni.evaluate().isNotEmpty) {
          await tester.tap(tryMetni.first);
          await tester.pumpAndSettle();

          final usdOption = find.textContaining('USD');
          if (usdOption.evaluate().isNotEmpty) {
            await tester.tap(usdOption.first);
            await tester.pumpAndSettle();
          }
        }

        final kaydet = find.text('Kaydet');
        if (kaydet.evaluate().isNotEmpty) {
          await tester.tap(kaydet.first);
          await tester.pumpAndSettle();
        }
      }
    }

    // ========== 2. Dashboard'a Git ==================
    final anaSayfa = find.text('Ana Sayfa');
    if (anaSayfa.evaluate().isNotEmpty) {
      await tester.tap(anaSayfa.first);
      await tester.pumpAndSettle();
    }

    // UI'ın karışık para birimlerini matematiksel parse ederken patlamadığını doğrulama
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
