import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:cashly/main.dart' as app;

/// Uzun Açıklama Metni Form ve Kart Taşma (Overflow) E2E Testi
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Expense Note Long Text RenderFlex Limit Test', (
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

        final textFields = find.byType(TextField);
        if (textFields.evaluate().isNotEmpty) {
          // Destansı uzunlukta bir not (TextScale, Word break sınırlarını zorlamak için)
          final destan =
              'Bugün süpermarkete gittik ve binlerce şey aldık, ' * 10;
          await tester.enterText(textFields.first, destan);
          await tester.testTextInput.receiveAction(TextInputAction.done);
          await tester.pumpAndSettle();
        }

        final tutar = find.widgetWithText(TextField, 'Tutar');
        if (tutar.evaluate().isNotEmpty) {
          await tester.enterText(tutar, '500');
          await tester.testTextInput.receiveAction(TextInputAction.done);
          await tester.pumpAndSettle();
        }

        final kaydet = find.text('Kaydet');
        if (kaydet.evaluate().isNotEmpty) {
          await tester.tap(kaydet.first);
          await tester.pumpAndSettle();
        }
      }
    }

    // Listeye döndüğümüzde o uzun kart renderlanacak
    // TextWidget'larında "maxLines: 2, overflow: TextOverflow.ellipsis" kullanıldıysa çökmez.
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
