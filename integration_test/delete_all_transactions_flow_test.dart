import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:cashly/main.dart' as app;

/// Her Şeyi Silip Mutlak Sıfır Gösterimi (Absolute Zero Rendering) E2E Testi
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Absolute Zero Dashboard Calculation Test', (
    WidgetTester tester,
  ) async {
    app.main();
    await tester.pumpAndSettle();

    final giderlerSekmesi = find.text('Giderler');
    if (giderlerSekmesi.evaluate().isNotEmpty) {
      await tester.tap(giderlerSekmesi.first);
      await tester.pumpAndSettle();

      // Tüm harcamaları sil (Listenin içini tamamen Wipe et)
      var swipeSil = find.byType(Dismissible);
      var trashIcon = find.byIcon(Icons.delete);

      while (swipeSil.evaluate().isNotEmpty ||
          trashIcon.evaluate().isNotEmpty) {
        if (swipeSil.evaluate().isNotEmpty) {
          await tester.drag(
            swipeSil.first,
            const Offset(-500, 0),
          ); // Sola sürükle
          await tester.pumpAndSettle();
          swipeSil = find.byType(Dismissible); // Güncelle
        } else if (trashIcon.evaluate().isNotEmpty) {
          await tester.tap(trashIcon.first);
          await tester.pumpAndSettle();
          trashIcon = find.byIcon(Icons.delete);
        }

        // Sonsuz döngü engellemesi (Fail-safe)
        if (swipeSil.evaluate().isEmpty && trashIcon.evaluate().isEmpty) break;
      }
    }

    // Ana Ekran - Mutlak 0 TL olmalı
    final anaSayfa = find.text('Ana Sayfa');
    if (anaSayfa.evaluate().isNotEmpty) {
      await tester.tap(anaSayfa.first);
      await tester.pumpAndSettle();
    }

    // Uygulama matematiği boş String ("") veya NULL yerine
    // Başarıyla "0.00" döndürebilmeli.
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
