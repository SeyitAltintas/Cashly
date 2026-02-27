import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:cashly/main.dart' as app;

/// Gelir Çöp Kutusu E2E Testi
/// Gelirler sekmesinden çöp kutusuna git, gezin, geri dön
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Income Recycle Bin Flow Test', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();

    // ========== Gelirler sekmesine git ==========
    final gelirlerSekmesi = find.text('Gelirler');
    if (gelirlerSekmesi.evaluate().isNotEmpty) {
      await tester.tap(gelirlerSekmesi.first);
      await tester.pumpAndSettle();
    } else {
      fail('Hatali Test: Beklenen UI bileseni (widget) ekranda bulunamadi.');
    }

    // ========== Ayarlar / Menü ikonu ==========
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

    // ========== Çöp kutusu menüsü ==========
    final copKutusu = find.textContaining('Çöp');
    final recycleBin = find.textContaining('Silinen');

    if (copKutusu.evaluate().isNotEmpty) {
      await tester.tap(copKutusu.first);
      await tester.pumpAndSettle();
    } else if (recycleBin.evaluate().isNotEmpty) {
      await tester.tap(recycleBin.first);
      await tester.pumpAndSettle();
    } else {
      fail('Hatali Test: Beklenen UI bileseni (widget) ekranda bulunamadi.');
    }

    // Sayfa açıldı, çökmedi
    expect(find.byType(MaterialApp), findsOneWidget);

    // Geri dön
    final backButton = find.byType(BackButton);
    if (backButton.evaluate().isNotEmpty) {
      await tester.tap(backButton);
      await tester.pumpAndSettle();
    } else {
      fail('Hatali Test: Beklenen UI bileseni (widget) ekranda bulunamadi.');
    }

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
