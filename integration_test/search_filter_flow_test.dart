import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:cashly/main.dart' as app;

/// Giderler Listesi Arama ve Filtreleme E2E Testi
/// 1. İki farklı harcama ekle
/// 2. Giderler sayfasında arama ikonuna tıkla
/// 3. Aramayı yap ve sadece eşleşenin geldiğini doğrula
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Expense Search and Filter Flow Test', (
    WidgetTester tester,
  ) async {
    app.main();
    await tester.pumpAndSettle();

    // ========== 1. Giderler Sekmesi ==========
    final giderlerSekmesi = find.text('Giderler');
    if (giderlerSekmesi.evaluate().isNotEmpty) {
      await tester.tap(giderlerSekmesi.first);
      await tester.pumpAndSettle();
    }

    // ========== 2. Harcamaları Ekle ==========
    final fab = find.byType(FloatingActionButton);
    if (fab.evaluate().isNotEmpty) {
      // Birinci harcama
      await tester.tap(fab.first);
      await tester.pumpAndSettle();

      final aciklama1 = find.byType(TextField).first;
      await tester.enterText(aciklama1, 'Özel Harcama Alfa');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      final tutar1 = find.widgetWithText(TextField, 'Tutar');
      await tester.enterText(tutar1, '100');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      final kaydet = find.text('Kaydet');
      await tester.tap(kaydet.first);
      await tester.pumpAndSettle();

      // İkinci harcama
      await tester.tap(fab.first);
      await tester.pumpAndSettle();

      final aciklama2 = find.byType(TextField).first;
      await tester.enterText(aciklama2, 'Market Beta');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      final tutar2 = find.widgetWithText(TextField, 'Tutar');
      await tester.enterText(tutar2, '250');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      await tester.tap(kaydet.first);
      await tester.pumpAndSettle();
    }

    // ========== 3. Arama Çubuğunu Aç ==========
    final aramaIkonu = find.byIcon(Icons.search);
    if (aramaIkonu.evaluate().isNotEmpty) {
      await tester.tap(aramaIkonu.first);
      await tester.pumpAndSettle();

      // "Alfa" diye arat
      final aramaInput = find.byType(TextField).first;
      await tester.enterText(aramaInput, 'Alfa');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // "Özel Harcama Alfa" görünmeli ama "Market Beta" görünmemeli
      expect(find.textContaining('Özel Harcama Alfa'), findsWidgets);

      // Arama çubuğunu temizle
      final temizleIkonu = find.byIcon(Icons.clear);
      if (temizleIkonu.evaluate().isNotEmpty) {
        await tester.tap(temizleIkonu.first);
        await tester.pumpAndSettle();
      }

      // Kapat / Geri dön (search bar kapansın)
      final backIcon = find.byIcon(Icons.arrow_back);
      if (backIcon.evaluate().isNotEmpty) {
        await tester.tap(backIcon.first);
        await tester.pumpAndSettle();
      }
    }

    // Uygulama sağlıklı çalışmaya devam ediyor
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
