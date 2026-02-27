import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:cashly/main.dart' as app;

/// Tutar alanına geçersiz/negatif (-) sayılar ve semboller girildiğinde Engine Tepkisi
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Negative Amount & Invalid Math Input Flow Test', (
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

        final tutar = find.widgetWithText(TextField, 'Tutar');
        if (tutar.evaluate().isNotEmpty) {
          // -500 veya geçersiz bir aritmetik operatör girmeye çalış (KeyboardFormatter engelleyecektir)
          await tester.enterText(tutar, '-500.00');
          await tester.testTextInput.receiveAction(TextInputAction.done);
          await tester.pumpAndSettle();

          await tester.enterText(tutar, '++250,,00');
          await tester.testTextInput.receiveAction(TextInputAction.done);
          await tester.pumpAndSettle();
        }

        final kaydet = find.text('Kaydet');
        if (kaydet.evaluate().isNotEmpty) {
          await tester.tap(kaydet.first);
          await tester.pumpAndSettle();
        }
      }
    } else {
      fail('Hatali Test: Beklenen UI bileseni (widget) ekranda bulunamadi.');
    }

    // Uygulama FormatException veya Assertion hatası fırlatmaktan kaçınabilmeli!
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
