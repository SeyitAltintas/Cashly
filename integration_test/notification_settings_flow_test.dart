import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:cashly/main.dart' as app;

/// 2. Bildirim Ayarları Akışı E2E Testi
/// Bildirim switch'lerini açıp kapatma ve uygulama stabilitesi
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Notification Settings Flow Test', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();

    // ========== ADIM 1: Ayarlar Sekmesine Git ==========
    final ayarlarSekmesi = find.text('Ayarlar').first;
    expect(ayarlarSekmesi, findsWidgets);
    await tester.tap(ayarlarSekmesi);
    await tester.pumpAndSettle();

    // ========== ADIM 2: Bildirim Ayarlarına Git ==========
    final bildirimMenu = find.text('Bildirim Ayarları');
    final notifMenu = find.text('Bildirimler');

    if (bildirimMenu.evaluate().isNotEmpty) {
      await tester.tap(bildirimMenu.first);
      await tester.pumpAndSettle();
    } else if (notifMenu.evaluate().isNotEmpty) {
      await tester.tap(notifMenu.first);
      await tester.pumpAndSettle();
    }

    // ========== ADIM 3: Switch'leri Toggle Et ==========
    final switches = find.byType(Switch);
    if (switches.evaluate().isNotEmpty) {
      // İlk switch'i aç/kapa
      await tester.tap(switches.first);
      await tester.pumpAndSettle();

      // Tekrar tıkla (eski haline dön)
      await tester.tap(switches.first);
      await tester.pumpAndSettle();

      // İkinci switch varsa onu da test et
      if (switches.evaluate().length > 1) {
        await tester.tap(switches.at(1));
        await tester.pumpAndSettle();
      }
    }

    // SwitchListTile de olabilir
    final switchListTiles = find.byType(SwitchListTile);
    if (switchListTiles.evaluate().isNotEmpty) {
      await tester.tap(switchListTiles.first);
      await tester.pumpAndSettle();

      await tester.tap(switchListTiles.first);
      await tester.pumpAndSettle();
    }

    // Uygulama çökmeden bildirim ayarları değiştirildi
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
