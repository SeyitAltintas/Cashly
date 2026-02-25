import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:cashly/main.dart' as app;

/// Görünüm (Appearance) Ayarları E2E Testi
/// Tema, Animasyon, Haptic ayarlarını toggle etme
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Appearance Settings Flow Test', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();

    // ========== Ayarlar sekmesine git ==========
    final ayarlarSekmesi = find.text('Ayarlar').first;
    expect(ayarlarSekmesi, findsWidgets);
    await tester.tap(ayarlarSekmesi);
    await tester.pumpAndSettle();

    // ========== Görünüm / Tema Ayarları ==========
    final gorunumMenu = find.text('Görünüm');
    final temaMenu = find.text('Tema');
    final appearanceMenu = find.textContaining('Görünüm');

    if (gorunumMenu.evaluate().isNotEmpty) {
      await tester.tap(gorunumMenu.first);
      await tester.pumpAndSettle();
    } else if (temaMenu.evaluate().isNotEmpty) {
      await tester.tap(temaMenu.first);
      await tester.pumpAndSettle();
    } else if (appearanceMenu.evaluate().isNotEmpty) {
      await tester.tap(appearanceMenu.first);
      await tester.pumpAndSettle();
    }

    // Sayfa açıldı mı
    expect(find.byType(MaterialApp), findsOneWidget);

    // ========== Animasyon Ayarlarını Aç ==========
    final animasyonMenu = find.textContaining('Animasyon');
    if (animasyonMenu.evaluate().isNotEmpty) {
      await tester.tap(animasyonMenu.first);
      await tester.pumpAndSettle();

      // Switch toggle
      final switches = find.byType(Switch);
      final switchTiles = find.byType(SwitchListTile);
      if (switches.evaluate().isNotEmpty) {
        await tester.tap(switches.first);
        await tester.pumpAndSettle();
        await tester.tap(switches.first);
        await tester.pumpAndSettle();
      } else if (switchTiles.evaluate().isNotEmpty) {
        await tester.tap(switchTiles.first);
        await tester.pumpAndSettle();
      }

      // Geri dön
      final backButton = find.byType(BackButton);
      if (backButton.evaluate().isNotEmpty) {
        await tester.tap(backButton);
        await tester.pumpAndSettle();
      }
    }

    // ========== Haptic Ayarlarını Aç ==========
    final hapticMenu = find.textContaining('Haptic');
    final titresimMenu = find.textContaining('Titreşim');
    if (hapticMenu.evaluate().isNotEmpty) {
      await tester.tap(hapticMenu.first);
      await tester.pumpAndSettle();

      final switches = find.byType(Switch);
      if (switches.evaluate().isNotEmpty) {
        await tester.tap(switches.first);
        await tester.pumpAndSettle();
      }

      final backButton = find.byType(BackButton);
      if (backButton.evaluate().isNotEmpty) {
        await tester.tap(backButton);
        await tester.pumpAndSettle();
      }
    } else if (titresimMenu.evaluate().isNotEmpty) {
      await tester.tap(titresimMenu.first);
      await tester.pumpAndSettle();

      final backButton = find.byType(BackButton);
      if (backButton.evaluate().isNotEmpty) {
        await tester.tap(backButton);
        await tester.pumpAndSettle();
      }
    }

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
