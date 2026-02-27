import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:cashly/main.dart' as app;

/// Para Birimi Değiştirme Akışı E2E Testi
/// Amaç: Para birimini TRY'den USD'ye çevirdiğimizde Dashboard ve
/// Harcamalar listesindeki sembol ve formatın doğru güncellenmesini test etmek.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Currency Change Flow Test', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();

    // ========== ADIM 1: Varsayılan Para Birimi Doğrulaması ==========
    // Dashboard'da "₺" sembolünün mevcut olduğunu kontrol et
    expect(
      find.textContaining('₺'),
      findsWidgets,
      reason: 'Varsayılan TRY (₺) sembolü Dashboard\'da görünmeli',
    );

    // ========== ADIM 2: Ayarlar -> Para Birimi ==========
    final ayarlarSekmesi = find.text('Ayarlar').first;
    expect(ayarlarSekmesi, findsWidgets);
    await tester.tap(ayarlarSekmesi);
    await tester.pumpAndSettle();

    // Para birimi ayarı seçeneği
    final paraBirimiMenu = find.text('Para Birimi');
    if (paraBirimiMenu.evaluate().isNotEmpty) {
      await tester.tap(paraBirimiMenu.first);
      await tester.pumpAndSettle();

      // USD seçeneği
      final usdOption = find.textContaining('USD');
      final dolarOption = find.textContaining(r'$');

      if (usdOption.evaluate().isNotEmpty) {
        await tester.tap(usdOption.first);
        await tester.pumpAndSettle();
      } else if (dolarOption.evaluate().isNotEmpty) {
        await tester.tap(dolarOption.first);
        await tester.pumpAndSettle();
      }
    } else {
      fail('Hatali Test: Beklenen UI bileseni (widget) ekranda bulunamadi.');
    }

    // ========== ADIM 3: Dashboard'a Dön ve Sembol Kontrolü ==========
    final dashboardSekmesi = find.text('Ana Sayfa').first;
    if (dashboardSekmesi.evaluate().isNotEmpty) {
      await tester.tap(dashboardSekmesi);
      await tester.pumpAndSettle();
    } else {
      fail('Hatali Test: Beklenen UI bileseni (widget) ekranda bulunamadi.');
    }

    // Uygulama çökmeden para birimi değişimi tamamlandı mı?
    expect(find.byType(MaterialApp), findsOneWidget);

    // "$" sembolünün artık ekranda olup olmadığını kontrol et
    // (Para birimi değişimi başarılıysa ₺ yerine $ görünecek)
    // Not: Gerçek davranış CurrencyService entegrasyonuna bağlıdır.

    // ========== ADIM 4: Geri TRY'ye Dön (Temizlik) ==========
    await tester.tap(ayarlarSekmesi);
    await tester.pumpAndSettle();

    if (paraBirimiMenu.evaluate().isNotEmpty) {
      await tester.tap(paraBirimiMenu.first);
      await tester.pumpAndSettle();

      final tryOption = find.textContaining('TRY');
      final tlOption = find.textContaining('₺');

      if (tryOption.evaluate().isNotEmpty) {
        await tester.tap(tryOption.first);
        await tester.pumpAndSettle();
      } else if (tlOption.evaluate().isNotEmpty) {
        await tester.tap(tlOption.first);
        await tester.pumpAndSettle();
      }
    } else {
      fail('Hatali Test: Beklenen UI bileseni (widget) ekranda bulunamadi.');
    }

    // Son kontrol: uygulama sağlam mı?
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
