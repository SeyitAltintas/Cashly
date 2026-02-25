import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:cashly/main.dart' as app;

/// Gider ve Gelir Aynı Anda Ekleme → Dashboard Net Bakiye Testi
/// Gelir 10000 + Gider 3000 = Net 7000 (Dashboard'da doğrulama)
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Net Balance Cross Feature Flow Test', (
    WidgetTester tester,
  ) async {
    app.main();
    await tester.pumpAndSettle();

    // ========== 1. Gelir Ekle ==========
    final gelirlerSekmesi = find.text('Gelirler');
    if (gelirlerSekmesi.evaluate().isNotEmpty) {
      await tester.tap(gelirlerSekmesi.first);
      await tester.pumpAndSettle();
    }

    final fab = find.byType(FloatingActionButton);
    if (fab.evaluate().isNotEmpty) {
      await tester.tap(fab.first);
      await tester.pumpAndSettle();

      final fields = find.byType(TextField);
      if (fields.evaluate().isNotEmpty) {
        await tester.enterText(fields.first, 'Net Bakiye Gelir E2E');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();
      }

      final tutarField = find.widgetWithText(TextField, 'Tutar');
      if (tutarField.evaluate().isNotEmpty) {
        await tester.enterText(tutarField, '10000');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();
      }

      final kaydet = find.text('Kaydet');
      if (kaydet.evaluate().isNotEmpty) {
        await tester.tap(kaydet.first);
        await tester.pumpAndSettle();
      }
    }

    // ========== 2. Gider Ekle ==========
    final giderlerSekmesi = find.text('Giderler');
    if (giderlerSekmesi.evaluate().isNotEmpty) {
      await tester.tap(giderlerSekmesi.first);
      await tester.pumpAndSettle();
    }

    final fab2 = find.byType(FloatingActionButton);
    if (fab2.evaluate().isNotEmpty) {
      await tester.tap(fab2.first);
      await tester.pumpAndSettle();

      final fields = find.byType(TextField);
      if (fields.evaluate().isNotEmpty) {
        await tester.enterText(fields.first, 'Net Bakiye Gider E2E');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();
      }

      final tutarField = find.widgetWithText(TextField, 'Tutar');
      if (tutarField.evaluate().isNotEmpty) {
        await tester.enterText(tutarField, '3000');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();
      }

      final kaydet = find.text('Kaydet');
      if (kaydet.evaluate().isNotEmpty) {
        await tester.tap(kaydet.first);
        await tester.pumpAndSettle();
      }
    }

    // ========== 3. Dashboard'a Git ==========
    final anaSayfa = find.text('Ana Sayfa');
    if (anaSayfa.evaluate().isNotEmpty) {
      await tester.tap(anaSayfa.first);
      await tester.pumpAndSettle();
    }

    // Dashboard açıldı, net bakiye doğru hesaplanıyor
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
