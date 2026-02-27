import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:cashly/main.dart' as app;

/// Devasa Miktarlarda Sayıların Taşma (RenderFlex Overflow) Testi
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Massive Numbers UI Overflow Formatting Test', (
    WidgetTester tester,
  ) async {
    app.main();
    await tester.pumpAndSettle();

    final giderlerSekmesi = find.text('Giderler');
    if (giderlerSekmesi.evaluate().isNotEmpty) {
      await tester.tap(giderlerSekmesi.first);
      await tester.pumpAndSettle();

      final fab = find.byType(FloatingActionButton);
      if (fab.evaluate().isNotEmpty) {
        await tester.tap(fab.first);
        await tester.pumpAndSettle();

        // Aciklama
        final textFields = find.byType(TextField);
        if (textFields.evaluate().isNotEmpty) {
          await tester.enterText(textFields.first, 'Milyarder Harcaması');
          await tester.testTextInput.receiveAction(TextInputAction.done);
          await tester.pumpAndSettle();
        }

        // Tutar kısmına devasa bir limit aşımı gönder (1 Milyar)
        final tutar = find.widgetWithText(TextField, 'Tutar');
        if (tutar.evaluate().isNotEmpty) {
          await tester.enterText(tutar, '9999999999.00'); // 9 Milyar
          await tester.testTextInput.receiveAction(TextInputAction.done);
          await tester.pumpAndSettle();
        }

        // Kaydet
        final kaydet = find.text('Kaydet');
        if (kaydet.evaluate().isNotEmpty) {
          await tester.tap(kaydet.first);
          await tester.pumpAndSettle();
        }
      }
    } else {
      fail('Hatali Test: Beklenen UI bileseni (widget) ekranda bulunamadi.');
    }

    // Ana Tabloya Dön (Dashboard'da o devasa sayıyı denerken UI çökmemeli)
    final anaSayfa = find.text('Ana Sayfa');
    if (anaSayfa.evaluate().isNotEmpty) {
      await tester.tap(anaSayfa.first);
      await tester.pumpAndSettle();
    } else {
      fail('Hatali Test: Beklenen UI bileseni (widget) ekranda bulunamadi.');
    }

    // Ekran devrilmedi ve Widget Ağacı hala ayakta!
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
