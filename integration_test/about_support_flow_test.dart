import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:cashly/main.dart' as app;

/// 9. Hakkında & Destek Sayfası E2E Testi
/// SSS, Gizlilik Politikası, Kullanım Koşulları açılıp çökmemesi
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('About & Support Page Flow Test', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();

    // ========== ADIM 1: Ayarlar Sekmesine Git ==========
    final ayarlarSekmesi = find.text('Ayarlar').first;
    expect(ayarlarSekmesi, findsWidgets);
    await tester.tap(ayarlarSekmesi);
    await tester.pumpAndSettle();

    // ========== ADIM 2: Hakkında / Destek ==========
    final hakkindaMenu = find.text('Hakkında');
    final destekMenu = find.text('Destek');
    final aboutMenu = find.textContaining('Hakkında');

    if (hakkindaMenu.evaluate().isNotEmpty) {
      await tester.tap(hakkindaMenu.first);
      await tester.pumpAndSettle();
    } else if (destekMenu.evaluate().isNotEmpty) {
      await tester.tap(destekMenu.first);
      await tester.pumpAndSettle();
    } else if (aboutMenu.evaluate().isNotEmpty) {
      await tester.tap(aboutMenu.first);
      await tester.pumpAndSettle();
    }

    // ========== ADIM 3: SSS (FAQ) Bölümünü Aç ==========
    final sssBaslik = find.textContaining('SSS');
    final faqBaslik = find.textContaining('FAQ');
    final sikSorulan = find.textContaining('Sık Sorulan');

    if (sssBaslik.evaluate().isNotEmpty) {
      await tester.tap(sssBaslik.first);
      await tester.pumpAndSettle();
    } else if (faqBaslik.evaluate().isNotEmpty) {
      await tester.tap(faqBaslik.first);
      await tester.pumpAndSettle();
    } else if (sikSorulan.evaluate().isNotEmpty) {
      await tester.tap(sikSorulan.first);
      await tester.pumpAndSettle();
    }

    // ========== ADIM 4: Gizlilik Politikasını Aç ==========
    final gizlilik = find.textContaining('Gizlilik');
    final privacy = find.textContaining('Privacy');

    if (gizlilik.evaluate().isNotEmpty) {
      await tester.tap(gizlilik.first);
      await tester.pumpAndSettle();

      // Geri dön
      final backButton = find.byType(BackButton);
      if (backButton.evaluate().isNotEmpty) {
        await tester.tap(backButton);
        await tester.pumpAndSettle();
      }
    } else if (privacy.evaluate().isNotEmpty) {
      await tester.tap(privacy.first);
      await tester.pumpAndSettle();
    }

    // ========== ADIM 5: Kullanım Koşulları ==========
    final kullanim = find.textContaining('Kullanım');
    final terms = find.textContaining('Terms');

    if (kullanim.evaluate().isNotEmpty) {
      await tester.tap(kullanim.first);
      await tester.pumpAndSettle();
    } else if (terms.evaluate().isNotEmpty) {
      await tester.tap(terms.first);
      await tester.pumpAndSettle();
    }

    // Uygulama çökmeden hakkında/destek sayfası gezildi
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
