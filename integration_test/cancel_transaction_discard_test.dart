import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:cashly/main.dart' as app;

/// Formların State Management (Hafıza) Temizleme Kontrolü
/// İptal denen formlara geri dönüldüğünde eski verilerin hayalet kalmaması
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Discard Transaction and Form State Cleanup Flow Test', (
    WidgetTester tester,
  ) async {
    app.main();
    await tester.pumpAndSettle();

    final gelirlerSekmesi = find.text('Gelirler');
    if (gelirlerSekmesi.evaluate().isNotEmpty) {
      await tester.tap(gelirlerSekmesi.first);
      await tester.pumpAndSettle();

      final fab = find.byType(FloatingActionButton);
      if (fab.evaluate().isNotEmpty) {
        await tester.tap(fab.first);
        await tester.pumpAndSettle();

        // ========== 1. Formu Doldur (İz Bırak) ==========
        final field1 = find.byType(TextField).first;
        await tester.enterText(field1, 'HAYALET NOT');

        final tutar = find.widgetWithText(TextField, 'Tutar');
        if (tutar.evaluate().isNotEmpty) {
          await tester.enterText(tutar, '7070');
        }
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();

        // ========== 2. Kaydetmeden İptal Edip Çık ==========
        final backBtn = find.byType(BackButton);
        if (backBtn.evaluate().isNotEmpty) {
          await tester.tap(backBtn.first);
          await tester.pumpAndSettle();

          // Warning Pop-up çıkarsa (WillPopScope) atla
          final evet = find.text('Evet');
          if (evet.evaluate().isNotEmpty) {
            await tester.tap(evet.last);
            await tester.pumpAndSettle();
          }
        }

        // ========== 3. Forma Tekrar Gir ==========
        final fab2 = find.byType(FloatingActionButton);
        if (fab2.evaluate().isNotEmpty) {
          await tester.tap(fab2.first);
          await tester.pumpAndSettle();

          // ========== 4. Hayalet Veri Denetimini Yap ==========
          final stringHayalet = find.textContaining('HAYALET');
          final sayiHayalet = find.textContaining('7070');

          // Textcontroller veya Provider yapısı state cache'i temizlenmemişse burada FAIL yer!
          expect(
            stringHayalet.evaluate().isEmpty,
            isTrue,
            reason: 'İptal edilen verinin String state temizlenmemiş!',
          );
          expect(
            sayiHayalet.evaluate().isEmpty,
            isTrue,
            reason: 'İptal edilen verinin Num state temizlenmemiş!',
          );

          expect(find.byType(MaterialApp), findsOneWidget);
        }
      }
    }
  });
}
