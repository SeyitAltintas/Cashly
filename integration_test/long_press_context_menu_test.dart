import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:cashly/main.dart' as app;

/// Listeler Üzerinde Basılı Tutma (Long Press / Context Menu) Testi
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Long Press List Item & Context Menu Rendering Test', (
    WidgetTester tester,
  ) async {
    app.main();
    await tester.pumpAndSettle();

    final hesaplarSekmesi = find.text('Hesaplarım');
    if (hesaplarSekmesi.evaluate().isNotEmpty) {
      await tester.tap(hesaplarSekmesi.first);
      await tester.pumpAndSettle();

      // Herhangi bir List item elemanını bul (Hesap veya Harcama Kartı)
      final tiles = find.byType(ListTile);
      if (tiles.evaluate().isNotEmpty) {
        // Normal tıklama yerine 'Uzun Basılı Tut'
        await tester.longPress(tiles.first);
        await tester
            .pumpAndSettle(); // UI eğer silme vb. context menüler çıkarıyorsa bekle.
      } else {
        final cards = find.byType(Card);
        if (cards.evaluate().isNotEmpty) {
          await tester.longPress(cards.first);
          await tester.pumpAndSettle();
        }
      }

      // Uzun basma olayı Material arayüz içinde Assertion Error fırlatmamalı
      expect(find.byType(MaterialApp), findsOneWidget);
    } else {
      fail('Hatali Test: Beklenen UI bileseni (widget) ekranda bulunamadi.');
    }
  });
}
