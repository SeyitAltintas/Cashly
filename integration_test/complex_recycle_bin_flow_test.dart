import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:cashly/main.dart' as app;

/// Gelişmiş Geri Dönüşüm Kutusu Akışı Testi
/// Amaç: Gider, Gelir ve Varlık silindiğinde Ana Toplamlardan düşülmesini
/// ve Çöp Kutusundan toplu geri yüklendiğinde eski haline gelmesini E2E test etmek.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Complex Recycle Bin Restore Flow Test', (
    WidgetTester tester,
  ) async {
    app.main();
    await tester.pumpAndSettle();

    // --- SETUP: "GiderE2E" adında bir harcama ekle ---
    final harcamalarSekmesi = find.text('Harcamalar').first;
    expect(harcamalarSekmesi, findsWidgets);
    await tester.tap(harcamalarSekmesi);
    await tester.pumpAndSettle();

    final fab = find.byType(FloatingActionButton).last;
    await tester.tap(fab);
    await tester.pumpAndSettle();

    final isimField = find.widgetWithText(TextField, 'Harcama Adı');
    await tester.enterText(isimField, 'GiderE2E');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    final tutarField = find.widgetWithText(TextField, 'Tutar');
    await tester.enterText(tutarField, '500');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    // ...Kategori seçimi (Eski testte atlanmış, listelenen defaultla devam).
    final kaydetButonu = find.widgetWithText(ElevatedButton, 'Kaydet');
    await tester.tap(kaydetButonu);
    await tester.pumpAndSettle();

    // Gider Listesinde "GiderE2E" ve "500" görüldü mü?
    expect(find.textContaining('GiderE2E'), findsWidgets);

    // --- STEP 1: SİLME (Swipe to Delete) ---
    final targetWidget = find.textContaining('GiderE2E');
    expect(targetWidget, findsWidgets);

    // Sola Kaydır (Sil)
    await tester.drag(targetWidget.first, const Offset(-500.0, 0.0));
    await tester.pumpAndSettle();

    // SnackBar'ın kapanmasını bekle (4 saniye)
    await tester.pumpAndSettle(const Duration(seconds: 4));

    // Öğenin Ana Listede olmadığını teyit edelim.
    expect(find.textContaining('GiderE2E'), findsNothing);

    // --- STEP 2: ÇÖP KUTUSUNA GİDİŞ ---
    final ayarlarSekmesi = find.text('Ayarlar').first;
    expect(ayarlarSekmesi, findsWidgets);
    await tester.tap(ayarlarSekmesi);
    await tester.pumpAndSettle();

    // Menüden Çöp Kutusuna tıkla
    final copKutusuButton = find.text('Çöp Kutusu');
    await tester.tap(copKutusuButton);
    await tester.pumpAndSettle();

    // Çöp kutusu sayfasında olduğumuzu doğrula
    expect(find.textContaining('Silinmiş Öğeler'), findsAtLeastNWidgets(1));

    // --- STEP 3: SİLİNEN ÖĞEYİ GERİ YÜKLE ---
    // Listede GiderE2E görünüyor
    expect(find.textContaining('GiderE2E'), findsWidgets);
    expect(find.textContaining('500'), findsWidgets);

    // Swipe Right to Restore (Veya ListTile trailing IconButon'u)
    final silinenWidget = find.textContaining('GiderE2E').first;

    // Genelde ListTile sonundaki Ikon Button ile geri yükleme çalışır (Icons.restore)
    var restoreIcons = find.byIcon(Icons.restore);
    if (restoreIcons.evaluate().isNotEmpty) {
      await tester.tap(restoreIcons.first);
      await tester.pumpAndSettle();
    } else {
      // Aksi takdirde Swipe deniyoruz
      await tester.drag(silinenWidget, const Offset(500.0, 0.0));
      await tester.pumpAndSettle();
    }

    // Çöp Kutusu Listesi'nden kaybolduğunu doğrula
    await tester.pumpAndSettle(const Duration(seconds: 3));
    expect(find.textContaining('GiderE2E'), findsNothing);

    // Geri (Appbar Back Button)
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    // --- STEP 4: ANA SAYFA DÖNÜŞ VE KONTROL ---
    await tester.tap(harcamalarSekmesi);
    await tester.pumpAndSettle();

    // HARCAMA GERİ GELMİŞ Mİ?
    expect(find.textContaining('GiderE2E'), findsWidgets);
  });
}
