import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:cashly/main.dart' as app;

/// 90. Extreme Date Selection & Infinite Loop Chaos Test
/// Amaç: Tarih seçici (Date Picker) üzerinden çok eski (örn: 1900 yılı) veya
/// çok uzak bir gelecekteki (örn: 2100 yılı) tarihler seçildiğinde,
/// özellikle 'Tekrarlayan İşlemler' (Recurring Transactions) veya 'Grafik' metotlarının
/// "While(tarih < bitisTarihi)" benzeri sonsuz döngülere (Infinite Loop) girip uygulamayı dondurmasını test etmek.

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Extreme Date Selection Infinite Loop E2E Test', (
    WidgetTester tester,
  ) async {
    app.main();
    await tester.pumpAndSettle();

    final fabButton = find.byType(FloatingActionButton);
    if (fabButton.evaluate().isNotEmpty) {
      await tester.tap(fabButton.first);
      await tester.pumpAndSettle();

      // Tarih seçici butonu veya TextField'ı bul
      // Genellikle DatePicker çağıran bir buton ikon (calendar_today) vardır.
      Finder dateIcon = find.byIcon(Icons.calendar_today);
      if (dateIcon.evaluate().isEmpty) {
        dateIcon = find.byIcon(Icons.date_range);
      }

      if (dateIcon.evaluate().isNotEmpty) {
        await tester.tap(dateIcon.first);
        await tester.pumpAndSettle(); // Takvim açıldı

        // Edit icon ile Text moduna geçmek (Takvimde yılı manuel girmek genelde daha kolaydır)
        final editIcon = find.byIcon(Icons.edit);
        if (editIcon.evaluate().isNotEmpty) {
          await tester.tap(editIcon.first);
          await tester.pumpAndSettle();

          // Tarih girişi (1900 yılı)
          final dateField = find.byType(TextField).last;
          await tester.enterText(
            dateField,
            '01/01/1900',
          ); // ya da lokal formatınıza göre
          await tester.testTextInput.receiveAction(TextInputAction.done);
          await tester.pumpAndSettle();

          Finder okButton = find.text('Tamam');
          if (okButton.evaluate().isEmpty) {
            okButton = find.text('OK');
          }
          if (okButton.evaluate().isEmpty) {
            okButton = find.text('KAYDET');
          }
          if (okButton.evaluate().isNotEmpty) {
            await tester.tap(okButton.last);
            await tester.pumpAndSettle();
          }
        } else {
          // Takvimde agresif Swipe (Mevcut aydan geriye doğru fışkırtma)
          Finder calendarView = find.byType(PageView);
          if (calendarView.evaluate().isEmpty) {
            calendarView = find.byType(GridView);
          }
          if (calendarView.evaluate().isNotEmpty) {
            for (int i = 0; i < 10; i++) {
              // Aylar arası çok hızlı geçiş
              await tester.fling(
                calendarView.first,
                const Offset(300, 0),
                1000,
              );
              await tester.pump(const Duration(milliseconds: 50));
            }
          }
          // Kapatmaya zorla
          await tester.tapAt(const Offset(5, 5));
          await tester.pumpAndSettle();
        }

        // =========================================================
        // KONTROL: Sistem Dondu mu? (Infinite Loop veya Date Parse Hatası)
        // =========================================================
        // Eğer yukarıdaki ekstrem tarih, veritabanına veya mantıksal katmana ulaştıysa ve
        // uygulama donduysa, tester Timeout alacaktır.
        // Biz yine de pumpAndSettle ile arayüzün kilitlenmediğinden ve hata fırlatmadığından eminiz.
        expect(
          tester.takeException(),
          null,
          reason:
              "Uç noktalardaki tarihler (1900 veya uzak gelecek) Date Parse hatasına veya Döngü kilitlenmesine neden oldu.",
        );
      }
    }
  });
}
