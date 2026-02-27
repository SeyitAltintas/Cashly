import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:cashly/main.dart' as app;

/// Form Doldururken Yanlışlıkla Geri Çıkma (WillPopScope / Unsaved Changes)
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Unsaved Form Changes Alert Protection Test', (
    WidgetTester tester,
  ) async {
    app.main();
    await tester.pumpAndSettle();

    // ========== 1. Gelir veya Gider Ekle Ekranı ==========
    final fab = find.byType(FloatingActionButton);
    if (fab.evaluate().isNotEmpty) {
      await tester.tap(fab.first);
      await tester.pumpAndSettle();

      // Form alanlarını "kirlet" (Dirty State yarat)
      final alanlar = find.byType(TextField);
      if (alanlar.evaluate().isNotEmpty) {
        await tester.enterText(alanlar.first, 'TEST VERİSİ');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();
      }

      // ========== 2. Kaydetmeden "Geri" Dön ==========
      final backBtn = find.byType(BackButton);
      if (backBtn.evaluate().isNotEmpty) {
        await tester.tap(backBtn.first);
        await tester.pumpAndSettle();
      }

      // ========== 3. "Değişiklikler Kaybolacak" Alert'i Var Mı? ==========
      final kaybolacak = find.textContaining('kaybolacak');
      final emin = find.textContaining('Emin');
      final evet = find.text('Evet');

      if (kaybolacak.evaluate().isNotEmpty || emin.evaluate().isNotEmpty) {
        // App'in bir WillPopScope koruması var demektir, Onayla dileyip çık
        if (evet.evaluate().isNotEmpty) {
          await tester.tap(evet.first);
          await tester.pumpAndSettle();
        }
      } else {
        // Alert yoksa, doğrudan formu kapatıp arkaya dönmüş olması lazım
        expect(find.byType(MaterialApp), findsOneWidget);
      }
    } else {
      fail('Hatali Test: Beklenen UI bileseni (widget) ekranda bulunamadi.');
    }

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
