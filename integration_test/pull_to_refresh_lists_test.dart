import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:cashly/main.dart' as app;

/// Pull to Refresh (Aşağı Sürükleyerek Yenileme) İterasyon Testi
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Pull to Refresh Drag Iteration Resistance Test', (
    WidgetTester tester,
  ) async {
    app.main();
    await tester.pumpAndSettle();

    final hesaplarSekmesi = find.text('Hesaplarım');
    if (hesaplarSekmesi.evaluate().isNotEmpty) {
      await tester.tap(hesaplarSekmesi.first);
      await tester.pumpAndSettle();

      // Sayfadaki liste (Scrollable view) bul
      final listFinder = find.byType(Scrollable);

      if (listFinder.evaluate().isNotEmpty) {
        // En üstteyken agresifçe "Aşağı Doğru Çekme" hareketi uygula (Pull to refresh)
        // Offset Y pozitif (+): Liste yukarıdan aşağı iner (Yenileme hareketi)
        await tester.drag(listFinder.first, const Offset(0, 400));

        // Yenileme ikonu dönerken sistem Future fonksiyonlarını işler.
        // Bu süre zarfında Exception fırlatıp fırlatmadığı (App Context vs) denetlenir.
        await tester.pumpAndSettle(const Duration(seconds: 2));
      }

      // Yenileme hareketi sistemi ve asenkron veri akışını kırmamalıdır
      expect(find.byType(MaterialApp), findsOneWidget);
    }
  });
}
