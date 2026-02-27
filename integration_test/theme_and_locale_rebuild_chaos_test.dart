import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:cashly/main.dart' as app;

/// 89. Theme & Locale Rebuild Chaos Test
/// Amaç: Kullanıcı uygulamada bir BottomSheet, Dialog ya da işlem sayfasındayken
/// (örneğin veri ekleme esnasında) sistemin Gece/Gündüz Modu aniden değiştiğinde
/// (veya uygulama içinden Tema/Dil hızlıca değiştirildiğinde) arayüzde
/// 'Look up a deactivated widget's ancestor' hatası alınıp alınmadığını kontrol etmek.
/// Risk: Widget ağacının (Element Tree) tamamen yeniden oluşturulması sırasında State kayıpları.

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Theme & Locale Rapid Rebuild Chaos E2E Test', (
    WidgetTester tester,
  ) async {
    app.main();
    await tester.pumpAndSettle();

    // =========================================================
    // SENARYO: Ayarlar Sayfasında Tema Değiştirirken Hızlı Geçişler
    // =========================================================
    final ayarlarSekmesi = find.text('Ayarlar');
    if (ayarlarSekmesi.evaluate().isNotEmpty) {
      await tester.tap(ayarlarSekmesi.first);
      await tester.pumpAndSettle();

      Finder gorunumSecenegi = find.textContaining('Görünüm');
      if (gorunumSecenegi.evaluate().isEmpty) {
        gorunumSecenegi = find.textContaining('Tema');
      }
      if (gorunumSecenegi.evaluate().isNotEmpty) {
        await tester.tap(gorunumSecenegi.first);
        await tester.pumpAndSettle();

        // Sistem teması, Karanlık, Aydınlık seçenekleri
        Finder karanlikMod = find.text('Karanlık');
        if (karanlikMod.evaluate().isEmpty) karanlikMod = find.text('Koyu');
        Finder aydinlikMod = find.text('Aydınlık');
        if (aydinlikMod.evaluate().isEmpty) aydinlikMod = find.text('Açık');

        if (karanlikMod.evaluate().isNotEmpty &&
            aydinlikMod.evaluate().isNotEmpty) {
          // SİMÜLASYON: Kullanıcı temalar arası saniyede 10 kez art arda basıp stres atıyor.
          for (int i = 0; i < 6; i++) {
            await tester.tap(karanlikMod.first);
            await tester.pump(
              const Duration(milliseconds: 50),
            ); // Render beklemeden!

            await tester.tap(aydinlikMod.first);
            await tester.pump(const Duration(milliseconds: 50));
          }
          await tester
              .pumpAndSettle(); // Ağacın yeniden derlenmesini ve durulmasını bekle.

          // Hata tespiti
          expect(
            tester.takeException(),
            null,
            reason:
                "Tema (ThemeMode) art arda değiştirilirken Context veya Provider koptu/çöktü.",
          );
        }
      }

      // Geri dön
      final backButton = find.byType(BackButton);
      if (backButton.evaluate().isNotEmpty) {
        await tester.tap(backButton.first);
        await tester.pumpAndSettle();
      }

      // =========================================================
      // SENARYO 2: Dil Seçeneğini Hızla Değiştirmek
      // =========================================================
      Finder dilSecenegi = find.textContaining('Dil');
      if (dilSecenegi.evaluate().isEmpty) {
        dilSecenegi = find.textContaining('Language');
      }
      if (dilSecenegi.evaluate().isNotEmpty) {
        await tester.tap(dilSecenegi.first);
        await tester.pumpAndSettle();

        Finder ingilizce = find.text('English');
        if (ingilizce.evaluate().isEmpty) ingilizce = find.textContaining('EN');
        Finder turkce = find.text('Türkçe');
        if (turkce.evaluate().isEmpty) turkce = find.textContaining('TR');

        if (ingilizce.evaluate().isNotEmpty && turkce.evaluate().isNotEmpty) {
          // Uygulamanın L10N lokasyon dosyalarını yükleyip parse etmesini zorla
          await tester.tap(ingilizce.first);
          await tester.pump(
            const Duration(milliseconds: 100),
          ); // Tam çeviri bitmeden
          await tester.tap(turkce.first);
          await tester.pump(const Duration(milliseconds: 100));
          await tester.tap(ingilizce.first);
          await tester.pumpAndSettle(); // Son kararı bekle

          expect(
            tester.takeException(),
            null,
            reason:
                "Dil aniden değiştirilirken Async çeviri dosyaları çakıştı veya String parse hatası alındı.",
          );
        }
      }
    }

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
