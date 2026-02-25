import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:cashly/main.dart' as app;

/// 3. Kategori Yönetimi Akışı E2E Testi
/// Yeni kategori ekleme → Harcamada kullanma → Doğrulama
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Category Management Flow Test', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();

    // ========== ADIM 1: Ayarlar → Gider Ayarları → Kategori Yönetimi ==========
    final ayarlarSekmesi = find.text('Ayarlar').first;
    expect(ayarlarSekmesi, findsWidgets);
    await tester.tap(ayarlarSekmesi);
    await tester.pumpAndSettle();

    final giderAyarlari = find.text('Gider Ayarları');
    if (giderAyarlari.evaluate().isNotEmpty) {
      await tester.tap(giderAyarlari.first);
      await tester.pumpAndSettle();
    }

    // Kategori Yönetimi butonunu bul
    final kategoriYonetimi = find.textContaining('Kategori');
    if (kategoriYonetimi.evaluate().isNotEmpty) {
      await tester.tap(kategoriYonetimi.first);
      await tester.pumpAndSettle();
    }

    // ========== ADIM 2: Yeni Kategori Ekle ==========
    final ekleButonu = find.byIcon(Icons.add);
    if (ekleButonu.evaluate().isNotEmpty) {
      await tester.tap(ekleButonu.last);
      await tester.pumpAndSettle();

      // Kategori adı gir (Dialog veya yeni sayfa)
      final kategoriIsim = find.byType(TextField).first;
      if (kategoriIsim.evaluate().isNotEmpty) {
        await tester.enterText(kategoriIsim, 'Hobi E2E');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();
      }

      // Kaydet / Ekle butonu
      final kaydet = find.text('Kaydet');
      final ekle = find.text('Ekle');
      if (kaydet.evaluate().isNotEmpty) {
        await tester.tap(kaydet.first);
        await tester.pumpAndSettle();
      } else if (ekle.evaluate().isNotEmpty) {
        await tester.tap(ekle.first);
        await tester.pumpAndSettle();
      }
    }

    // ========== ADIM 3: Kategori Listesinde "Hobi E2E" Var Mı ==========
    expect(find.textContaining('Hobi E2E'), findsWidgets);

    // Uygulama çökmeden kategori eklendi
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
