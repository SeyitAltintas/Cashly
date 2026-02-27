import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:cashly/main.dart' as app;

/// 85. Data Lifecycle Conflict Chaos Test
/// Amaç: Veri okuma (Liste Kaydırma) ve Veri Yazma/Silme işlemleri (UI İterasyonu)
/// aynı anda agresif bir şekilde gerçekleştiğinde (async conflict) uygulamanın yanıtını ölçmek.
/// Risk: 'Unhandled Exception', 'ConcurrentModificationError' tarzı çökmeleri engellemek.

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Data Lifecycle Conflict Chaos E2E Test', (
    WidgetTester tester,
  ) async {
    app.main();
    await tester.pumpAndSettle();

    final listView = find.byType(ListView);
    if (listView.evaluate().isNotEmpty) {
      // =========================================================
      // DÖNGÜ: Agresif Kaydırma Esnasında Rastgele Tıklamalar
      // Amaç: Layout henüz çizilirken (rendering/repainting) farklı
      // gesture detector'ları sarsarak çakışma (conflict) yaratmak
      // =========================================================
      await tester.fling(listView.first, const Offset(0, -400), 800);

      // Liste daha hareket halindeyken click algılatmayı dene
      await tester.tapAt(const Offset(150, 200));
      await tester.pump(const Duration(milliseconds: 30));
      await tester.tapAt(const Offset(100, 300));
      await tester.pump(const Duration(milliseconds: 30));

      // Fling (kaydırma) zıt yöne
      await tester.fling(listView.first, const Offset(0, 400), 800);
      await tester.tapAt(const Offset(200, 400));

      await tester.pumpAndSettle();

      expect(
        tester.takeException(),
        null,
        reason:
            "Liste hareket halindeyken uygulanan asenkron tıklamalar Layout veya State çöküşüne neden oldu.",
      );
    }

    // Tüm kaosun sonunda uygulamanın merkez (root) widget'ı hala yayında olmalı
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
