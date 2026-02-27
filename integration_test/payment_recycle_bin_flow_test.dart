import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:cashly/main.dart' as app;

/// Ödeme Yöntemi Çöp Kutusu E2E Testi
/// Hesaplarım → Çöp kutusunu aç → Sayfa stabil çalışıyor
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Payment Method Recycle Bin Flow Test', (
    WidgetTester tester,
  ) async {
    app.main();
    await tester.pumpAndSettle();

    // ========== Hesaplarım / Ödeme Yöntemleri ==========
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

    // ========== Çöp kutusu ikonuna tıkla ==========
    final deleteIcon = find.byIcon(Icons.delete_outline);
    final moreIcon = find.byIcon(Icons.more_vert);

    if (deleteIcon.evaluate().isNotEmpty) {
      await tester.tap(deleteIcon.first);
      await tester.pumpAndSettle();
    } else if (moreIcon.evaluate().isNotEmpty) {
      await tester.tap(moreIcon.first);
      await tester.pumpAndSettle();

      final copKutusu = find.textContaining('Çöp');
      if (copKutusu.evaluate().isNotEmpty) {
        await tester.tap(copKutusu.first);
        await tester.pumpAndSettle();
      }
    } else {
      fail('Hatali Test: Beklenen UI bileseni (widget) ekranda bulunamadi.');
    }

    expect(find.byType(MaterialApp), findsOneWidget);

    // Geri dön
    final backButton = find.byType(BackButton);
    if (backButton.evaluate().isNotEmpty) {
      await tester.tap(backButton);
      await tester.pumpAndSettle();
    } else {
      fail('Hatali Test: Beklenen UI bileseni (widget) ekranda bulunamadi.');
    }

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
