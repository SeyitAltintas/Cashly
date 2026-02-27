import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:cashly/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Çöp Kutusu (Geri Dönüşüm) Akışı Testi', (
    WidgetTester tester,
  ) async {
    // 1. Uygulamanın Başlangıcı
    app.main();
    await tester.pumpAndSettle();

    // 2. İşlemsel Olarak İlk (herhangi) bir listeye gidiyoruz -> Örneğin Harcamalar
    final harcamalarSekmesi = find.text('Harcamalar').first;
    if (harcamalarSekmesi.evaluate().isNotEmpty) {
      await tester.tap(harcamalarSekmesi);
      await tester.pumpAndSettle();
    } else {
      fail('Hatali Test: Beklenen UI bileseni (widget) ekranda bulunamadi.');
    }

    // 3. Geçici bir kayıt ekleyip sonrasında "Sileceğiz"
    final fab = find.byType(FloatingActionButton).last;
    if (fab.evaluate().isNotEmpty) {
      await tester.tap(fab);
      await tester.pumpAndSettle();

      final firstField = find.byType(TextField).first;
      if (firstField.evaluate().isNotEmpty) {
        await tester.enterText(firstField, 'Silinip Geri Alınacak Harcama');
      }
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      final tutarField = find.widgetWithText(TextField, 'Tutar');
      if (tutarField.evaluate().isNotEmpty) {
        await tester.enterText(tutarField, '777');
      }
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      final kaydetButonu = find.widgetWithText(ElevatedButton, 'Kaydet');
      if (kaydetButonu.evaluate().isNotEmpty) {
        await tester.tap(kaydetButonu);
        await tester.pumpAndSettle();
      }
    } else {
      fail('Hatali Test: Beklenen UI bileseni (widget) ekranda bulunamadi.');
    }

    // 4. Şimdi listede görünen 'Silinip Geri Alınacak Harcama'yı siliyoruz (Swipe-to-delete ya da Details ekranı üzerinden)
    // Dismissible widgetını test etmek için Offset Swipe simülasyonu yapıyoruz
    final targetWidget = find.textContaining('Silinip Geri Alınacak Harcama');
    expect(targetWidget, findsWidgets); // En azından listeye eklendi mi görelim

    if (targetWidget.evaluate().isNotEmpty) {
      await tester.drag(
        targetWidget.first,
        const Offset(-500.0, 0.0),
      ); // Sola (Sil) kaydır
      await tester.pumpAndSettle();

      // "Geri Al" SnackBar görünürse, süreyi doldurup kapanmasını bekliyoruz.
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // Öğenin Ana Listede gerçekten yok olduğunu teyit ediyoruz.
      expect(
        find.textContaining('Silinip Geri Alınacak Harcama'),
        findsNothing,
      );
    } else {
      fail('Hatali Test: Beklenen UI bileseni (widget) ekranda bulunamadi.');
    }

    // 5. Ayarlar / Çöp Kutusu sekmesini açıyoruz.
    final ayarlarSekmesi = find.text('Ayarlar').first;
    if (ayarlarSekmesi.evaluate().isNotEmpty) {
      await tester.tap(ayarlarSekmesi);
      await tester.pumpAndSettle();
    } else {
      fail('Hatali Test: Beklenen UI bileseni (widget) ekranda bulunamadi.');
    }

    // Uygulamanızın profil kısmındaki "Silinen Öğeler" butonu...
    final silinenOgeSecenegi = find.text('Çöp Kutusu'); // veya 'Silinen Öğeler'
    if (silinenOgeSecenegi.evaluate().isNotEmpty) {
      await tester.tap(silinenOgeSecenegi);
      await tester.pumpAndSettle();

      // 6. Sildiğimiz öğenin bu sayfada olduğunu kontrol ediyoruz
      expect(
        find.textContaining('Silinip Geri Alınacak Harcama'),
        findsWidgets,
      );

      // 7. Geri Yükle işlemi... (Sağa çekerek mi? Tıklayarak Geri yükle butonuna basarak mı?)
      // Farzedelim ki "Tümünü Geri Yükle" FloatingActionButton var
      final geriYukleButton = find.byIcon(
        Icons.restore,
      ); // Tümünü geri alma konsepti
      if (geriYukleButton.evaluate().isNotEmpty) {
        await tester.tap(geriYukleButton);
        await tester.pumpAndSettle();

        // Uyarıyı onayla
        final confirmButton = find.text('Evet');
        if (confirmButton.evaluate().isNotEmpty) {
          await tester.tap(confirmButton);
          await tester.pumpAndSettle();
        }
      }

      // 8. Çöp kutusu klasörü boşaldı mı?
      expect(
        find.textContaining('Silinip Geri Alınacak Harcama'),
        findsNothing,
      );
    } else {
      fail('Hatali Test: Beklenen UI bileseni (widget) ekranda bulunamadi.');
    }
  });
}
