import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:cashly/main.dart' as app;

/// 83. Concurrent UI Interactions & Flakiness Test
/// Amaç: Kullanıcının art arda, son derece hızlı şekillerde (Rage Click)
/// butonlara basması, sekmeleri değiştirmesi ve bottom_sheet/dialog
/// elementlerini tetiklemesinin uygulamanın "navigation stack" durumunu bozup bozmadığını test etmek.
/// Risk: Beklenmeyen state (durum) değişiklikleri, üst üste açılan menüler ve UI kilitlenmeleri.

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Concurrent UI / Rage Click Flakiness E2E Test', (
    WidgetTester tester,
  ) async {
    app.main();
    await tester.pumpAndSettle();

    // =========================================================
    // SENARYO 1: İşlem Ekle Butonuna (FAB) Rage Click (Çoklu Tıklama)
    // =========================================================
    final fabButton = find.byType(FloatingActionButton);
    if (fabButton.evaluate().isNotEmpty) {
      // Çoklu tıklama animasyon ve state kilitlenmelerini tetikleyebilir
      for (int i = 0; i < 7; i++) {
        await tester.tap(fabButton.first);
      }
      // Uygulamanın bunları işleyebilmesi için bekleyelim
      await tester.pumpAndSettle();

      // Herhangi bir State hatası veya çökme yaşanmamış olmalı
      expect(
        tester.takeException(),
        null,
        reason: "FAB rage-click sonrası uygulama çöktü veya State bozuldu.",
      );

      // Açılan ekranı geri veya boşluğa tıklayarak kapat
      final backButton = find.byType(BackButton);
      if (backButton.evaluate().isNotEmpty) {
        await tester.tap(backButton.first);
        await tester.pumpAndSettle();
      } else {
        await tester.tapAt(const Offset(1, 1)); // Bottom sheet dışına tıkla
        await tester.pumpAndSettle();
      }
    }

    // =========================================================
    // SENARYO 2: Sekmeler (Bottom Navigation) Arası Agresif Geçiş
    // =========================================================
    final homeTab = find.text('Ana Sayfa');
    final settingsTab = find.text('Ayarlar');

    if (homeTab.evaluate().isNotEmpty && settingsTab.evaluate().isNotEmpty) {
      // Kullanıcının sekmeler arasında çok hızlı gidip geldiği senaryo
      // Amaç: Async controller/provider yüklemelerinin abort edilip çökmemesini sağlamak
      for (int i = 0; i < 10; i++) {
        await tester.tap(settingsTab.first);
        await tester.pump(
          const Duration(milliseconds: 20),
        ); // Kısa micro task beklemesi
        await tester.tap(homeTab.first);
        await tester.pump(const Duration(milliseconds: 20));
      }
      await tester.pumpAndSettle(); // Nihai dengeyi bekle

      expect(
        tester.takeException(),
        null,
        reason:
            "Sekmeler arası hızlı geçişlerde (Tab Switching) bellek sızıntısı veya kilitlenme hatası alındı.",
      );
    }

    // Uygulama ayakta mı kontrolü
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
