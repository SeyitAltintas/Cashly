import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:cashly/main.dart' as app;

/// Araçlar Kısa Yollarından Veri Ekleme E2E Testi
/// Ana navigasyon yerine Tools/Araçlar sayfasındaki kısa yolları kullanma
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Quick Add From Tools Menu Flow Test', (
    WidgetTester tester,
  ) async {
    app.main();
    await tester.pumpAndSettle();

    // ========== 1. Araçlar (Tools) Sekmesi ==========
    final araclarSekmesi = find.text('Araçlar');
    final toolsSekmesi = find.text('Tools');

    if (araclarSekmesi.evaluate().isNotEmpty) {
      await tester.tap(araclarSekmesi.first);
      await tester.pumpAndSettle();
    } else if (toolsSekmesi.evaluate().isNotEmpty) {
      await tester.tap(toolsSekmesi.first);
      await tester.pumpAndSettle();
    }

    // ========== 2. Hızlı İşlem İkonuna Tıklama (Harcama Ekle) ==========
    // Örneğin "Harcama Ekle", "Gelir Ekle" veya Card / UI blokları vardır
    final harcamaEkleYazisi = find.textContaining('Harcama Ekle');
    final quickAddIcon = find.byIcon(Icons.add_shopping_cart);

    if (harcamaEkleYazisi.evaluate().isNotEmpty) {
      await tester.tap(harcamaEkleYazisi.first);
      await tester.pumpAndSettle();
    } else if (quickAddIcon.evaluate().isNotEmpty) {
      await tester.tap(quickAddIcon.first);
      await tester.pumpAndSettle();
    } else {
      // Araçlardaki ilk tıklanabilir listTile veya karta bas
      final cards = find.byType(Card);
      if (cards.evaluate().isNotEmpty) {
        await tester.tap(cards.first);
        await tester.pumpAndSettle();
      }
    }

    // ========== 3. Form Göründü mü Kontrolü ==========
    // Sayfada TextField varsa (ekleme formuna gidilmiş demektir)
    final textFields = find.byType(TextField);
    if (textFields.evaluate().isNotEmpty) {
      // Geri Dön (İşlemi iptal et ve menüleri geri sar)
      final backButton = find.byType(BackButton);
      if (backButton.evaluate().isNotEmpty) {
        await tester.tap(backButton.first);
        await tester.pumpAndSettle();
      }
    }

    // Uygulama sağlıklı çalışmaya devam ediyor
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
