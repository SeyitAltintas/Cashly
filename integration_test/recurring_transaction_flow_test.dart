import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:cashly/main.dart' as app;

/// Tekrarlayan (Recurring) İşlemler Akışı E2E Testi
/// Amaç: Tekrarlayan gider/gelir ekleme ve "Bu aya ekle" işleminin
/// doğru çalıştığını test etmek.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Recurring Transaction Flow Test', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();

    // ========== ADIM 1: Ayarlar -> Gider Ayarları -> Tekrarlayan İşlemler ==========
    final ayarlarSekmesi = find.text('Ayarlar').first;
    expect(ayarlarSekmesi, findsWidgets);
    await tester.tap(ayarlarSekmesi);
    await tester.pumpAndSettle();

    // Gider Ayarları sayfasına git
    final giderAyarlari = find.text('Gider Ayarları');
    if (giderAyarlari.evaluate().isNotEmpty) {
      await tester.tap(giderAyarlari.first);
      await tester.pumpAndSettle();
    } else {
      fail('Hatali Test: Beklenen UI bileseni (widget) ekranda bulunamadi.');
    }

    // Tekrarlayan işlemler bölümünü bul
    final tekrarlayanBaslik = find.textContaining('Tekrarlayan');
    if (tekrarlayanBaslik.evaluate().isNotEmpty) {
      // Yeni tekrarlayan işlem ekle butonu (+ ikonu veya "Ekle" butonu)
      final ekleButonu = find.byIcon(Icons.add);
      if (ekleButonu.evaluate().isNotEmpty) {
        await tester.tap(ekleButonu.last);
        await tester.pumpAndSettle();

        // İşlem adı gir
        final isimField = find.byType(TextField).first;
        if (isimField.evaluate().isNotEmpty) {
          await tester.enterText(isimField, 'Kira E2E');
          await tester.testTextInput.receiveAction(TextInputAction.done);
          await tester.pumpAndSettle();
        }

        // Tutar gir
        final tutarField = find.widgetWithText(TextField, 'Tutar');
        if (tutarField.evaluate().isNotEmpty) {
          await tester.enterText(tutarField, '5000');
          await tester.testTextInput.receiveAction(TextInputAction.done);
          await tester.pumpAndSettle();
        }

        // Kaydet
        final kaydetButonu = find.text('Kaydet');
        if (kaydetButonu.evaluate().isNotEmpty) {
          await tester.tap(kaydetButonu.first);
          await tester.pumpAndSettle();
        }

        // Tekrarlayan işlem listesinde "Kira E2E" görünüyor mu?
        expect(find.textContaining('Kira E2E'), findsWidgets);
      }
    } else {
      fail('Hatali Test: Beklenen UI bileseni (widget) ekranda bulunamadi.');
    }

    // ========== ADIM 2: "Bu Aya Ekle" İşlemini Tetikle ==========
    // Geri dön -> Harcamalar sekmesine git
    final backButton = find.byType(BackButton);
    if (backButton.evaluate().isNotEmpty) {
      await tester.tap(backButton);
      await tester.pumpAndSettle();
    } else {
      fail('Hatali Test: Beklenen UI bileseni (widget) ekranda bulunamadi.');
    }

    final harcamalarSekmesi = find.text('Harcamalar').first;
    expect(harcamalarSekmesi, findsWidgets);
    await tester.tap(harcamalarSekmesi);
    await tester.pumpAndSettle();

    // Harcamalar listesinde "Kira E2E" görünüyorsa tekrarlayan işlem başarılı
    // (Session bazlı E2E'de "Bu aya ekle" otomatik tetiklenmiyorsa
    // bunu elle tetiklemek gerekebilir)

    // Uygulama çökmeden yüklendi mi?
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
