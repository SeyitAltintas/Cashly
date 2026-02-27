import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:cashly/main.dart' as app;

/// 10. Ödeme Yöntemi Detayı ve Borç Analizi E2E Testi
/// Kredi kartı detayına girip borç analizini görüntüleme
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Payment Method Detail & Debt Analysis Flow Test', (
    WidgetTester tester,
  ) async {
    app.main();
    await tester.pumpAndSettle();

    // ========== ADIM 1: Hesaplarım / Ödeme Yöntemleri Sayfasına Git ==========
    final hesaplarSekmesi = find.text('Hesaplarım');
    final odemeYontemleri = find.text('Ödeme Yöntemleri');

    if (hesaplarSekmesi.evaluate().isNotEmpty) {
      await tester.tap(hesaplarSekmesi.first);
      await tester.pumpAndSettle();
    } else if (odemeYontemleri.evaluate().isNotEmpty) {
      await tester.tap(odemeYontemleri.first);
      await tester.pumpAndSettle();
    } else {
      fail('Hatali Test: Beklenen UI bileseni (widget) ekranda bulunamadi.');
    }

    // ========== ADIM 2: İlk Ödeme Yöntemine (Kart/Hesap) Tıkla ==========
    final listTiles = find.byType(ListTile);
    final cards = find.byType(Card);

    if (listTiles.evaluate().isNotEmpty) {
      await tester.tap(listTiles.first);
      await tester.pumpAndSettle();
    } else if (cards.evaluate().isNotEmpty) {
      await tester.tap(cards.first);
      await tester.pumpAndSettle();
    } else {
      fail('Hatali Test: Beklenen UI bileseni (widget) ekranda bulunamadi.');
    }

    // ========== ADIM 3: Detay Sayfası Açıldı Mı ==========
    // Detay sayfasında "Bakiye", "Limit", "Borç" gibi bilgiler görünmeli
    expect(find.byType(MaterialApp), findsOneWidget);

    // Borç analizi kartı/bölümü varsa
    final borcAnalizi = find.textContaining('Borç');
    final debtAnalysis = find.textContaining('Debt');

    if (borcAnalizi.evaluate().isNotEmpty) {
      await tester.tap(borcAnalizi.first);
      await tester.pumpAndSettle();
    } else if (debtAnalysis.evaluate().isNotEmpty) {
      await tester.tap(debtAnalysis.first);
      await tester.pumpAndSettle();
    } else {
      fail('Hatali Test: Beklenen UI bileseni (widget) ekranda bulunamadi.');
    }

    // ========== ADIM 4: Geri Dön ==========
    final backButton = find.byType(BackButton);
    if (backButton.evaluate().isNotEmpty) {
      await tester.tap(backButton);
      await tester.pumpAndSettle();
    } else {
      fail('Hatali Test: Beklenen UI bileseni (widget) ekranda bulunamadi.');
    }

    // Uygulama çökmeden borç analizi gezildi
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
