import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:cashly/main.dart' as app;

/// 8. Sesli Komutlar Sayfası E2E Testi
/// Sesli asistan ve komut listesi sayfasının açılıp çökmemesini test etme
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Voice Commands Page Flow Test', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();

    // ========== ADIM 1: Ayarlar Sekmesine Git ==========
    final ayarlarSekmesi = find.text('Ayarlar').first;
    expect(ayarlarSekmesi, findsWidgets);
    await tester.tap(ayarlarSekmesi);
    await tester.pumpAndSettle();

    // ========== ADIM 2: Sesli Asistan / Sesli Komutlar ==========
    final sesliAsistan = find.text('Sesli Asistan');
    final sesliKomutlar = find.text('Sesli Komutlar');
    final voiceMenu = find.textContaining('Sesli');

    if (sesliAsistan.evaluate().isNotEmpty) {
      await tester.tap(sesliAsistan.first);
      await tester.pumpAndSettle();
    } else if (sesliKomutlar.evaluate().isNotEmpty) {
      await tester.tap(sesliKomutlar.first);
      await tester.pumpAndSettle();
    } else if (voiceMenu.evaluate().isNotEmpty) {
      await tester.tap(voiceMenu.first);
      await tester.pumpAndSettle();
    } else {
      fail('Hatali Test: Beklenen UI bileseni (widget) ekranda bulunamadi.');
    }

    // ========== ADIM 3: Komut Listesi Görünüyor Mu ==========
    // Sayfada komut örnekleri veya açıklama metinleri olmalı
    // Örn: "harcama ekle", "bütçe kontrol" gibi
    expect(find.byType(MaterialApp), findsOneWidget);

    // ========== ADIM 4: Komut Detayına Tıkla (Varsa) ==========
    final listTiles = find.byType(ListTile);
    if (listTiles.evaluate().isNotEmpty) {
      await tester.tap(listTiles.first);
      await tester.pumpAndSettle();

      // Geri dön
      final backButton = find.byType(BackButton);
      if (backButton.evaluate().isNotEmpty) {
        await tester.tap(backButton);
        await tester.pumpAndSettle();
      }
    } else {
      fail('Hatali Test: Beklenen UI bileseni (widget) ekranda bulunamadi.');
    }

    // Uygulama çökmeden sesli komutlar sayfası gezildi
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
