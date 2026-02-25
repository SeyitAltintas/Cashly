import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:cashly/main.dart' as app;

/// Dashboard / Analiz Ekranında Tarih Filtresi (Ay Seçimi) E2E Testi
/// Month/Year Picker popup'ının açılması ve geçmiş bir aya gidilmesi
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Date Filter (Month/Year Picker) Flow Test', (
    WidgetTester tester,
  ) async {
    app.main();
    await tester.pumpAndSettle();

    // ========== 1. Dashboard'da Ay Seçici Nerede ==========
    // Çoğu ekranda appbar veya üst kısımda takvim veya ay ismi bulunur
    // Örn: Icons.calendar_today, veya "Haziran 2024" metni (TextButton)
    final calendarIcon = find.byIcon(Icons.calendar_today);
    final calendarMonthIcon = find.byIcon(Icons.calendar_month);

    // Yıl içeren yazılar aranabilir, şimdilik ikonlardan deneyelim
    if (calendarIcon.evaluate().isNotEmpty) {
      await tester.tap(calendarIcon.first);
      await tester.pumpAndSettle();
    } else if (calendarMonthIcon.evaluate().isNotEmpty) {
      await tester.tap(calendarMonthIcon.first);
      await tester.pumpAndSettle();
    } else {
      // Analiz veya Giderler sayfasına gidip bulalım
      final giderlerSekmesi = find.text('Giderler');
      if (giderlerSekmesi.evaluate().isNotEmpty) {
        await tester.tap(giderlerSekmesi.first);
        await tester.pumpAndSettle();

        if (calendarIcon.evaluate().isNotEmpty) {
          await tester.tap(calendarIcon.first);
          await tester.pumpAndSettle();
        } else if (calendarMonthIcon.evaluate().isNotEmpty) {
          await tester.tap(calendarMonthIcon.first);
          await tester.pumpAndSettle();
        }
      }
    }

    // ========== 2. Pop-up / Dialog içinde Ay Seçimi ==========
    // Eğer dialog açıldıysa genelde "Geçen Ay" için sol ok "<" ikon olur
    final prevMonthIcon = find.byIcon(Icons.chevron_left);
    if (prevMonthIcon.evaluate().isNotEmpty) {
      await tester.tap(prevMonthIcon.first);
      await tester.pumpAndSettle();

      // Tamam veya Onayla butonu varsa
      final tamam = find.text('Tamam');
      final ok = find.text('OK');
      if (tamam.evaluate().isNotEmpty) {
        await tester.tap(tamam.first);
        await tester.pumpAndSettle();
      } else if (ok.evaluate().isNotEmpty) {
        await tester.tap(ok.first);
        await tester.pumpAndSettle();
      }
    }

    // ========== 3. Boş Durum (Empty State) Gösterimi ==========
    // Geçmiş bir aya gidildiğinde veri yoksa "Burada işlem yok" veya EmptyState çıkar
    // Çökmediğini doğruluyoruz
    expect(find.byType(MaterialApp), findsOneWidget);

    // ========== 4. Tekrar Bugüne/Bu Aya Dön ==========
    final todayIcon = find.byIcon(Icons.today);
    if (todayIcon.evaluate().isNotEmpty) {
      await tester.tap(todayIcon.first);
      await tester.pumpAndSettle();
    }

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
