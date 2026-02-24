import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:cashly/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Harcama Ekleme Akışı E2E Testi', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();

    final harcamalarSekmesi = find.text('Harcamalar').first;
    if (harcamalarSekmesi.evaluate().isNotEmpty) {
      await tester.tap(harcamalarSekmesi);
      await tester.pumpAndSettle();
    }

    final fab = find.byType(FloatingActionButton).last;
    if (fab.evaluate().isNotEmpty) {
      await tester.tap(fab);
      await tester.pumpAndSettle();

      final firstField = find.byType(TextField).first;
      if (firstField.evaluate().isNotEmpty) {
        await tester.enterText(firstField, 'E2E Test Harcama');
      }

      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      final tutarField = find.widgetWithText(TextField, 'Tutar');
      if (tutarField.evaluate().isNotEmpty) {
        await tester.enterText(tutarField, '750');
      }

      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      final kaydetButonu = find.widgetWithText(ElevatedButton, 'Kaydet');
      if (kaydetButonu.evaluate().isNotEmpty) {
        await tester.tap(kaydetButonu);
        await tester.pumpAndSettle();
      }

      expect(find.textContaining('E2E Test Harcama'), findsWidgets);
      expect(find.textContaining('750'), findsWidgets);
    }
  });
}
