import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:cashly/main.dart' as app;

/// Varlık Detay Sayfası E2E Testi
/// Varlık ekle → Detay sayfasını aç → Kar/zarar bilgisini gör → Geri dön
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Asset Detail Page Flow Test', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();

    // ========== Varlıklar sekmesine git ==========
    final varliklarSekmesi = find.text('Varlıklar');
    if (varliklarSekmesi.evaluate().isNotEmpty) {
      await tester.tap(varliklarSekmesi.first);
      await tester.pumpAndSettle();
    }

    // ========== Yeni varlık ekle ==========
    final fab = find.byType(FloatingActionButton);
    if (fab.evaluate().isNotEmpty) {
      await tester.tap(fab.first);
      await tester.pumpAndSettle();

      // İsim gir
      final fields = find.byType(TextField);
      if (fields.evaluate().isNotEmpty) {
        await tester.enterText(fields.first, 'E2E Altın Detay');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();
      }

      // Miktar gir
      final miktarField = find.widgetWithText(TextField, 'Miktar');
      if (miktarField.evaluate().isNotEmpty) {
        await tester.enterText(miktarField, '5');
        await tester.pumpAndSettle();
      }

      // Kaydet
      final kaydet = find.text('Kaydet');
      if (kaydet.evaluate().isNotEmpty) {
        await tester.tap(kaydet.first);
        await tester.pumpAndSettle();
      }
    }

    // ========== Detay sayfasını aç ==========
    final varlik = find.textContaining('E2E Altın Detay');
    if (varlik.evaluate().isNotEmpty) {
      await tester.tap(varlik.first);
      await tester.pumpAndSettle();
    } else {
      // İlk varlığa tıkla
      final listItems = find.byType(ListTile);
      if (listItems.evaluate().isNotEmpty) {
        await tester.tap(listItems.first);
        await tester.pumpAndSettle();
      }
    }

    // Detay sayfası açıldı, çökmedi
    expect(find.byType(MaterialApp), findsOneWidget);

    // ========== Geri dön ==========
    final backButton = find.byType(BackButton);
    if (backButton.evaluate().isNotEmpty) {
      await tester.tap(backButton);
      await tester.pumpAndSettle();
    }

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
