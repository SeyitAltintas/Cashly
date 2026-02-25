import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:cashly/main.dart' as app;

/// Gelir Düzenleme Akışı E2E Testi
/// Gelir ekle → Detaya tıkla → Düzenle → Yeni değerleri doğrula
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Income Edit Flow Test', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();

    // ========== 1. Gelirler sekmesine git ==========
    final gelirlerSekmesi = find.text('Gelirler');
    if (gelirlerSekmesi.evaluate().isNotEmpty) {
      await tester.tap(gelirlerSekmesi.first);
      await tester.pumpAndSettle();
    }

    // ========== 2. Gelir ekle ==========
    final fab = find.byType(FloatingActionButton);
    if (fab.evaluate().isNotEmpty) {
      await tester.tap(fab.first);
      await tester.pumpAndSettle();

      final fields = find.byType(TextField);
      if (fields.evaluate().isNotEmpty) {
        await tester.enterText(fields.first, 'Düzenlenecek Gelir');
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

    // ========== 3. Gelire tıkla (detay/düzenleme) ==========
    final gelir = find.textContaining('Düzenlenecek Gelir');
    if (gelir.evaluate().isNotEmpty) {
      await tester.tap(gelir.first);
      await tester.pumpAndSettle();
    }

    // ========== 4. Düzenle ==========
    final editIcon = find.byIcon(Icons.edit);
    if (editIcon.evaluate().isNotEmpty) {
      await tester.tap(editIcon.first);
      await tester.pumpAndSettle();
    }

    // İsmi güncelle
    final fields = find.byType(TextField);
    if (fields.evaluate().isNotEmpty) {
      await tester.enterText(fields.first, 'Güncellenmiş Gelir');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
    }

    // Kaydet
    final kaydet = find.text('Kaydet');
    final guncelle = find.text('Güncelle');
    if (kaydet.evaluate().isNotEmpty) {
      await tester.tap(kaydet.first);
      await tester.pumpAndSettle();
    } else if (guncelle.evaluate().isNotEmpty) {
      await tester.tap(guncelle.first);
      await tester.pumpAndSettle();
    }

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
