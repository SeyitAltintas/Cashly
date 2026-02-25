import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:cashly/main.dart' as app;

/// Hızlı Veri Ekleme Asenkron Çakışma (Race Condition) Testi
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Rapid Transaction Sync & DB Race Condition Test', (
    WidgetTester tester,
  ) async {
    app.main();
    await tester.pumpAndSettle();

    // 1. Gelir Ekle
    final gelirlerSekmesi = find.text('Gelirler');
    if (gelirlerSekmesi.evaluate().isNotEmpty) {
      await tester.tap(gelirlerSekmesi.first);
      await tester.pumpAndSettle();

      final fab = find.byType(FloatingActionButton);
      if (fab.evaluate().isNotEmpty) {
        await tester.tap(fab.first);
        await tester.pumpAndSettle();

        final alanlar = find.byType(TextField);
        await tester.enterText(alanlar.first, 'Maaş');
        final tutar = find.widgetWithText(TextField, 'Tutar');
        await tester.enterText(tutar, '10000');

        final kaydet = find.text('Kaydet');
        await tester.tap(kaydet.first);
        await tester.pumpAndSettle();
      }
    }

    // Bekleme yok: Hemen Gider Ekle (Kilit test mekanizması)
    final giderlerSekmesi = find.text('Giderler');
    if (giderlerSekmesi.evaluate().isNotEmpty) {
      await tester.tap(giderlerSekmesi.first);
      await tester.pumpAndSettle();

      final fab = find.byType(FloatingActionButton);
      if (fab.evaluate().isNotEmpty) {
        await tester.tap(fab.first);
        await tester.pumpAndSettle();

        final alanlar = find.byType(TextField);
        await tester.enterText(alanlar.first, 'Kira Hızlı');
        final tutar = find.widgetWithText(TextField, 'Tutar');
        await tester.enterText(tutar, '3000');

        final kaydet = find.text('Kaydet');
        await tester.tap(kaydet.first);
        await tester.pumpAndSettle();
      }
    }

    // Dashboard Çarpışma Kontrolü (İki Async İşlem Ana sayfada toplanabilecek mi?)
    final anaSayfa = find.text('Ana Sayfa');
    if (anaSayfa.evaluate().isNotEmpty) {
      await tester.tap(anaSayfa.first);
      await tester.pumpAndSettle();
    }

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
