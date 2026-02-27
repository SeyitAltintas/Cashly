import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:cashly/main.dart' as app;

/// 91. Chart Gesture & CustomPainter Overload Chaos Test
/// Amaç: Analiz ekranlarında yer alan CustomPainter elementlerinin (Pie Chart, Bar Chart vb.)
/// üzerine çoklu-dokunma (multi-touch), kaydırma ve uzun basma (long press)
/// eş zamanlı yapıldığında RenderBox (Render nesnesi) çizicisinin Index sınırlarını
/// (Out of Bounds) veya Koordinat kısıtlarınılaşıp çökmediğini denetlemek.
/// Risk: 'Failed assertion: line bounds >= 0', 'NaN (Not a Number)' çizim hataları.

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Chart CustomPainter Gesture Overload E2E Test', (
    WidgetTester tester,
  ) async {
    app.main();
    await tester.pumpAndSettle();

    // 1. Analiz / İstatistik Sayfasına Git
    Finder analizSekmesi = find.text('Analiz');
    if (analizSekmesi.evaluate().isEmpty) {
      analizSekmesi = find.text('İstatistik');
    }
    if (analizSekmesi.evaluate().isNotEmpty) {
      await tester.tap(analizSekmesi.first);
      await tester.pumpAndSettle();

      // Grafikleri bul (fl_chart kullanıyorsanız PieChart/BarChart tipleri vardır)
      // CustomPainter tiplerini veya direkt Canvas içeren widget'ları arıyoruz.
      final chartWidget = find.byType(CustomPaint);

      if (chartWidget.evaluate().isNotEmpty) {
        final grafik = chartWidget.first;
        final center = tester.getCenter(grafik);

        // =========================================================
        // SİMÜLASYON 1: Grafik Üzerinde Agresif Tıklama
        // Amaç: Tıklama noktalarının (touch events) "Index bulma" mantığını sarsmak
        // =========================================================
        for (int i = 0; i < 5; i++) {
          await tester.tapAt(center.translate(10, 10)); // Merkeze yakın
          await tester.tapAt(center.translate(50, -50)); // Tepeye doğru
          await tester.tapAt(center.translate(-40, 30)); // Sola doğru
          await tester.pump(const Duration(milliseconds: 20));
        }

        // =========================================================
        // SİMÜLASYON 2: Grafik Üzerinde Çapraz Long Press + Swipe
        // Amaç: Tooltip çıkartma mekanizmasının (örneğin üzerine basılı tutunca miktar gösterme)
        // parmak kayarken (dragout) NullPointerException fırlatıp fırlatmadığı
        // =========================================================
        final gesture = await tester.startGesture(center); // Basılı tut
        await tester.pump(
          const Duration(milliseconds: 500),
        ); // Long press süresi

        // Grafiğin dışına doğru sürükle
        await gesture.moveBy(const Offset(150, 200));
        await tester.pump(const Duration(milliseconds: 50));
        await gesture.up(); // Parmağı çek

        await tester.pumpAndSettle();

        // Herhangi bir matematik/çizim/gesture hatası yakalanmamış olmalı
        expect(
          tester.takeException(),
          null,
          reason:
              "Grafik UI bileşeni çoklu veya agresif dokunmaları işleyemedi, CustomPainter veya Gesture çökmesi oluştu.",
        );
      }
    }

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
