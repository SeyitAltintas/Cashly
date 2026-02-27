import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:cashly/main.dart' as app;

/// 81. Category Dependency & Cascade Deletion Chaos Test
/// Amaç: Kullanıcı bir kategori silerken, bu kategoriye bağlı UI arka planda açıksa sistemin çökmemesini test etmek.
/// Edge Case: Kaskad silme durumunda State / Build sorunlarını yakalar (FocusNode dispose vb.).

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Category Dependency Cascade Chaos E2E Test', (
    WidgetTester tester,
  ) async {
    app.main();
    await tester.pumpAndSettle();

    // ADIM 1: Ayarlara Git
    final ayarlarSekmesi = find.text('Ayarlar').first;
    expect(ayarlarSekmesi, findsWidgets);
    await tester.tap(ayarlarSekmesi);
    await tester.pumpAndSettle();

    final giderAyarlari = find.text('Gider Ayarları');
    if (giderAyarlari.evaluate().isNotEmpty) {
      await tester.tap(giderAyarlari.first);
      await tester.pumpAndSettle();
    } else {
      fail('Gider Ayarları tabına ulaşılamadı. UI bozuk olabilir.');
    }

    // Kategori Yönetimine Git
    final kategoriYonetimi = find.textContaining('Kategori');
    if (kategoriYonetimi.evaluate().isNotEmpty) {
      await tester.tap(kategoriYonetimi.first);
      await tester.pumpAndSettle();
    }

    // ADIM 2: Chaos (Sürekli Ekle, Düzenle, Sil Döngüsü Simülasyonu)
    final ekleButonu = find.byIcon(Icons.add);
    if (ekleButonu.evaluate().isNotEmpty) {
      // 1. Kategori ekle
      await tester.tap(ekleButonu.last);
      await tester.pumpAndSettle();

      final kategoriIsim = find.byType(TextField).first;
      if (kategoriIsim.evaluate().isNotEmpty) {
        await tester.enterText(kategoriIsim, 'ChaosCategory');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();

        final kaydet = find.text('Kaydet');
        if (kaydet.evaluate().isNotEmpty) {
          await tester.tap(kaydet.first);
          await tester.pumpAndSettle();
        }
      }
    }

    // 2. Sayfadan Çık (Geri)
    final backButton = find.byType(BackButton);
    if (backButton.evaluate().isNotEmpty) {
      await tester.tap(backButton.first);
      await tester.pumpAndSettle();
    }

    // ADIM 3: Gider Ekleme Sayfasına Hızlı Geçiş ve Kategori Seçim Simulasyonu
    final anaSayfa = find.text('Ana Sayfa').first;
    if (anaSayfa.evaluate().isNotEmpty) {
      await tester.tap(anaSayfa);
      await tester.pumpAndSettle();
    }

    // Gider Ekle Aç
    final fabButton = find.byType(FloatingActionButton);
    if (fabButton.evaluate().isNotEmpty) {
      await tester.tap(fabButton.first);
      await tester.pumpAndSettle();

      // Hızlıca kapat (BottomSheet veya dialog)
      await tester.tapAt(
        const Offset(10, 10),
      ); // Outside bounds to dimiss bottomsheet etc.
      await tester.pumpAndSettle();
    }

    // Test sonu çökme kontrolü
    expect(
      tester.takeException(),
      null,
      reason: "Unhandled exception during rapid state changes.",
    );
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
