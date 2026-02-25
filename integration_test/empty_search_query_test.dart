import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:cashly/main.dart' as app;

/// Regex / Arama Barı Geçersiz ve Kaotik Karakter Filtreleme Testi
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Empty/Chaotic Search Query Regex Defense Test', (
    WidgetTester tester,
  ) async {
    app.main();
    await tester.pumpAndSettle();

    final giderlerSekmesi = find.text('Giderler');
    if (giderlerSekmesi.evaluate().isNotEmpty) {
      await tester.tap(giderlerSekmesi.first);
      await tester.pumpAndSettle();

      // Arama ikonuna veya arama çubuğuna tıkla
      final searchIcon = find.byIcon(Icons.search);
      if (searchIcon.evaluate().isNotEmpty) {
        await tester.tap(searchIcon.first);
        await tester.pumpAndSettle();
      }

      final textFields = find.byType(TextField);
      if (textFields.evaluate().isNotEmpty) {
        // SQL Injection veya Regex Kırıcı tuhaf bir metin gir
        const chaoticText = r"(*%#)![\[\]\]\\\\^^^}{!!";
        await tester.enterText(textFields.first, chaoticText);

        // onChanged/onSubmitted fonksiyonları arka planda çalışıp
        // veritabanı veya Memory üzerinde string taraması başlatır.
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();

        // Uygulamanın String/RegExp Exception fırlatmadığını doğrula.
        expect(find.byType(MaterialApp), findsOneWidget);

        // Temizle (Geri tuşu veya cancel butonu ile)
        final closeIcon = find.byIcon(Icons.close);
        final backBtn = find.byType(BackButton);

        if (closeIcon.evaluate().isNotEmpty) {
          await tester.tap(closeIcon.last);
          await tester.pumpAndSettle();
        } else if (backBtn.evaluate().isNotEmpty) {
          await tester.tap(backBtn.first);
          await tester.pumpAndSettle();
        }
      }
    }
  });
}
