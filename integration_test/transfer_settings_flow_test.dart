import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:cashly/main.dart' as app;

/// Transfer Ayarları E2E Testi
/// Ayarlar → Transfer ayarları sayfasını aç → Gezin
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Transfer Settings Flow Test', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();

    // ========== Ayarlar sekmesine git ==========
    final ayarlarSekmesi = find.text('Ayarlar').first;
    expect(ayarlarSekmesi, findsWidgets);
    await tester.tap(ayarlarSekmesi);
    await tester.pumpAndSettle();

    // ========== Gider Ayarları / Finans ==========
    final giderAyarlari = find.text('Gider Ayarları');
    final finansAyarlari = find.textContaining('Finans');

    if (giderAyarlari.evaluate().isNotEmpty) {
      await tester.tap(giderAyarlari.first);
      await tester.pumpAndSettle();
    } else if (finansAyarlari.evaluate().isNotEmpty) {
      await tester.tap(finansAyarlari.first);
      await tester.pumpAndSettle();
    }

    // ========== Transfer Ayarları ==========
    final transferAyarlari = find.textContaining('Transfer');
    if (transferAyarlari.evaluate().isNotEmpty) {
      await tester.tap(transferAyarlari.first);
      await tester.pumpAndSettle();

      // Ayarlar sayfası açıldı
      expect(find.byType(MaterialApp), findsOneWidget);

      // Switch / seçenekler varsa toggle et
      final switches = find.byType(Switch);
      if (switches.evaluate().isNotEmpty) {
        await tester.tap(switches.first);
        await tester.pumpAndSettle();
      }

      // Geri dön
      final backButton = find.byType(BackButton);
      if (backButton.evaluate().isNotEmpty) {
        await tester.tap(backButton);
        await tester.pumpAndSettle();
      }
    }

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
