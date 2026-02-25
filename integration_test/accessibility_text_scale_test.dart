import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:cashly/main.dart' as app;

/// Erişilebilirlik (Büyük Yazı Tipi) RenderFlex Taşkın Testi
/// Sistem metin boyutu 3 katına çıktığında app çöküyor mu?
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Accessibility Text Scale (3.0x) Overflow Test', (
    WidgetTester tester,
  ) async {
    // ========== 1. Cihaz Metin Boyutunu Devasa Yap (Körlük Modu Ölçeği) ==========
    tester.binding.platformDispatcher.textScaleFactorTestValue = 3.0;

    app.main();
    await tester.pumpAndSettle();

    // ========== 2. Dashboard RendereFlex Hata Kontrolü ==========
    // Eğer bir widget Fixed yükseklikteyse (örn: height: 100) ve metin taşıyorsa
    // Exception fırlatır (Yellow/Black zebra çizgileri)
    // Test ortamında bu crash olarak "error" kaydeder.
    expect(find.byType(MaterialApp), findsOneWidget);

    // ========== 3. Farklı Sekmelere de Gidip Test Et ==========
    final giderlerSekmesi = find.text('Giderler');
    if (giderlerSekmesi.evaluate().isNotEmpty) {
      await tester.tap(giderlerSekmesi.first);
      await tester.pumpAndSettle();
    }

    final ayarlarSekmesi = find.text('Ayarlar').first;
    if (ayarlarSekmesi.evaluate().isNotEmpty) {
      await tester.tap(ayarlarSekmesi);
      await tester.pumpAndSettle();
    }

    // ========== 4. Skalayı Temizle ==========
    tester.binding.platformDispatcher.clearTextScaleFactorTestValue();
    await tester.pumpAndSettle();

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
