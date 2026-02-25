import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:cashly/main.dart' as app;

/// Android Donanım Geri Tuşu (Hardware Back Button) E2E Testi
/// Navigasyonun derinliklerine inip geri tuşuyla çıkmayı simüle eder
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Hardware Back Button Navigation Flow Test', (
    WidgetTester tester,
  ) async {
    app.main();
    await tester.pumpAndSettle();

    // ========== 1. Derin Bir Sayfaya Git (Ayarlar -> Hakkında -> SSS) ==========
    final ayarlarSekmesi = find.text('Ayarlar').first;
    expect(ayarlarSekmesi, findsWidgets);
    await tester.tap(ayarlarSekmesi);
    await tester.pumpAndSettle();

    final hakkindaMenu = find.textContaining('Hakkında');
    if (hakkindaMenu.evaluate().isNotEmpty) {
      await tester.tap(hakkindaMenu.first);
      await tester.pumpAndSettle();

      final sssMenu = find.textContaining('SSS');
      if (sssMenu.evaluate().isNotEmpty) {
        await tester.tap(sssMenu.first);
        await tester.pumpAndSettle();
      }
    }

    // Uygulama çökmedi ve SSS ya da Hakkında sayfasındayız
    expect(find.byType(MaterialApp), findsOneWidget);

    // ========== 2. Donanımsal Geri Tuşunu Simüle Et ==========
    // Android telefonu kullanan birinin "Geri" tuşuna basması
    // Veya iOS'te ekranın solundan sağa swipe yapması
    final dynamic widgetTester = tester;

    // 1. Geri basış (SSS'den Hakkında'ya düşmeli)
    await widgetTester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    // 2. Geri basış (Hakkında'dan Ayarlar'a düşmeli)
    await widgetTester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    // 3. Geri basış (Eğer Ayarlar'daysa Ana menü veya Home Dashboard'a düşmeli)
    // Eğer app kapanmaya çalışırsa (en üst katmansa) yakalaması lazımdır.
    await widgetTester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    // Tüm pop rotalarından sonra uygulamanın beyaz ekran (crash) vermediğini kontrol
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
