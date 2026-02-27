import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:cashly/main.dart' as app;

/// Veri Yedekleme ve Dosya Sistemi E2E Testi
/// İzin (Permission) dialogu veya Native I/O sınırlarında kilitlenme
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Export Backup File Operation Integrity Test', (
    WidgetTester tester,
  ) async {
    app.main();
    await tester.pumpAndSettle();

    // ========== 1. Ayarlara ve Veri Yönetimine Git ==========
    final ayarlarSekmesi = find.text('Ayarlar').first;
    expect(ayarlarSekmesi, findsWidgets);
    await tester.tap(ayarlarSekmesi);
    await tester.pumpAndSettle();

    final veriYonetimi = find.textContaining('Veri');
    final yedekle = find.textContaining('Yedekle');

    if (veriYonetimi.evaluate().isNotEmpty) {
      await tester.tap(veriYonetimi.first);
      await tester.pumpAndSettle();

      final dtYedek = find.textContaining('Yedek');
      if (dtYedek.evaluate().isNotEmpty) {
        await tester.tap(dtYedek.first);
        await tester.pumpAndSettle();
      }
    } else if (yedekle.evaluate().isNotEmpty) {
      await tester.tap(yedekle.first);
      await tester.pumpAndSettle();
    } else {
      fail('Hatali Test: Beklenen UI bileseni (widget) ekranda bulunamadi.');
    }

    // ========== 2. Dışa / İçe Aktar Butonlarına Tıkla ==========
    final disaAktar = find.textContaining('Dışa');
    final iceAktar = find.textContaining('İçe');

    // Eğer butonlar varsa tıkla (Bu native file picker açacaktır)
    // Integration test framework native (Android UI) File picker'ı seçemez
    // ama butona basışın uygulamanın Flutter katmanını öldürmediğini teyit edebilir
    if (disaAktar.evaluate().isNotEmpty) {
      // Sadece Tap simülasyonu
      await tester.tap(disaAktar.last);
      // Sistem Dialogu geleceği için 1 saniye bekle
      await tester.pumpAndSettle(const Duration(seconds: 1));
    } else if (iceAktar.evaluate().isNotEmpty) {
      await tester.tap(iceAktar.last);
      await tester.pumpAndSettle(const Duration(seconds: 1));
    } else {
      fail('Hatali Test: Beklenen UI bileseni (widget) ekranda bulunamadi.');
    }

    // Test Runner hala ayakta is "File Platform Channel" bağlantısı sağlıklıdır.
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
