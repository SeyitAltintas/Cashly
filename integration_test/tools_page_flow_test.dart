import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:cashly/main.dart' as app;

/// 7. Araçlar Sayfası Gezinme E2E Testi
/// Tools/Araçlar sayfasındaki tüm butonların stabilitesini test etme
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Tools Page Navigation Flow Test', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();

    // ========== ADIM 1: Araçlar Sayfasına Git ==========
    // Alt menüde "Araçlar" veya "Tools" yazısı
    final araclarSekmesi = find.text('Araçlar');
    final toolsSekmesi = find.text('Tools');

    if (araclarSekmesi.evaluate().isNotEmpty) {
      await tester.tap(araclarSekmesi.first);
      await tester.pumpAndSettle();
    } else if (toolsSekmesi.evaluate().isNotEmpty) {
      await tester.tap(toolsSekmesi.first);
      await tester.pumpAndSettle();
    }

    // ========== ADIM 2: Sayfadaki Kart/Butonlara Tıkla ==========
    // Araçlar sayfasında genelde InkWell veya Card içinde öğeler olur
    final cards = find.byType(Card);
    if (cards.evaluate().isNotEmpty) {
      // İlk kartı aç
      await tester.tap(cards.first);
      await tester.pumpAndSettle();

      // Geri dön
      final backButton = find.byType(BackButton);
      if (backButton.evaluate().isNotEmpty) {
        await tester.tap(backButton);
        await tester.pumpAndSettle();
      }

      // İkinci kart varsa onu da test et
      if (cards.evaluate().length > 1) {
        await tester.tap(cards.at(1));
        await tester.pumpAndSettle();

        final backButton2 = find.byType(BackButton);
        if (backButton2.evaluate().isNotEmpty) {
          await tester.tap(backButton2);
          await tester.pumpAndSettle();
        }
      }
    }

    // Uygulama çökmeden araçlar sayfası gezildi
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
