import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:cashly/main.dart' as app;

/// Tema Değişimi ve Ağır Ekranların (Grafiklerin) Rebuild E2E Testi
/// Dark Mode'a geçiş yapıp Analiz ve Dashboard gibi componentleri yormak
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Theme Toggle & Heavy UI Rebuild Flow Test', (
    WidgetTester tester,
  ) async {
    app.main();
    await tester.pumpAndSettle();

    // ========== 1. Ayarlardan Tema Değiştir ==========
    final ayarlarSekmesi = find.text('Ayarlar').first;
    expect(ayarlarSekmesi, findsWidgets);
    await tester.tap(ayarlarSekmesi);
    await tester.pumpAndSettle();

    final gorunumMenu = find.text('Görünüm');
    final temaMenu = find.text('Tema');

    if (gorunumMenu.evaluate().isNotEmpty) {
      await tester.tap(gorunumMenu.first);
      await tester.pumpAndSettle();
    } else if (temaMenu.evaluate().isNotEmpty) {
      await tester.tap(temaMenu.first);
      await tester.pumpAndSettle();
    } else {
      fail('Hatali Test: Beklenen UI bileseni (widget) ekranda bulunamadi.');
    }

    // Tema Değiştir (ListTile veya Segmented Control veya Switch)
    final karanlikTema = find.textContaining('Karanlık');
    final darkTheme = find.textContaining('Dark');

    if (karanlikTema.evaluate().isNotEmpty) {
      await tester.tap(karanlikTema.first);
      await tester.pumpAndSettle();
    } else if (darkTheme.evaluate().isNotEmpty) {
      await tester.tap(darkTheme.first);
      await tester.pumpAndSettle();
    } else {
      // Bulamazsa switch vardır
      final switches = find.byType(Switch);
      if (switches.evaluate().isNotEmpty) {
        await tester.tap(switches.first);
        await tester.pumpAndSettle();
      } else {
        fail('Hatali Test: Beklenen UI bileseni (widget) ekranda bulunamadi.');
      }
    }

    // Geri Ayarlar Ana Ekrana
    final backButton = find.byType(BackButton);
    while (backButton.evaluate().isNotEmpty) {
      await tester.tap(backButton.first);
      await tester.pumpAndSettle();
    }

    // ========== 2. Analiz Sayfasında Grafikleri Zorla ==========
    final analizSekmesi = find.text('Analiz');
    if (analizSekmesi.evaluate().isNotEmpty) {
      await tester.tap(analizSekmesi.first);
      await tester.pumpAndSettle(
        const Duration(seconds: 1),
      ); // Chart çizimi zaman alabilir
    } else {
      fail('Hatali Test: Beklenen UI bileseni (widget) ekranda bulunamadi.');
    }
    expect(find.byType(MaterialApp), findsOneWidget);

    // ========== 3. Dashboard'a Git ==========
    final anaSayfa = find.text('Ana Sayfa');
    if (anaSayfa.evaluate().isNotEmpty) {
      await tester.tap(anaSayfa.first);
      await tester.pumpAndSettle();
    } else {
      fail('Hatali Test: Beklenen UI bileseni (widget) ekranda bulunamadi.');
    }

    // Komple UI rebuild sonrası çökme yok
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
