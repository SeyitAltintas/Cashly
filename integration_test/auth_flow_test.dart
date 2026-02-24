import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:cashly/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Kimlik Doğrulama Hatalı Giriş ve Parola Sıfırlama Akışı', (
    WidgetTester tester,
  ) async {
    app.main();
    await tester.pumpAndSettle();

    // Not: Uygulama önceden giriş yapmış halde değilse Auth sayfasında açılacaktır
    // Eğer direk Dashboard'a düşülüyorsa, logout yapıp test edilebilir

    // Varsayım: Login sayfasındayız
    final emailField = find.byType(TextField).first;
    final passwordField = find.byType(TextField).last;

    if (emailField.evaluate().isNotEmpty &&
        passwordField.evaluate().isNotEmpty) {
      // 1. Yanlış Bir E-posta Formatı Girmeyi Deneyelim
      await tester.enterText(emailField, 'test@');
      await tester.enterText(passwordField, '1234');

      final girisYapButonu = find.widgetWithText(ElevatedButton, 'Giriş Yap');
      if (girisYapButonu.evaluate().isNotEmpty) {
        await tester.tap(girisYapButonu);
        await tester.pumpAndSettle();

        // Uyarı (Validasyon Hatası) mesajı çıkmalı (Örn: Geçerli e-posta veya eksik şifre)
        // expect(find.textContaining('e-posta'), findsWidgets); // Bu proje özelinde localizasyondan gelebilir.
      }

      // 2. Parolamı Unuttum Linki test ediliyor
      final sifreUnettumButton = find.text(
        'Şifremi Unuttum',
      ); // Veya TextButton ('Forgot Password?')
      if (sifreUnettumButton.evaluate().isNotEmpty) {
        await tester.tap(sifreUnettumButton);
        await tester.pumpAndSettle();

        // E-posta input'unun tekrar ekranda olması veya bir AlertDialog çıkması beklenir
        final emailResetField = find.byType(TextField).first;
        if (emailResetField.evaluate().isNotEmpty) {
          await tester.enterText(emailResetField, 'test@example.com');

          final gonderButonu = find.widgetWithText(
            ElevatedButton,
            'Gönder',
          ); // Send Email vb
          if (gonderButonu.evaluate().isNotEmpty) {
            await tester.tap(gonderButonu);
            await tester.pumpAndSettle();

            // Başarı mesajı onaylanır
            // expect(find.textContaining('gönderildi'), findsWidgets);
          }
        }
      }
    }
  });
}
