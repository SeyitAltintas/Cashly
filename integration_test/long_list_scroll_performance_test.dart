import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:cashly/main.dart' as app;

/// Uzun Liste Aşağı Kaydırma (Scroll) ve Pagination Performans Testi
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Long List Scroll View Performance & Bounds Test', (
    WidgetTester tester,
  ) async {
    app.main();
    await tester.pumpAndSettle();

    // ========== 1. Listelerin Olduğu Ekrana Git ==========
    final giderlerSekmesi = find.text('Giderler');
    if (giderlerSekmesi.evaluate().isNotEmpty) {
      await tester.tap(giderlerSekmesi.first);
      await tester.pumpAndSettle();
    }

    // Sayfada bir Scrollable liste veya ListVew builder var mı
    final listFinder = find.byType(Scrollable);

    if (listFinder.evaluate().isNotEmpty) {
      // ========== 2. Ekranda Aşağıya Doğru Dehşet Verici Hızla Kaydır ==========
      // Bu işlem eğer listenizin child'ları ağır ise "Out of memory" verebilir
      // Veya limit dışına çıkma hatası (Scroll index range out of bounds) patlatır.
      await tester.fling(listFinder.first, const Offset(0, -600), 10000);
      await tester.pumpAndSettle();

      await tester.fling(listFinder.first, const Offset(0, -1000), 10000);
      await tester.pumpAndSettle();

      await tester.fling(listFinder.first, const Offset(0, -800), 10000);
      await tester.pumpAndSettle();

      // ========== 3. Yukarıya (Başa) Hızlıca Geri Çek ==========
      await tester.fling(listFinder.first, const Offset(0, 2000), 10000);
      await tester.pumpAndSettle();

      // Kaydırma bitince Widget Tree (ListView.builder mantığı) ayakta duruyor
      expect(find.byType(MaterialApp), findsOneWidget);
    }
  });
}
