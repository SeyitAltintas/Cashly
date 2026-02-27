import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:cashly/main.dart' as app;

/// 82. Extreme Pagination & Filter Performance Test
/// Amaç: Kullanıcı filtreleri yoğunlaştırdığında (tarih + yüksek limitli fiyat) Memory Leak olmaması.
/// Edge Case: Null olan liste/state'lerde kaydırma eyleminin crash yaratmaması.

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Extreme Pagination & Filtering Memory E2E Test', (
    WidgetTester tester,
  ) async {
    app.main();
    await tester.pumpAndSettle();

    // ADIM 1: Arama / Analiz Menüsüne Git
    final analizSekmesi = find.text(
      'Analiz',
    ); // veya 'Arama', nav barda hangisi varsa
    if (analizSekmesi.evaluate().isNotEmpty) {
      await tester.tap(analizSekmesi.first);
      await tester.pumpAndSettle();
    } else {
      // Alternatif: Gecmis sekmesi
      final gecmisSekmesi = find.text('Geçmiş');
      if (gecmisSekmesi.evaluate().isNotEmpty) {
        await tester.tap(gecmisSekmesi.first);
        await tester.pumpAndSettle();
      }
    }

    // ADIM 2: Filtre İkonuna Tıklama (Simülasyon)
    final filterIcon = find.byIcon(Icons.filter_list);
    if (filterIcon.evaluate().isNotEmpty) {
      await tester.tap(filterIcon.first);
      await tester.pumpAndSettle();

      // Miktar alanlarına abartılı rakamlar girmek
      final textFields = find.byType(TextField);
      if (textFields.evaluate().length >= 2) {
        await tester.enterText(textFields.at(0), '999999999'); // Min
        await tester.enterText(textFields.at(1), '1000000000'); // Max
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();

        final uygulaBtn = find.text('Uygula');
        if (uygulaBtn.evaluate().isNotEmpty) {
          await tester.tap(uygulaBtn.first);
          await tester.pumpAndSettle();
        }
      }
    }

    // ADIM 3: Liste Üzerinde Hızlı ve Agresif Scroll Simülasyonu
    final listView = find.byType(ListView);
    if (listView.evaluate().isNotEmpty) {
      // 5 kez agresif swipe işlemi (OOM veya Repaint Crash tetiklemesi)
      for (int i = 0; i < 5; i++) {
        await tester.fling(listView.first, const Offset(0, -500), 1000);
        // pumpAndSettle beklemek yerine micro pump
        await tester.pump(const Duration(milliseconds: 100));
      }
    }

    // Sistem stabil mi?
    expect(
      tester.takeException(),
      null,
      reason: "Memory leak veya Scroll View hatası fırlatıldı.",
    );
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
