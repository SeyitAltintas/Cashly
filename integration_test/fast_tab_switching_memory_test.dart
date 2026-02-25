import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:cashly/main.dart' as app;

/// Alt Çubukta (Bottom Nav) Saniyeler İçinde Çok Hızlı Geçiş Stres Testi
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Fast Tab Switching UI Memory Rendering Test', (
    WidgetTester tester,
  ) async {
    app.main();
    await tester.pumpAndSettle();

    // Genellikle 4-5 sekme vardır
    final anaSayfa = find.textContaining('Ana Sayfa');
    final giderler = find.textContaining('Giderler');
    final gelirler = find.textContaining('Gelirler');
    final varliklar = find.textContaining('Varlıklar');
    final hesaplar = find.textContaining('Hesaplarım');

    // ========== Spamlama ============
    // Frame Render'ların henüz bitmeden başka widget tetiklenmesi memory leak veya
    // "Looking up a deactivated widget ancestor" hataları verebilir!

    for (int i = 0; i < 3; i++) {
      if (giderler.evaluate().isNotEmpty) await tester.tap(giderler.last);
      if (gelirler.evaluate().isNotEmpty) await tester.tap(gelirler.last);
      if (varliklar.evaluate().isNotEmpty) await tester.tap(varliklar.last);
      if (hesaplar.evaluate().isNotEmpty) await tester.tap(hesaplar.last);
      if (anaSayfa.evaluate().isNotEmpty) await tester.tap(anaSayfa.last);

      // Hızlıca bas (pumpAndSettle kullanılmaz bilerek)
      await tester.pump(
        const Duration(milliseconds: 100),
      ); // UI engine'i nefessiz bırak
    }

    // ========== Tamamlandıktan sonra stabilize olmasını bekle ==========
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // UI Thread ve Navigation Stack'in hala sağlıklı durduğunun kanıtı:
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
