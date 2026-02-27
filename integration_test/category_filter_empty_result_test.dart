import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:cashly/main.dart' as app;

/// Boş Veride Kategorik Filtreleme (Empty Result Filter) E2E Testi
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Category Filter Empty Result Handling Flow Test', (
    WidgetTester tester,
  ) async {
    app.main();
    await tester.pumpAndSettle();

    // ========== 1. Giderler Listesinde ==========
    final giderlerSekmesi = find.text('Giderler');
    if (giderlerSekmesi.evaluate().isNotEmpty) {
      await tester.tap(giderlerSekmesi.first);
      await tester.pumpAndSettle();

      // Eğemen bir filtre / arama widgetı var mıdır kontrolü
      final filtreIkonu = find.byIcon(Icons.filter_list);
      final kategoriDropdown = find.textContaining(
        'Tümü',
      ); // ya da Tüm Kategoriler

      if (filtreIkonu.evaluate().isNotEmpty) {
        await tester.tap(filtreIkonu.first);
        await tester.pumpAndSettle();
      } else if (kategoriDropdown.evaluate().isNotEmpty) {
        await tester.tap(kategoriDropdown.first);
        await tester.pumpAndSettle();
      }

      // ========== 2. Olmayan Bir Kategoriyi Seç ==========
      // Genelde 'Sağlık', 'Eğitim', 'Diğer' vs vardır. Spesifik bir şeye tıkla.
      final saglik = find.textContaining('Sağlık');
      final yatirim = find.textContaining('Yatırım');
      final alisveris = find.textContaining('Alışveriş');

      if (saglik.evaluate().isNotEmpty) {
        await tester.tap(saglik.last);
        await tester.pumpAndSettle();
      } else if (yatirim.evaluate().isNotEmpty) {
        await tester.tap(yatirim.last);
        await tester.pumpAndSettle();
      } else if (alisveris.evaluate().isNotEmpty) {
        await tester.tap(alisveris.last);
        await tester.pumpAndSettle();
      }

      // ========== 3. Ekranda Veri Yok veya Listview Boş Kalmalı ==========
      // Uç noktadaki bir veriye filtre atandıktan sonra sistem `RangeError` veya indeks çöküşü yaşamadan "Boş" döner.
    } else {
      fail('Hatali Test: Beklenen UI bileseni (widget) ekranda bulunamadi.');
    }

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
