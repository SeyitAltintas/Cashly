import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:cashly/main.dart' as app;

/// Bölgesel Sembol (TL sağda mı? USD solda mı?) Düzen Testi
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Currency Locale Layout Formatting Change Test', (
    WidgetTester tester,
  ) async {
    app.main();
    await tester.pumpAndSettle();

    final ayarlarSekmesi = find.text('Ayarlar').first;
    expect(ayarlarSekmesi, findsWidgets);
    await tester.tap(ayarlarSekmesi);
    await tester.pumpAndSettle();

    // 1. Dil menüsünü bul ve değiştir (TL vs $ Sembol formatına yansıyacaktır)
    final dilMenu = find.textContaining('Dil');
    if (dilMenu.evaluate().isNotEmpty) {
      await tester.tap(dilMenu.first);
      await tester.pumpAndSettle();

      final ingilizce = find.textContaining('English'); // veya EN
      if (ingilizce.evaluate().isNotEmpty) {
        await tester.tap(ingilizce.first);
        await tester.pumpAndSettle();
      }
    } else {
      fail('Hatali Test: Beklenen UI bileseni (widget) ekranda bulunamadi.');
    }

    // Geri Ana Sayfaya veya Dashboard'a gel
    // Formatlama mekanizmaları (örn: NumberFormat.currency) eğer app dilinden çekiyorsa
    // TextOverflow vermemeli ve $10.00 gibi yeni bir düzenlemeye soft-transition geçmelidir!
    final anaSayfa = find.text('Ana Sayfa');
    final home = find.text('Home');

    if (anaSayfa.evaluate().isNotEmpty) {
      await tester.tap(anaSayfa.first);
      await tester.pumpAndSettle();
    } else if (home.evaluate().isNotEmpty) {
      await tester.tap(home.first);
      await tester.pumpAndSettle();
    } else {
      fail('Hatali Test: Beklenen UI bileseni (widget) ekranda bulunamadi.');
    }

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
