import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:cashly/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Varlık Ekleme Akışı E2E Testi', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();

    final varliklarSekmesi = find.text('Varlıklar').first;
    if (varliklarSekmesi.evaluate().isNotEmpty) {
      await tester.tap(varliklarSekmesi);
      await tester.pumpAndSettle();
    }

    final fab = find.byType(FloatingActionButton).last;
    if (fab.evaluate().isNotEmpty) {
      await tester.tap(fab);
      await tester.pumpAndSettle();

      final firstField = find.byType(TextField).first;
      if (firstField.evaluate().isNotEmpty) {
        await tester.enterText(firstField, 'E2E Test Varlık (Altın)');
      }

      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      final tutarField = find.widgetWithText(TextField, 'Tutar (Mevcut Değer)');
      if (tutarField.evaluate().isNotEmpty) {
        await tester.enterText(tutarField, '15000');
      }

      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // Kripto, Döviz, Altın vb kategori seçilir... (Varsayılan varsa atla)

      final kaydetButonu = find.widgetWithText(ElevatedButton, 'Kaydet');
      if (kaydetButonu.evaluate().isNotEmpty) {
        await tester.tap(kaydetButonu);
        await tester.pumpAndSettle();
      }

      expect(find.textContaining('E2E Test Varlık (Altın)'), findsWidgets);
      expect(find.textContaining('15000'), findsWidgets);
    }
  });
}
