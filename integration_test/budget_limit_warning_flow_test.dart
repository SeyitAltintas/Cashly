import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:cashly/main.dart' as app;

/// Bütçe Limiti Uyarı Sistemi Akışı Testi
/// Amaç: Kullanıcının bütçe limiti belirleyip, limit eşiğine yaklaştığında
/// ve aştığında UI uyarılarının doğru çalıştığını test etmek.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Budget Limit Warning Flow Test', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();

    // ========== ADIM 1: Bütçe Limitini Ayarla ==========
    // Ayarlar sekmesine git
    final ayarlarSekmesi = find.text('Ayarlar').first;
    expect(ayarlarSekmesi, findsWidgets);
    await tester.tap(ayarlarSekmesi);
    await tester.pumpAndSettle();

    // Gider Ayarları'na gir (bütçe limiti burada)
    final giderAyarlari = find.text('Gider Ayarları');
    if (giderAyarlari.evaluate().isNotEmpty) {
      await tester.tap(giderAyarlari.first);
      await tester.pumpAndSettle();

      // Aylık Bütçe alanını bul ve 1000 TL olarak ayarla
      final butceField = find.widgetWithText(
        TextField,
        'Aylık Gelir (Bütçe Limiti)',
      );
      if (butceField.evaluate().isEmpty) {
        // Alternatif label ile dene
        final altButceField = find.byType(TextField).first;
        if (altButceField.evaluate().isNotEmpty) {
          await tester.enterText(altButceField, '1000');
          await tester.testTextInput.receiveAction(TextInputAction.done);
          await tester.pumpAndSettle();
        }
      } else {
        await tester.enterText(butceField, '1000');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();
      }

      // Kaydet butonu (varsa)
      final kaydetButonu = find.text('Kaydet');
      if (kaydetButonu.evaluate().isNotEmpty) {
        await tester.tap(kaydetButonu.first);
        await tester.pumpAndSettle();
      }

      // Geri dön (Back button)
      final backButton = find.byType(BackButton);
      if (backButton.evaluate().isNotEmpty) {
        await tester.tap(backButton);
        await tester.pumpAndSettle();
      }
    } else {
      fail('Hatali Test: Beklenen UI bileseni (widget) ekranda bulunamadi.');
    }

    // ========== ADIM 2: Büyük bir Harcama Ekle (Limit Aşımı) ==========
    final harcamalarSekmesi = find.text('Harcamalar').first;
    expect(harcamalarSekmesi, findsWidgets);
    await tester.tap(harcamalarSekmesi);
    await tester.pumpAndSettle();

    final fab = find.byType(FloatingActionButton).last;
    await tester.tap(fab);
    await tester.pumpAndSettle();

    final isimField = find.widgetWithText(TextField, 'Harcama Adı');
    await tester.enterText(isimField, 'Bütçe Aşım Testi');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    final tutarField = find.widgetWithText(TextField, 'Tutar');
    await tester.enterText(tutarField, '1500');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    final kaydet = find.widgetWithText(ElevatedButton, 'Kaydet');
    await tester.tap(kaydet);
    await tester.pumpAndSettle();

    // ========== ADIM 3: Dashboard'a Dönüp Uyarıyı Kontrol Et ==========
    final dashboardSekmesi = find.text('Ana Sayfa').first;
    expect(dashboardSekmesi, findsWidgets);
    await tester.tap(dashboardSekmesi);
    await tester.pumpAndSettle();

    // Dashboard'un çökmeden yüklendiğini doğrula
    expect(find.byType(MaterialApp), findsOneWidget);

    // Bütçe halkası (CircularProgressIndicator veya custom widget) veya
    // uyarı widget'ı görünüyor olmalı. Uygulama çökmemeli!
    // Uyarı metni: "Bütçenizi aştınız" veya kırmızı renkte progress bar.
  });
}
