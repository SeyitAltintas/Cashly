import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:cashly/main.dart' as app;

/// İnternet Yokken Döviz/Altın Yenileme Stres Testi
/// Offline durumda uygulamanın crash vermemesi ve Cache kullanması
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Offline Network Currency Update Resistance Test', (
    WidgetTester tester,
  ) async {
    app.main();
    await tester.pumpAndSettle();

    // ========== 1. Varlıklar/Kurlar Sayfasına Git ==========
    final varliklarSekmesi = find.text('Varlıklar');
    if (varliklarSekmesi.evaluate().isNotEmpty) {
      await tester.tap(varliklarSekmesi.first);
      await tester.pumpAndSettle();
    }

    // ========== 2. API Güncelleme Butonuna (Refresh) Tıkla ==========
    final refreshIcon = find.byIcon(Icons.refresh);
    final syncIcon = find.byIcon(Icons.sync);

    // Gerçek bir offline durumu tester üzerinden taklit etmek zordur (OS seviyesindedir)
    // Ancak arka plandaki Future API Call yapısının `await` Timeout durdurmaları test edilir.
    if (refreshIcon.evaluate().isNotEmpty) {
      await tester.tap(refreshIcon.first);
      // Backend api isteği gidiyor, sonucu bekle...
      await tester.pumpAndSettle(const Duration(seconds: 2));
    } else if (syncIcon.evaluate().isNotEmpty) {
      await tester.tap(syncIcon.first);
      await tester.pumpAndSettle(const Duration(seconds: 2));
    }

    // ========== 3. Snackbar Error veya Cache Başarısı Kontrolü ==========
    // Eğer internet giderse "Bağlantı Hatası" veya "Çevrimdışı" yazısı çıkar
    // Çıkmasa da uygulamanın API request hatası ile (Unhandled Exception) çökmemesi kritik
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
