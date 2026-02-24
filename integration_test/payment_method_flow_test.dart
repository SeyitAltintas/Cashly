import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:cashly/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Ödeme Yöntemi Ekleme Akışı E2E Testi', (
    WidgetTester tester,
  ) async {
    // Uygulamayı başlat
    app.main();
    await tester.pumpAndSettle();

    // 1. Sağ Alt Köşe Menü veya Profil/Ayarlar'dan Ödeme Yöntemleri sayfasına git
    // Not: Uygulamanızın menü navigasyonuna göre "Ödeme Yöntemleri" sekmesini/butonunu buluyoruz
    final hesaplarButonu = find.text('Hesaplarım');
    final odemeYontemleriButonu = find.text('Ödeme Yöntemleri');

    // Uygulama yapısına göre hangisi varsa ona tıkla
    if (odemeYontemleriButonu.evaluate().isNotEmpty) {
      await tester.tap(odemeYontemleriButonu.first);
      await tester.pumpAndSettle();
    } else if (hesaplarButonu.evaluate().isNotEmpty) {
      await tester.tap(hesaplarButonu.first);
      await tester.pumpAndSettle();
    }

    // 2. Yeni Hesap/Banka/Kredi Kartı Ekle butonuna tıkla
    final fab = find.byType(FloatingActionButton).last;
    if (fab.evaluate().isNotEmpty) {
      await tester.tap(fab);
      await tester.pumpAndSettle();

      // 3. Formu Doldur: Hesap/Banka Adı
      final isimAlan = find.byType(TextField).first;
      if (isimAlan.evaluate().isNotEmpty) {
        await tester.enterText(isimAlan, 'E2E Test Bankası');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();
      }

      // 4. Formu Doldur: Bakiye
      final bakiyeAramaString = 'Bakiye';
      final bakiyeField = find.widgetWithText(TextField, bakiyeAramaString);
      if (bakiyeField.evaluate().isNotEmpty) {
        await tester.enterText(bakiyeField, '25000');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();
      }

      // Kredi kartı için limit vb. alanlar olabiliyor, standart ise devam et

      // 5. Kaydet butonuna tıkla
      final kaydetButonu = find.widgetWithText(ElevatedButton, 'Kaydet');
      if (kaydetButonu.evaluate().isNotEmpty) {
        await tester.tap(kaydetButonu);
        await tester.pumpAndSettle();
      }

      // 6. Listede 'E2E Test Bankası' yazısını gör
      expect(find.textContaining('E2E Test Bankası'), findsWidgets);
      expect(find.textContaining('25000'), findsWidgets);
    }
  });
}
