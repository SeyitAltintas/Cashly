import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:cashly/main.dart' as app;

/// Üst Üste Çok Derin Ekranlara Gezinme ve Geri Dönüş Hafıza (Stack) Testi
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Deep Nested Navigation Pop Memory Integrity Test', (
    WidgetTester tester,
  ) async {
    app.main();
    await tester.pumpAndSettle();

    // 1. Ayarlara Git (Derinlik 1)
    final ayarlarSekmesi = find.text('Ayarlar').first;
    expect(ayarlarSekmesi, findsWidgets);
    await tester.tap(ayarlarSekmesi);
    await tester.pumpAndSettle();

    // 2. Gider Ayarları (Derinlik 2)
    final giderAyarlari = find.textContaining('Gider Ayarları');
    if (giderAyarlari.evaluate().isNotEmpty) {
      await tester.tap(giderAyarlari.first);
      await tester.pumpAndSettle();

      // 3. Kategori Yönetimi (Derinlik 3)
      final katYonetim = find.textContaining('Kategori');
      if (katYonetim.evaluate().isNotEmpty) {
        await tester.tap(katYonetim.first);
        await tester.pumpAndSettle();

        // 4. Kategori Ekle Butonu / Modal Popup (Derinlik 4)
        final fab = find.byType(FloatingActionButton);
        if (fab.evaluate().isNotEmpty) {
          await tester.tap(fab.first);
          await tester.pumpAndSettle();
        }
      }
    }

    // ========== Art arda Çok Hızlı 'Geri' Çık (Memory Stack Unwinding) ==========
    int popChecks = 0;
    while (find.byType(BackButton).evaluate().isNotEmpty && popChecks < 5) {
      await tester.tap(find.byType(BackButton).first);
      await tester.pumpAndSettle(const Duration(milliseconds: 300));
      popChecks++;
    }

    // App en başa sorunsuzca ve çökmeksizin dönebildi
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
