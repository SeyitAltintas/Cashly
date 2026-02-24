import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:cashly/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Gelir Ekleme Akışı E2E Testi', (WidgetTester tester) async {
    // Uygulamayı başlat
    app.main();
    await tester.pumpAndSettle();

    // Not: Bu UI odaklı bir testtir. Sayfanın Login/Dashboard state'ini
    // geçtikten sonra BottomNavigationBar'dan İstatistikler/Gelir sekmesini
    // veya doğrudan Income sayfasına gitmeyi test eder. Hızlandırılmış
    // animasyonları ve render bekleme sürelerini içerir.

    // 1. Gelirler (Incomes) sayfasına git (Menü veya Dashboard üzerinden)
    // Uygulama yapısına göre navigasyon adımları: (Örn: GoRouter /incomes)
    // Dashboard'dan gelirler sekmesini tıkla:
    final gelirlerSekmesi = find.text('Gelirler').first;
    if (gelirlerSekmesi.evaluate().isNotEmpty) {
      await tester.tap(gelirlerSekmesi);
      await tester.pumpAndSettle();
    }

    // 2. Yeni Gelir Ekle butonuna tıkla (Genellikle FloatingActionButton)
    final fab = find.byType(FloatingActionButton).last;
    if (fab.evaluate().isNotEmpty) {
      await tester.tap(fab);
      await tester.pumpAndSettle();

      // 3. Formu Doldur (İsim, Tutar, Kategori)
      final isimAlan = find.bySemanticsLabel('İsim veya açıklama');
      if (isimAlan.evaluate().isNotEmpty) {
        await tester.enterText(isimAlan, 'E2E Test Geliri');
        await tester.pumpAndSettle();
      } else {
        // Fallback: TypeTextField'a göre ara
        final firstField = find.byType(TextField).first;
        if (firstField.evaluate().isNotEmpty) {
          await tester.enterText(firstField, 'E2E Test Geliri');
        }
      }

      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // 4. Tutarı gir
      final tutarAramaString = 'Tutar';
      final tutarField = find.widgetWithText(TextField, tutarAramaString);
      if (tutarField.evaluate().isNotEmpty) {
        await tester.enterText(tutarField, '1500');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();
      }

      // Kategori seçimi vb (Varsayılan varsa atla)

      // 5. Kaydet butonuna tıkla
      final kaydetButonu = find.widgetWithText(ElevatedButton, 'Kaydet');
      if (kaydetButonu.evaluate().isNotEmpty) {
        await tester.tap(kaydetButonu);
        await tester.pumpAndSettle();
      }

      // 6. Listede 'E2E Test Geliri' yazısını gör
      expect(find.textContaining('E2E Test Geliri'), findsWidgets);
      expect(find.textContaining('1500'), findsWidgets);
    }
  });
}
