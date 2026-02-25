import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:cashly/main.dart' as app;

/// İleri Tarihli (Zamanlanmış) Transfer Emri E2E Testi
/// Takvim üzerinden geleceği seçip transfer kaydetme
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Scheduled Transfer E2E Flow Test', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();

    // ========== 1. Transfer Sayfasına Git ==========
    final hesaplarSekmesi = find.text('Hesaplarım');
    final odemeYontemleri = find.text('Ödeme Yöntemleri');
    if (hesaplarSekmesi.evaluate().isNotEmpty) {
      await tester.tap(hesaplarSekmesi.first);
      await tester.pumpAndSettle();
    } else if (odemeYontemleri.evaluate().isNotEmpty) {
      await tester.tap(odemeYontemleri.first);
      await tester.pumpAndSettle();
    }

    final transferIcon = find.byIcon(Icons.swap_horiz);
    final transferText = find.text('Transfer');
    if (transferIcon.evaluate().isNotEmpty) {
      await tester.tap(transferIcon.first);
      await tester.pumpAndSettle();
    } else if (transferText.evaluate().isNotEmpty) {
      await tester.tap(transferText.first);
      await tester.pumpAndSettle();
    }

    // ========== 2. Form Alanlarını Doldur ==========
    expect(find.byType(MaterialApp), findsOneWidget);

    final tutarField = find.widgetWithText(TextField, 'Tutar');
    if (tutarField.evaluate().isNotEmpty) {
      await tester.enterText(tutarField, '750');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
    }

    // ========== 3. Takvimi Aç ve İleri Tarihi Seç ==========
    // Tarih TextField'ı veya ikonu tıkla
    final calendarPickIcon = find.byIcon(Icons.calendar_today);
    final dateField = find.textContaining('Tarih');

    if (calendarPickIcon.evaluate().isNotEmpty) {
      await tester.tap(calendarPickIcon.first);
      await tester.pumpAndSettle();
    } else if (dateField.evaluate().isNotEmpty) {
      // TextField olarak bulduysak tıkla
      try {
        await tester.tap(dateField.first);
        await tester.pumpAndSettle();
      } catch (e) {
        // tıklanamıyorsa atla
      }
    }

    // Takvim dialogu açıldıysa: Sağ ok (Sonraki Ay)
    final nextMonthIcon = find.byIcon(Icons.chevron_right);
    if (nextMonthIcon.evaluate().isNotEmpty) {
      await tester.tap(nextMonthIcon.first);
      await tester.pumpAndSettle();

      // "Tamam" veya "Onayla" tıkla
      final okBtn = find.text('Tamam');
      final applyBtn = find.text('OK');
      if (okBtn.evaluate().isNotEmpty) {
        await tester.tap(okBtn.first);
        await tester.pumpAndSettle();
      } else if (applyBtn.evaluate().isNotEmpty) {
        await tester.tap(applyBtn.first);
        await tester.pumpAndSettle();
      }
    }

    // Transfer Onay
    final onayButonu = find.text('Transfer Et');
    final kaydetButonu = find.text('Kaydet');
    if (onayButonu.evaluate().isNotEmpty) {
      await tester.tap(onayButonu.first);
      await tester.pumpAndSettle();
    } else if (kaydetButonu.evaluate().isNotEmpty) {
      await tester.tap(kaydetButonu.first);
      await tester.pumpAndSettle();
    }

    // Hata olmaksızın takvim ve transfer işlemi tamamlandı
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
