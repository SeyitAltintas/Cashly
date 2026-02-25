import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:cashly/main.dart' as app;

/// App Lifecycle (Arka plana atılma) E2E Testi
/// Uygulama "Paused" (Home tuşuna basmış gibi) durumuna getirilip
/// tekrar "Resumed" edildiğinde ekran kilitlenmesi veya stabilite testi.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('App Lifecycle Lock / Pause Resume Flow Test', (
    WidgetTester tester,
  ) async {
    app.main();
    await tester.pumpAndSettle();

    // ========== 1. Ekranların Normal Olarak Yüklendiğini Doğrula ==========
    expect(find.byType(MaterialApp), findsOneWidget);

    // ========== 2. Arka Plana Gönderimi Simüle Et (Paused) ==========
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pumpAndSettle();

    // Genellikle paused durumunda Flutter widget tear-down yapmaz ama
    // gizleme katmanı veya loglama tetiklenecektir.

    // Bağımlılığına göre app uyku (Inactive) durumuna da geçirilir
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await tester.pumpAndSettle();

    // ========== 3. Ön Plana Tekrar Gelmeyi Simüle Et (Resumed) ==========
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();

    // ========== 4. Lock Ekranı veya Ana Ekran Görünüyor mu? ==========
    // Uygulama güvenlik kilidi açıldıysa PIN gir ekranı olmalı
    final pinEkraniTuslari = find.byType(GridView);
    final pinBasligi = find.textContaining('PIN');
    final sifreSifirla = find.textContaining('Şifre');

    if (pinEkraniTuslari.evaluate().isNotEmpty ||
        pinBasligi.evaluate().isNotEmpty ||
        sifreSifirla.evaluate().isNotEmpty) {
      // Pin kilidi var
      // Bir PIN girmeyi deneyelim (1,1,1,1 varsayalım)
      final buttons = find.byType(TextButton);
      if (buttons.evaluate().length >= 10) {
        await tester.tap(buttons.at(0)); // Örneğin '1' e bas
        await tester.pump(const Duration(milliseconds: 200));
        await tester.tap(buttons.at(0));
        await tester.pump(const Duration(milliseconds: 200));
        await tester.tap(buttons.at(0));
        await tester.pump(const Duration(milliseconds: 200));
        await tester.tap(buttons.at(0));
        await tester.pumpAndSettle();
      }
    }

    // Uygulamanın resume olduktan sonra çökmemesi kritik olandır
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
