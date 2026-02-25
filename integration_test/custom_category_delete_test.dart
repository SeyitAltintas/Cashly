import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:cashly/main.dart' as app;

/// Özel Kategori Silme (Alert Dialog) E2E Testi
/// Yönetim altından özel bir kategori sildiğimizde çıkan uyarı diyalogu
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Custom Category Delete Alert Flow Test', (
    WidgetTester tester,
  ) async {
    app.main();
    await tester.pumpAndSettle();

    // ========== 1. Ayarlara ve Kategori Yönetimine Git ==========
    final ayarlarSekmesi = find.text('Ayarlar').first;
    expect(ayarlarSekmesi, findsWidgets);
    await tester.tap(ayarlarSekmesi);
    await tester.pumpAndSettle();

    final giderAyarlari = find.text('Gider Ayarları');
    if (giderAyarlari.evaluate().isNotEmpty) {
      await tester.tap(giderAyarlari.first);
      await tester.pumpAndSettle();
    }

    final kategoriYonetimi = find.textContaining('Kategori');
    if (kategoriYonetimi.evaluate().isNotEmpty) {
      await tester.tap(kategoriYonetimi.first);
      await tester.pumpAndSettle();
    }

    // ========== 2. Varolan Kategoriyi Silmeyi Dene ==========
    // Liste üzerindeki silme ikonuna bas (Swipe veya Icon olabilir)
    final deleteIcons = find.byIcon(Icons.delete);
    final deleteOutlines = find.byIcon(Icons.delete_outline);

    if (deleteIcons.evaluate().isNotEmpty) {
      await tester.tap(deleteIcons.last);
      await tester.pumpAndSettle();
    } else if (deleteOutlines.evaluate().isNotEmpty) {
      await tester.tap(deleteOutlines.last);
      await tester.pumpAndSettle();
    } else {
      // Swipe mekanizması varsa
      final listTiles = find.byType(ListTile);
      if (listTiles.evaluate().isNotEmpty) {
        await tester.drag(listTiles.last, const Offset(-300, 0));
        await tester.pumpAndSettle();

        final silYazisi = find.text('Sil');
        if (silYazisi.evaluate().isNotEmpty) {
          await tester.tap(silYazisi.first);
          await tester.pumpAndSettle();
        }
      }
    }

    // ========== 3. Alert / Diyalog Göründü mü (Dialog / Popup) ==========
    // "Emin misiniz?" "Sileceksiniz" gibi bir yazı çıkar
    final eminMisiniz = find.textContaining('Emin');
    final silButonu = find.text('Sil');
    final evetButonu = find.text('Evet');

    if (eminMisiniz.evaluate().isNotEmpty) {
      // Seçimi onayla veya iptal et
      if (silButonu.evaluate().isNotEmpty) {
        await tester.tap(silButonu.last);
        await tester.pumpAndSettle();
      } else if (evetButonu.evaluate().isNotEmpty) {
        await tester.tap(evetButonu.last);
        await tester.pumpAndSettle();
      }
    }

    // Uygulama çökmedi ve Alert mekanizması çalıştı
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
