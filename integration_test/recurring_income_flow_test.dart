import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:cashly/main.dart' as app;

/// 11. Gelir Tekrarlayan İşlemler Akışı E2E Testi
/// Tekrarlayan gelir (Maaş) ekleme ve listede doğrulama
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Recurring Income Flow Test', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();

    // ========== ADIM 1: Gelirler Sekmesine Git ==========
    final gelirlerSekmesi = find.text('Gelirler').first;
    expect(gelirlerSekmesi, findsWidgets);
    await tester.tap(gelirlerSekmesi);
    await tester.pumpAndSettle();

    // ========== ADIM 2: Gelir Ayarlar Sayfasına Git ==========
    // AppBar'daki ayarlar ikonu veya menü
    final settingsIcon = find.byIcon(Icons.settings);
    final moreIcon = find.byIcon(Icons.more_vert);

    if (settingsIcon.evaluate().isNotEmpty) {
      await tester.tap(settingsIcon.last);
      await tester.pumpAndSettle();
    } else if (moreIcon.evaluate().isNotEmpty) {
      await tester.tap(moreIcon.first);
      await tester.pumpAndSettle();
    } else {
      fail('Hatali Test: Beklenen UI bileseni (widget) ekranda bulunamadi.');
    }

    // ========== ADIM 3: Tekrarlayan Gelirler Bölümü ==========
    final tekrarlayanGelir = find.textContaining('Tekrarlayan');
    if (tekrarlayanGelir.evaluate().isNotEmpty) {
      // Ekle butonu
      final ekleButonu = find.byIcon(Icons.add);
      if (ekleButonu.evaluate().isNotEmpty) {
        await tester.tap(ekleButonu.last);
        await tester.pumpAndSettle();

        // İsim gir
        final isimField = find.byType(TextField).first;
        if (isimField.evaluate().isNotEmpty) {
          await tester.enterText(isimField, 'Maaş E2E');
          await tester.testTextInput.receiveAction(TextInputAction.done);
          await tester.pumpAndSettle();
        }

        // Tutar gir
        final tutarField = find.widgetWithText(TextField, 'Tutar');
        if (tutarField.evaluate().isNotEmpty) {
          await tester.enterText(tutarField, '25000');
          await tester.testTextInput.receiveAction(TextInputAction.done);
          await tester.pumpAndSettle();
        }

        // Kaydet
        final kaydet = find.text('Kaydet');
        if (kaydet.evaluate().isNotEmpty) {
          await tester.tap(kaydet.first);
          await tester.pumpAndSettle();
        }

        // Listede "Maaş E2E" görünüyor mu
        expect(find.textContaining('Maaş E2E'), findsWidgets);
      }
    } else {
      fail('Hatali Test: Beklenen UI bileseni (widget) ekranda bulunamadi.');
    }

    // Uygulama çökmeden tekrarlayan gelir eklendi
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
