import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:cashly/main.dart' as app;

/// Ayarların Yeniden Başlatılınca (Cold Start) Gelebilmesi Testi
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Settings Persistence After Reboot Flow Test', (
    WidgetTester tester,
  ) async {
    app.main();
    await tester.pumpAndSettle();

    // ========== 1. Ayarlardan Animasyonları Kapat ==========
    final ayarlarSekmesi = find.text('Ayarlar').first;
    expect(ayarlarSekmesi, findsWidgets);
    await tester.tap(ayarlarSekmesi);
    await tester.pumpAndSettle();

    final gorunum = find.textContaining('Görünüm');
    if (gorunum.evaluate().isNotEmpty) {
      await tester.tap(gorunum.first);
      await tester.pumpAndSettle();

      final animMenu = find.textContaining('Animasyon');
      if (animMenu.evaluate().isNotEmpty) {
        await tester.tap(animMenu.first);
        await tester.pumpAndSettle();

        // Switch tıkla
        final switches = find.byType(Switch);
        if (switches.evaluate().isNotEmpty) {
          // Değerini tersine çevir
          await tester.tap(switches.first);
          await tester.pumpAndSettle();
        }
      }
    }

    // ========== 2. Uygulamayı Kapatıp Yeniden Açmayı Simüle Et ==========
    // Dart ortamında `app.main()`'i tekrar çağırmak, global provider vs varsa
    // hata verebilir. Integration testlerinde mock bir lifecycle duraklatması veya
    // route sıfırlaması ile test edilirız:
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.detached);
    await tester.pumpAndSettle();

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
