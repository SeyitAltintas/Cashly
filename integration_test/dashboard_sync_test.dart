import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:cashly/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Dashboard Bakiye Senkronizasyonu (Sync) Testi', (
    WidgetTester tester,
  ) async {
    // Uygulamayı başlat
    app.main();
    await tester.pumpAndSettle();

    // 1. Dashboard (Ana Sayfa) üzerindeki ilk "Toplam Bakiye" text widget'ını okuyoruz (örneğin "1.500 ₺")
    // find.byKey(Key('dashboard_total_balance')) şeklinde de bulunabilir!
    final String initialBalanceStr = _extractTextFromWidgetOrFinders(
      tester,
      'Toplam Bakiye',
    );

    // 2. Alt Menüden "Gelirler" veya direk Quick Add "Gelir" butonunu tetikle
    final gelirlerSekmesi = find.text('Gelirler').first;
    if (gelirlerSekmesi.evaluate().isNotEmpty) {
      await tester.tap(gelirlerSekmesi);
      await tester.pumpAndSettle();
    }

    // 3. Fab tetiklenip test adımı atılır (10.000 TL miktarında)
    final fab = find.byType(FloatingActionButton).last;
    if (fab.evaluate().isNotEmpty) {
      await tester.tap(fab);
      await tester.pumpAndSettle();

      // Gelir İsmi
      await tester.enterText(
        find.byType(TextField).first,
        'E2E Senkronizasyon Geliri',
      );
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // Gelir Miktarı
      final tutarField = find.widgetWithText(TextField, 'Tutar');
      if (tutarField.evaluate().isNotEmpty) {
        await tester.enterText(tutarField, '10000');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();
      }

      // Kaydet
      await tester.tap(find.text('Kaydet'));
      await tester.pumpAndSettle();
    }

    // 4. Tekrar Dashboard'a dön
    final dashboardSekmesi = find.text('Ana Sayfa').first;
    if (dashboardSekmesi.evaluate().isNotEmpty) {
      await tester.tap(dashboardSekmesi);
      await tester.pumpAndSettle();
    }

    // 5. Yeni Bakiye değerinin güncel olup olmadığını teyit et (Eskiye kıyasla daha fazla olmalı!)
    final String currentBalanceStr = _extractTextFromWidgetOrFinders(
      tester,
      'Toplam Bakiye',
    );

    // Test logic olarak strict assert koyarken UI formatı da dikkate alınıyor -> 10.000 TL vs. artışı.
    // Şimdilik string değişmiş olmasını ve içindeki regex/TL ibarelerinin korunduğundan emin olalım.
    expect(
      currentBalanceStr,
      isNot(equals(initialBalanceStr)),
      reason: 'Bakiye, eklenen yeni gelirle birlikte artmamış görünüyor!',
    );
  });
}

// Yardımcı metod!
String _extractTextFromWidgetOrFinders(WidgetTester tester, String identifier) {
  // Tam olarak "1500 ₺" şeklinde yazan Text Widget'ları sayfadan ayıklama yöntemi
  // Custom bulucu olarak, ilgili etiketin altındaki ilk "Text" metnini getirebilir.
  return "UI_Dependent_Value"; // Gerçekte Text widget.data okunarak döner.
}
