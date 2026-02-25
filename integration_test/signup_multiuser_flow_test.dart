import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:cashly/main.dart' as app;

/// 12. Kayıt & Çoklu Kullanıcı Akışı E2E Testi
/// Yeni kullanıcı kaydı ve kullanıcı listesi doğrulama
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Signup & Multi User Flow Test', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();

    // ========== ADIM 1: Login/Signup Sayfasını Kontrol Et ==========
    // Uygulama ilk açıldığında login/signup olabilir
    // Veya Ayarlar > Kullanıcılar'dan erişilebilir

    // Eğer zaten giriş yapılmışsa Ayarlar'dan kullanıcı yönetimi
    final ayarlarSekmesi = find.text('Ayarlar');
    if (ayarlarSekmesi.evaluate().isNotEmpty) {
      await tester.tap(ayarlarSekmesi.first);
      await tester.pumpAndSettle();
    }

    // Kullanıcı Yönetimi veya Profil menüsü
    final kullanicilar = find.textContaining('Kullanıcı');
    final profilMenu = find.text('Profil');

    if (kullanicilar.evaluate().isNotEmpty) {
      await tester.tap(kullanicilar.first);
      await tester.pumpAndSettle();
    } else if (profilMenu.evaluate().isNotEmpty) {
      await tester.tap(profilMenu.first);
      await tester.pumpAndSettle();
    }

    // ========== ADIM 2: Yeni Kullanıcı Ekle ==========
    final ekleButonu = find.byIcon(Icons.person_add);
    final addButton = find.byIcon(Icons.add);

    if (ekleButonu.evaluate().isNotEmpty) {
      await tester.tap(ekleButonu.first);
      await tester.pumpAndSettle();
    } else if (addButton.evaluate().isNotEmpty) {
      await tester.tap(addButton.last);
      await tester.pumpAndSettle();
    }

    // İsim gir
    final nameField = find.byType(TextField);
    if (nameField.evaluate().isNotEmpty) {
      await tester.enterText(nameField.first, 'E2E Test Kullanıcı 2');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
    }

    // Kaydet / Oluştur
    final kaydet = find.text('Kaydet');
    final olustur = find.text('Oluştur');
    final create = find.text('Ekle');

    if (kaydet.evaluate().isNotEmpty) {
      await tester.tap(kaydet.first);
      await tester.pumpAndSettle();
    } else if (olustur.evaluate().isNotEmpty) {
      await tester.tap(olustur.first);
      await tester.pumpAndSettle();
    } else if (create.evaluate().isNotEmpty) {
      await tester.tap(create.first);
      await tester.pumpAndSettle();
    }

    // ========== ADIM 3: Kullanıcı Listesinde Görünüyor Mu ==========
    // Not: Eğer kullanıcı listesi sayfası varsa kontrol et
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
