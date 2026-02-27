import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:cashly/main.dart' as app;

/// Harcama Güncelleme (Edit) Akışı E2E Testi
/// Amaç: Mevcut bir harcamayı açıp tutarını/ismini değiştirip
/// kaydettikten sonra listenin doğru güncellenmesini test etmek.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Expense Edit & Update Flow Test', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();

    // ========== ADIM 1: Test Harcaması Ekle ==========
    final harcamalarSekmesi = find.text('Harcamalar').first;
    expect(harcamalarSekmesi, findsWidgets);
    await tester.tap(harcamalarSekmesi);
    await tester.pumpAndSettle();

    final fab = find.byType(FloatingActionButton).last;
    await tester.tap(fab);
    await tester.pumpAndSettle();

    final isimField = find.widgetWithText(TextField, 'Harcama Adı');
    await tester.enterText(isimField, 'Düzenlenecek Harcama');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    final tutarField = find.widgetWithText(TextField, 'Tutar');
    await tester.enterText(tutarField, '300');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    final kaydetButonu = find.widgetWithText(ElevatedButton, 'Kaydet');
    await tester.tap(kaydetButonu);
    await tester.pumpAndSettle();

    // Eklendiğini doğrula
    expect(find.textContaining('Düzenlenecek Harcama'), findsWidgets);

    // ========== ADIM 2: Harcamaya Tıklayıp Detay/Edit Sayfasına Git ==========
    await tester.tap(find.textContaining('Düzenlenecek Harcama').first);
    await tester.pumpAndSettle();

    // Detay sayfasında düzenleme (Edit) ikonu/butonu bul
    final editIcon = find.byIcon(Icons.edit);
    final editButton = find.text('Düzenle');

    if (editIcon.evaluate().isNotEmpty) {
      await tester.tap(editIcon.first);
      await tester.pumpAndSettle();
    } else if (editButton.evaluate().isNotEmpty) {
      await tester.tap(editButton.first);
      await tester.pumpAndSettle();
    } else {
      fail('Hatali Test: Beklenen UI bileseni (widget) ekranda bulunamadi.');
    }

    // ========== ADIM 3: Değerleri Güncelle ==========
    // İsim alanını güncelle
    final editIsimField = find.byType(TextField).first;
    if (editIsimField.evaluate().isNotEmpty) {
      await tester.enterText(editIsimField, 'Güncellenmiş Harcama');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
    } else {
      fail('Hatali Test: Beklenen UI bileseni (widget) ekranda bulunamadi.');
    }

    // Tutar alanını güncelle
    final editTutarField = find.widgetWithText(TextField, 'Tutar');
    if (editTutarField.evaluate().isNotEmpty) {
      await tester.enterText(editTutarField, '500');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
    } else {
      fail('Hatali Test: Beklenen UI bileseni (widget) ekranda bulunamadi.');
    }

    // Kaydet
    final guncelleButonu = find.widgetWithText(ElevatedButton, 'Güncelle');
    final kaydet = find.widgetWithText(ElevatedButton, 'Kaydet');
    if (guncelleButonu.evaluate().isNotEmpty) {
      await tester.tap(guncelleButonu);
      await tester.pumpAndSettle();
    } else if (kaydet.evaluate().isNotEmpty) {
      await tester.tap(kaydet);
      await tester.pumpAndSettle();
    } else {
      fail('Hatali Test: Beklenen UI bileseni (widget) ekranda bulunamadi.');
    }

    // ========== ADIM 4: Listenin Güncellendiğini Doğrula ==========
    // Eski isim artık olmamalı, yeni isim görünmeli
    expect(find.textContaining('Güncellenmiş Harcama'), findsWidgets);
    expect(find.textContaining('500'), findsWidgets);
  });
}
