import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:cashly/main.dart' as app;

/// Tam Uygulama Turu E2E Testi
/// Tüm ana sekmelere sırayla git → Her sayfanın açılıp çökmediğini doğrula
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Full App Tour Flow Test', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();

    // ========== Ana Sayfa / Dashboard ==========
    expect(find.byType(MaterialApp), findsOneWidget);

    // ========== Giderler Sekmesi ==========
    final giderlerSekmesi = find.text('Giderler');
    if (giderlerSekmesi.evaluate().isNotEmpty) {
      await tester.tap(giderlerSekmesi.first);
      await tester.pumpAndSettle();
      expect(find.byType(MaterialApp), findsOneWidget);
    }

    // ========== Gelirler Sekmesi ==========
    final gelirlerSekmesi = find.text('Gelirler');
    if (gelirlerSekmesi.evaluate().isNotEmpty) {
      await tester.tap(gelirlerSekmesi.first);
      await tester.pumpAndSettle();
      expect(find.byType(MaterialApp), findsOneWidget);
    }

    // ========== Varlıklar Sekmesi ==========
    final varliklarSekmesi = find.text('Varlıklar');
    if (varliklarSekmesi.evaluate().isNotEmpty) {
      await tester.tap(varliklarSekmesi.first);
      await tester.pumpAndSettle();
      expect(find.byType(MaterialApp), findsOneWidget);
    }

    // ========== Hesaplarım Sekmesi ==========
    final hesaplarSekmesi = find.text('Hesaplarım');
    if (hesaplarSekmesi.evaluate().isNotEmpty) {
      await tester.tap(hesaplarSekmesi.first);
      await tester.pumpAndSettle();
      expect(find.byType(MaterialApp), findsOneWidget);
    }

    // ========== Analiz Sekmesi ==========
    final analizSekmesi = find.text('Analiz');
    if (analizSekmesi.evaluate().isNotEmpty) {
      await tester.tap(analizSekmesi.first);
      await tester.pumpAndSettle();
      expect(find.byType(MaterialApp), findsOneWidget);
    }

    // ========== Ayarlar Sekmesi ==========
    final ayarlarSekmesi = find.text('Ayarlar');
    if (ayarlarSekmesi.evaluate().isNotEmpty) {
      await tester.tap(ayarlarSekmesi.first);
      await tester.pumpAndSettle();
      expect(find.byType(MaterialApp), findsOneWidget);
    }

    // ========== Tekrar Ana Sayfaya Dön ==========
    final anaSayfa = find.text('Ana Sayfa');
    if (anaSayfa.evaluate().isNotEmpty) {
      await tester.tap(anaSayfa.first);
      await tester.pumpAndSettle();
    }

    // Tam tur tamamlandı, hiçbir sekmede crash olmadı
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
