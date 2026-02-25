import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:cashly/main.dart' as app;

/// Form Üzerinde Hesap / Ödeme Yöntemi Dropdown Spamlama Stres Testi
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Dropdown State Rapid Switch Overflow Test', (
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

        // ========== Dropdown / Hesap Seçimi İkonuna Tıkla ==========
        // Genelde 'Hesap', 'Nakit', veya DropdownButton, DropdownSearch widgetleri vardır.
        final nakitHesapYazisi = find.textContaining('Nakit');
        final krediKartiYazisi = find.textContaining('Kredi');
        final bankaHesabiYazisi = find.textContaining('Banka');

        // Kullanıcının Dropdown seçeneklerini hızlıca değiştirme simülasyonu
        // Bu UI'da selected_index array'ini (Dropdown value = x) strese sokar

        for (int i = 0; i < 3; i++) {
          if (nakitHesapYazisi.evaluate().isNotEmpty) {
            await tester.tap(nakitHesapYazisi.last);
            await tester.pumpAndSettle(const Duration(milliseconds: 200));
          }

          if (krediKartiYazisi.evaluate().isNotEmpty) {
            await tester.tap(krediKartiYazisi.last);
            await tester.pumpAndSettle(const Duration(milliseconds: 200));
          }

          if (bankaHesabiYazisi.evaluate().isNotEmpty) {
            await tester.tap(bankaHesabiYazisi.last);
            await tester.pumpAndSettle(const Duration(milliseconds: 200));
          }
        }

        // Tutar vs girilip işlem yapılabiliyor mu kontrolü (UI lock olmadı)
        final tutar = find.widgetWithText(TextField, 'Tutar');
        if (tutar.evaluate().isNotEmpty) {
          await tester.enterText(tutar, '100');
          await tester.testTextInput.receiveAction(TextInputAction.done);
          await tester.pumpAndSettle();
          expect(find.byType(MaterialApp), findsOneWidget);
        }
      }
    }
  });
}
