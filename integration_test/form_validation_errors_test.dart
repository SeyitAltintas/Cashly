import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:cashly/main.dart' as app;

/// Form Validasyonu ve Hata Mesajları E2E Testi
/// Boş alanlarla formları kaydetmeye çalışıp uyarıları tetikleme
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Form Validation Errors Flow Test', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();

    // ========== 1. Gider Ekleme Formu ==========
    final giderlerSekmesi = find.text('Giderler');
    if (giderlerSekmesi.evaluate().isNotEmpty) {
      await tester.tap(giderlerSekmesi.first);
      await tester.pumpAndSettle();
    } else {
      fail('Hatali Test: Beklenen UI bileseni (widget) ekranda bulunamadi.');
    }

    final fab = find.byType(FloatingActionButton);
    if (fab.evaluate().isNotEmpty) {
      await tester.tap(fab.first);
      await tester.pumpAndSettle();

      // Hiçbir şey girmeden doğrudan kaydetmeye bas
      final kaydet = find.text('Kaydet');
      if (kaydet.evaluate().isNotEmpty) {
        await tester.tap(kaydet.first);
        await tester.pumpAndSettle();

        // İsim veya Tutar boş uyarısı araması (validator mesajları)
        final zorunluAlan = find.textContaining('zorunlu');
        final giriniz = find.textContaining('girin');
        final bosBirakilamaz = find.textContaining('boş');

        // Uyarı mesajlarından en az biri görünmeli
        expect(
          zorunluAlan.evaluate().isNotEmpty ||
              giriniz.evaluate().isNotEmpty ||
              bosBirakilamaz.evaluate().isNotEmpty,
          isTrue,
          reason: 'Validasyon hatası gösterilmedi!',
        );
      }

      // Geri dön
      final backButton = find.byType(BackButton);
      if (backButton.evaluate().isNotEmpty) {
        await tester.tap(backButton);
        await tester.pumpAndSettle();
      }
    } else {
      fail('Hatali Test: Beklenen UI bileseni (widget) ekranda bulunamadi.');
    }

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
