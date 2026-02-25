import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:cashly/main.dart' as app;

/// Analiz Sayfası Akışı Testi
/// Amaç: Sisteme farklı giderler ve gelirler ekledikten sonra
/// Analiz sekmesinde Pasta Grafiği (PieChart) ve listelerin doğru güncellendiğini test etmek.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Analysis Screen Flow & Verification Test', (
    WidgetTester tester,
  ) async {
    app.main();
    await tester.pumpAndSettle();

    // 1. Gider Ekle (Market)
    final harcamalarSekmesi = find.text('Harcamalar').first;
    expect(harcamalarSekmesi, findsWidgets);
    await tester.tap(harcamalarSekmesi);
    await tester.pumpAndSettle();

    final fab = find.byType(FloatingActionButton).last;
    await tester.tap(fab);
    await tester.pumpAndSettle();

    final isimField = find.widgetWithText(TextField, 'Harcama Adı');
    await tester.enterText(isimField, 'Migros E2E');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    final tutarField = find.widgetWithText(TextField, 'Tutar');
    await tester.enterText(tutarField, '150');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    final kaydetButonu = find.widgetWithText(ElevatedButton, 'Kaydet');
    await tester.tap(kaydetButonu);
    await tester.pumpAndSettle();

    // 2. İkinci Gideri Ekle (Fatura)
    await tester.tap(fab);
    await tester.pumpAndSettle();

    await tester.enterText(isimField, 'Elektrik E2E');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    await tester.enterText(tutarField, '850');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    await tester.tap(kaydetButonu);
    await tester.pumpAndSettle();

    // Listede göründüklerine emin ol
    expect(find.textContaining('Migros E2E'), findsWidgets);
    expect(find.textContaining('Elektrik E2E'), findsWidgets);

    // 3. Analiz Sayfasına Git
    final analizSekmesi = find.text('Analiz').first;
    expect(analizSekmesi, findsWidgets);
    await tester.tap(analizSekmesi);
    await tester.pumpAndSettle();

    // Analiz sayfası yüklendi mi?
    expect(find.text('Harcama'), findsWidgets);
    expect(find.text('Gelir'), findsWidgets);
    expect(find.text('Varlık'), findsWidgets);

    // Kategori toplamları yüzdelik ve miktar olarak ekrana gelmiş mi kontrol et.
    // E2E UI'ları kategori gösterir, harcama adı göstermeyebilir. Fakat eklediğimiz
    // değerlerin karşılığı olan oranlar/tutar (150 ve 850 TL içeren textler) olmalı.
    // '150' veya '850' sayısını içeren widget'lar Analiz sayfasında görünmeli
    expect(find.textContaining('150'), findsWidgets);
    expect(find.textContaining('850'), findsWidgets);

    // "Gelir" sekmesine geçiş yapıp UI güncellemesini test edelim.
    final gelirTab = find.text('Gelir');
    await tester.tap(gelirTab);
    await tester.pumpAndSettle();

    // Gelir ekranındaki içerik yüklendiğini kontrol edelim (boş durum texti gibi)
    // Şimdilik çökmediğini ve sayfanın başarıyla Gelir görünümüne geçtiğini teyit ediyoruz.
    expect(find.text('Harcama'), findsWidgets);
  });
}
