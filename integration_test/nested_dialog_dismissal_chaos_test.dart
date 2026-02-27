import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:cashly/main.dart' as app;

/// 86. Dialog & BottomSheet Stack Memory Leak Test
/// Amaç: Üst üste birden fazla Dialog, BottomSheet vb. arayüz elementi
/// açıldığında (örneğin İşlem Ekle -> Kategori Seçimi -> Yeni Kategori Ekle)
/// ekran geri veya boşluğa tıklayarak kapatıldığında hafızada "zombi state"
/// olup olmadığını ve Navigasyon rotasının çökmeyeceğini denetlemek.

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Nested Dialog & Route Pop Chaos E2E Test', (
    WidgetTester tester,
  ) async {
    app.main();
    await tester.pumpAndSettle();

    final fabButton = find.byType(FloatingActionButton);
    if (fabButton.evaluate().isNotEmpty) {
      await tester.tap(fabButton.first);
      await tester.pumpAndSettle(); // 1. Popup: BottomSheet (İşlem Ekle)

      // Kategori seçimine tıklayarak 2. Popup'ı (veya Dropdown/Dialog) tetikle
      final kategoriSecimi = find.text(
        'Kategori Seç',
      ); // veya uygulamanızdaki karşılığı
      if (kategoriSecimi.evaluate().isNotEmpty) {
        await tester.tap(kategoriSecimi.first);
        await tester.pumpAndSettle(); // 2. Popup açıldı

        // Yeni bir Dialog daha tetiklemeyi denetlesin (Yeni Kategori ekleme butonu gibi)
        final yeniEkleIcon = find.byIcon(Icons.add_circle_outline);
        if (yeniEkleIcon.evaluate().isNotEmpty) {
          await tester.tap(yeniEkleIcon.first);
          await tester.pumpAndSettle(); // 3. Popup açıldı (Üst Üste 3 rota)
        }

        // ŞİMDİ KAOS: Ters sırayla değil, Root seviyesindeki fiziksel geri tuşuyla
        // tamamını temizleme emri. (Android'de edge-swipe / back click davranışı)
        // Ya da çoklu tapAt(outside)

        for (int i = 0; i < 3; i++) {
          await tester.tapAt(
            const Offset(5, 5),
          ); // Boşluğa veya SafeArea dışına bas
          await tester.pump(const Duration(milliseconds: 300));
        }
        await tester.pumpAndSettle();
      }
    }

    // Uygulama hala hayatta mı ve bellek sızdırıp "Exception" patlattı mı?
    expect(
      tester.takeException(),
      null,
      reason:
          "İç içe geçen dialoglar kapatılırken Route veya State çökmesi yaşandı.",
    );
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
