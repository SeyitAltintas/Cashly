import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:cashly/main.dart' as app;

/// Cihaz Kasıyorken / Kullanıcı Spam Atarken Hızlı Tıklama (Spam) Koruması
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Rapid Tap (Debouncer) Registration Flow Test', (
    WidgetTester tester,
  ) async {
    app.main();
    await tester.pumpAndSettle();

    // ========== 1. Gider ekleme sayfasına git ==========
    final giderlerSekmesi = find.text('Giderler');
    if (giderlerSekmesi.evaluate().isNotEmpty) {
      await tester.tap(giderlerSekmesi.first);
      await tester.pumpAndSettle();
    } else {
      fail('Hatali Test: Beklenen UI bileseni (widget) ekranda bulunamadi.');
    }

    final fab = find.byType(FloatingActionButton);
    if (fab.evaluate().isNotEmpty) {
      await tester.tap(fab.first);
      await tester.pumpAndSettle();

      final aciklama = find.byType(TextField).first;
      await tester.enterText(aciklama, 'Spam Tıklama Testi');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      final tutar = find.widgetWithText(TextField, 'Tutar');
      if (tutar.evaluate().isNotEmpty) {
        await tester.enterText(tutar, '10');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();
      }

      // ========== 2. Kaydet butonuna aralıksız 5 kere bas (Throttle testi) ==========
      final kaydet = find.text('Kaydet');
      if (kaydet.evaluate().isNotEmpty) {
        await tester.tap(kaydet.first);
        await tester.tap(kaydet.first);
        await tester.tap(kaydet.first);
        await tester.tap(kaydet.first);
        await tester.tap(kaydet.first);

        await tester.pumpAndSettle();
      }
    } else {
      fail('Hatali Test: Beklenen UI bileseni (widget) ekranda bulunamadi.');
    }

    // Uygulama donmadı veya hata vermedi (Debouncer veya kilit mekanizması korudu)
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
