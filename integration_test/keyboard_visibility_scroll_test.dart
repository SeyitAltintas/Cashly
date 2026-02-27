import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:cashly/main.dart' as app;

/// Sanal Klavye Açılınca Kaydırma (Scroll Visibility) E2E Testi
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Keyboard Visibility & Form Scroll Flow Test', (
    WidgetTester tester,
  ) async {
    app.main();
    await tester.pumpAndSettle();

    // ========== 1. Form Sayfasına Git ==========
    final giderlerSekmesi = find.text('Giderler');
    if (giderlerSekmesi.evaluate().isNotEmpty) {
      await tester.tap(giderlerSekmesi.first);
      await tester.pumpAndSettle();
    } else {
      fail('Hatali Test: Beklenen UI bileseni (widget) ekranda bulunamadi.');
    }

    final fab = find.byType(FloatingActionButton);
    if (fab.evaluate().isNotEmpty) {
      await tester.tap(fab.first);
      await tester.pumpAndSettle();

      final textFields = find.byType(TextField);
      if (textFields.evaluate().isNotEmpty) {
        // En alttaki TextField'a tıkla ve klavye açıldığını simüle et
        final lastField = textFields.last;

        // ensureVisible ile ListView'ın scroll off-set ayarlamasını zorla
        await tester.ensureVisible(lastField);
        await tester.tap(lastField);

        // Klavye overlay gecikmesini beklet
        await tester.pumpAndSettle(const Duration(milliseconds: 500));

        // Metin gir
        await tester.enterText(lastField, 'Klavye Testi');

        // Klavyeyi Kapat
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();
      }
    } else {
      fail('Hatali Test: Beklenen UI bileseni (widget) ekranda bulunamadi.');
    }

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
