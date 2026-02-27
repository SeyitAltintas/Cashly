import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:cashly/main.dart' as app;

/// 84. Rapid Form Submission & Validation Chaos Test
/// Amaç: Veri ekleme formlarındaki validasyon sistemi hızla zorlandığında
/// (form değerleri uç limitlerdeyken çoklu kaydetme istekleri atıldığında)
/// duplicate verinin ve UI çökmesinin engellenmesi.
/// Risk: Validasyon esnasında state kilitlenmeleri ve geçersiz asenkron veritabanı kayıtları.

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Rapid Form Submission & Validation Chaos E2E Test', (
    WidgetTester tester,
  ) async {
    app.main();
    await tester.pumpAndSettle();

    final fabButton = find.byType(FloatingActionButton);
    if (fabButton.evaluate().isNotEmpty) {
      await tester.tap(fabButton.first);
      await tester.pumpAndSettle();

      // "Kaydet" veya "Ekle" butonunu bulalım
      final saveButtonText = find.text('Kaydet');
      final addButtonText = find.text('Ekle');

      Finder getSubmitBtn() {
        if (saveButtonText.evaluate().isNotEmpty) return saveButtonText.first;
        if (addButtonText.evaluate().isNotEmpty) return addButtonText.first;
        return saveButtonText; // Fallback
      }

      final submitBtn = getSubmitBtn();
      if (submitBtn.evaluate().isNotEmpty) {
        // =========================================================
        // SENARYO 1: Boş (Geçersiz) Formda Rage-Click Save İstekleri
        // Beklenti: Validasyon hatası vermeli ama ASLA çökmemeli
        // =========================================================
        for (int i = 0; i < 8; i++) {
          await tester.tap(submitBtn.first);
          await tester.pump(const Duration(milliseconds: 10)); // Çok hızlı!
        }
        await tester.pumpAndSettle();
        expect(
          tester.takeException(),
          null,
          reason:
              "Boş validasyon sırasında çoklu 'Kaydet' işlemi uygulamayı çökertti.",
        );

        // =========================================================
        // SENARYO 2: Tamsayı Taşması (Integer Overflow) ve Karakter Limiti
        // =========================================================
        final textFields = find.byType(TextField);
        if (textFields.evaluate().isNotEmpty) {
          // İlk inputa (genellikle tutar/fiyat) inanılmaz limitlerde bir veri girelim
          // Float/Double parsing ve veritabanı constraintlerini sarsacak boyut
          await tester.enterText(
            textFields.first,
            '99999999999999999999999999999.99',
          );
          await tester.testTextInput.receiveAction(TextInputAction.done);
          await tester.pumpAndSettle();

          // Tekrar rage click
          for (int i = 0; i < 5; i++) {
            await tester.tap(submitBtn.first);
            await tester.pump(const Duration(milliseconds: 20));
          }
          await tester.pumpAndSettle();
          expect(
            tester.takeException(),
            null,
            reason:
                "Aşırı yüksek numerik değer girişinde kaydet tuşlaması parse/database hatasıyla çöktü.",
          );
        }
      }
    }
  });
}
