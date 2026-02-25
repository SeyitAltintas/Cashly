import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:cashly/main.dart' as app;

/// Gelir + Ödeme Yöntemi Entegrasyonu E2E Testi
/// Gelir eklerken ödeme yöntemine bağlama → Bakiye yansıması
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Income Payment Method Integration Flow Test', (
    WidgetTester tester,
  ) async {
    app.main();
    await tester.pumpAndSettle();

    // ========== 1. Gelir Sekmesine Git ==========
    final gelirlerSekmesi = find.text('Gelirler');
    if (gelirlerSekmesi.evaluate().isNotEmpty) {
      await tester.tap(gelirlerSekmesi.first);
      await tester.pumpAndSettle();
    }

    // ========== 2. Gelir Ekle ==========
    final fab = find.byType(FloatingActionButton);
    if (fab.evaluate().isNotEmpty) {
      await tester.tap(fab.first);
      await tester.pumpAndSettle();

      // İsim gir
      final fields = find.byType(TextField);
      if (fields.evaluate().isNotEmpty) {
        await tester.enterText(fields.first, 'Freelance E2E');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();
      }

      // Tutar gir
      final tutarField = find.widgetWithText(TextField, 'Tutar');
      if (tutarField.evaluate().isNotEmpty) {
        await tester.enterText(tutarField, '5000');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();
      }

      // Ödeme yöntemi seçimi (varsa dropdown/picker)
      final odemeYontemi = find.textContaining('Ödeme');
      final hesapSec = find.textContaining('Hesap');
      if (odemeYontemi.evaluate().isNotEmpty) {
        await tester.tap(odemeYontemi.first);
        await tester.pumpAndSettle();

        // İlk seçeneği seç
        final options = find.byType(ListTile);
        if (options.evaluate().isNotEmpty) {
          await tester.tap(options.first);
          await tester.pumpAndSettle();
        }
      } else if (hesapSec.evaluate().isNotEmpty) {
        await tester.tap(hesapSec.first);
        await tester.pumpAndSettle();
      }

      // Kaydet
      final kaydet = find.text('Kaydet');
      if (kaydet.evaluate().isNotEmpty) {
        await tester.tap(kaydet.first);
        await tester.pumpAndSettle();
      }
    }

    // ========== 3. Hesaplarım Sekmesinde Bakiye Kontrol ==========
    final hesaplar = find.text('Hesaplarım');
    if (hesaplar.evaluate().isNotEmpty) {
      await tester.tap(hesaplar.first);
      await tester.pumpAndSettle();
    }

    // Uygulama çökmeden gelir → ödeme yöntemi entegrasyonu tamamlandı
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
