import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:cashly/main.dart' as app;

/// Grafik Sıfıra Bölme (Empty Chart Division) Hayatta Kalma Testi
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Chart Zero Division Prevention Flow Test', (
    WidgetTester tester,
  ) async {
    app.main();
    await tester.pumpAndSettle();

    // ========== 1. Analiz Sekmesine Geçiş ==========
    final analizSekmesi = find.text('Analiz');
    if (analizSekmesi.evaluate().isNotEmpty) {
      await tester.tap(analizSekmesi.first);

      // Paint (Çizim) Frame'leri renderlanırken çökme hatası "Unhandled Exception" fırlattırır.
      // E2E Testi bu süreyi tanıyarak grafiğin tam render olma stresine sokar.
      await tester.pumpAndSettle(const Duration(seconds: 1));
    }

    // Analiz chartlarında (FLChart vs) "Toplam = 0" ise ValueCalc (Value / Total * 100)
    // NaN (Not A Number) veya Infinity fırlatıp Engine'i yıkabilir.

    // Uygulama Analiz Ekranında tamamen sağlıklı
    expect(find.byType(MaterialApp), findsOneWidget);

    // ========== 2. Grafikte Zaman Aralığı Değiştirme (Geçmiş veya Boş aylar) ==========
    final geriGecmis = find.byIcon(Icons.chevron_left);
    if (geriGecmis.evaluate().isNotEmpty) {
      await tester.tap(geriGecmis.first);
      await tester.pumpAndSettle(const Duration(milliseconds: 500));
    }

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
