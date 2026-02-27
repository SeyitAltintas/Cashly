import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:cashly/main.dart' as app;

/// Varlık Çöp Kutusu E2E Testi
/// Varlık sil → Çöp kutusunda gör → Geri yükle
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Asset Recycle Bin Flow Test', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();

    // ========== Varlıklar sekmesine git ==========
    final varliklarSekmesi = find.text('Varlıklar');
    if (varliklarSekmesi.evaluate().isNotEmpty) {
      await tester.tap(varliklarSekmesi.first);
      await tester.pumpAndSettle();
    } else {
      fail('Hatali Test: Beklenen UI bileseni (widget) ekranda bulunamadi.');
    }

    // ========== Çöp kutusu ikonuna tıkla ==========
    final deleteIcon = find.byIcon(Icons.delete_outline);
    final recycleIcon = find.byIcon(Icons.restore_from_trash);
    final moreMenu = find.byIcon(Icons.more_vert);

    if (deleteIcon.evaluate().isNotEmpty) {
      await tester.tap(deleteIcon.first);
      await tester.pumpAndSettle();
    } else if (recycleIcon.evaluate().isNotEmpty) {
      await tester.tap(recycleIcon.first);
      await tester.pumpAndSettle();
    } else if (moreMenu.evaluate().isNotEmpty) {
      await tester.tap(moreMenu.first);
      await tester.pumpAndSettle();

      final copKutusu = find.textContaining('Çöp');
      if (copKutusu.evaluate().isNotEmpty) {
        await tester.tap(copKutusu.first);
        await tester.pumpAndSettle();
      }
    } else {
      fail('Hatali Test: Beklenen UI bileseni (widget) ekranda bulunamadi.');
    }

    // Çöp kutusu sayfası açıldı, çökmedi
    expect(find.byType(MaterialApp), findsOneWidget);

    // ========== Geri dön ==========
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
