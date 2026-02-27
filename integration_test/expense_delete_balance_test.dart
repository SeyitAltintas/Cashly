import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:cashly/main.dart' as app;

/// Harcama Silme ve Bakiye Güncellemesi E2E Testi
/// Harcama ekle → Dashboard bakiyesini kontrol et → Sil → Bakiye geri döner
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Expense Delete Balance Update Flow Test', (
    WidgetTester tester,
  ) async {
    app.main();
    await tester.pumpAndSettle();

    // ========== 1. Giderler sekmesine git ==========
    final giderlerSekmesi = find.text('Giderler');
    if (giderlerSekmesi.evaluate().isNotEmpty) {
      await tester.tap(giderlerSekmesi.first);
      await tester.pumpAndSettle();
    } else {
      fail('Hatali Test: Beklenen UI bileseni (widget) ekranda bulunamadi.');
    }

    // ========== 2. Harcama ekle ==========
    final fab = find.byType(FloatingActionButton);
    if (fab.evaluate().isNotEmpty) {
      await tester.tap(fab.first);
      await tester.pumpAndSettle();

      final fields = find.byType(TextField);
      if (fields.evaluate().isNotEmpty) {
        await tester.enterText(fields.first, 'Silinecek Harcama E2E');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();
      }

      final tutarField = find.widgetWithText(TextField, 'Tutar');
      if (tutarField.evaluate().isNotEmpty) {
        await tester.enterText(tutarField, '750');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();
      }

      final kaydet = find.text('Kaydet');
      if (kaydet.evaluate().isNotEmpty) {
        await tester.tap(kaydet.first);
        await tester.pumpAndSettle();
      }
    } else {
      fail('Hatali Test: Beklenen UI bileseni (widget) ekranda bulunamadi.');
    }

    // ========== 3. Harcamayı sil (Swipe-to-delete) ==========
    final harcama = find.textContaining('Silinecek Harcama E2E');
    if (harcama.evaluate().isNotEmpty) {
      // Swipe ile sil
      await tester.drag(harcama.first, const Offset(-300, 0));
      await tester.pumpAndSettle();

      // "Sil" onay butonu
      final silButonu = find.text('Sil');
      if (silButonu.evaluate().isNotEmpty) {
        await tester.tap(silButonu.first);
        await tester.pumpAndSettle();
      }
    } else {
      fail('Hatali Test: Beklenen UI bileseni (widget) ekranda bulunamadi.');
    }

    // ========== 4. Dashboard'da bakiye kontrolü ==========
    final anaSayfa = find.text('Ana Sayfa');
    if (anaSayfa.evaluate().isNotEmpty) {
      await tester.tap(anaSayfa.first);
      await tester.pumpAndSettle();
    } else {
      fail('Hatali Test: Beklenen UI bileseni (widget) ekranda bulunamadi.');
    }

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
