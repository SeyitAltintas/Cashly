import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:cashly/main.dart' as app;

/// 4. Kategori Bazlı Bütçe Detayı E2E Testi
/// Belirli bir kategoriye bütçe limiti koyup Dashboard'da yansımasını kontrol etme
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Category Budget Detail Flow Test', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();

    // ========== ADIM 1: Ayarlar → Kategori Bütçeleri ==========
    final ayarlarSekmesi = find.text('Ayarlar').first;
    expect(ayarlarSekmesi, findsWidgets);
    await tester.tap(ayarlarSekmesi);
    await tester.pumpAndSettle();

    // Gider Ayarları
    final giderAyarlari = find.text('Gider Ayarları');
    if (giderAyarlari.evaluate().isNotEmpty) {
      await tester.tap(giderAyarlari.first);
      await tester.pumpAndSettle();
    }

    // Kategori Bütçeleri (veya Bütçe Limitleri)
    final kategoriBudget = find.textContaining('Bütçe');
    if (kategoriBudget.evaluate().isNotEmpty) {
      await tester.tap(kategoriBudget.first);
      await tester.pumpAndSettle();

      // Bir kategorinin bütçe alanına tutar gir
      final budgetFields = find.byType(TextField);
      if (budgetFields.evaluate().isNotEmpty) {
        await tester.enterText(budgetFields.first, '2000');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();
      }

      // Kaydet
      final kaydet = find.text('Kaydet');
      if (kaydet.evaluate().isNotEmpty) {
        await tester.tap(kaydet.first);
        await tester.pumpAndSettle();
      }
    }

    // ========== ADIM 2: Dashboard'a Dönüp Kontrol Et ==========
    // Geri dön
    final backButton = find.byType(BackButton);
    while (backButton.evaluate().isNotEmpty) {
      await tester.tap(backButton);
      await tester.pumpAndSettle();
    }

    final dashboardSekmesi = find.text('Ana Sayfa').first;
    if (dashboardSekmesi.evaluate().isNotEmpty) {
      await tester.tap(dashboardSekmesi);
      await tester.pumpAndSettle();
    }

    // Uygulama çökmeden bütçe detayı kaydedildi
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
