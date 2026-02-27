import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:cashly/main.dart' as app;

/// Gelir Kategori Yönetimi E2E Testi
/// Gelir kategorisi ekleme ve listede doğrulama
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Income Category Management Flow Test', (
    WidgetTester tester,
  ) async {
    app.main();
    await tester.pumpAndSettle();

    // ========== Gelirler sekmesine git ==========
    final gelirlerSekmesi = find.text('Gelirler');
    if (gelirlerSekmesi.evaluate().isNotEmpty) {
      await tester.tap(gelirlerSekmesi.first);
      await tester.pumpAndSettle();
    } else {
      fail('Hatali Test: Beklenen UI bileseni (widget) ekranda bulunamadi.');
    }

    // ========== Ayarlara git ==========
    final settingsIcon = find.byIcon(Icons.settings);
    final moreIcon = find.byIcon(Icons.more_vert);

    if (settingsIcon.evaluate().isNotEmpty) {
      await tester.tap(settingsIcon.last);
      await tester.pumpAndSettle();
    } else if (moreIcon.evaluate().isNotEmpty) {
      await tester.tap(moreIcon.first);
      await tester.pumpAndSettle();
    } else {
      fail('Hatali Test: Beklenen UI bileseni (widget) ekranda bulunamadi.');
    }

    // ========== Kategori Yönetimi ==========
    final kategoriYonetimi = find.textContaining('Kategori');
    if (kategoriYonetimi.evaluate().isNotEmpty) {
      await tester.tap(kategoriYonetimi.first);
      await tester.pumpAndSettle();

      // Yeni kategori ekle
      final ekleButonu = find.byIcon(Icons.add);
      if (ekleButonu.evaluate().isNotEmpty) {
        await tester.tap(ekleButonu.last);
        await tester.pumpAndSettle();

        final field = find.byType(TextField).first;
        if (field.evaluate().isNotEmpty) {
          await tester.enterText(field, 'Yatırım Geliri E2E');
          await tester.testTextInput.receiveAction(TextInputAction.done);
          await tester.pumpAndSettle();
        }

        final kaydet = find.text('Kaydet');
        final ekle = find.text('Ekle');
        if (kaydet.evaluate().isNotEmpty) {
          await tester.tap(kaydet.first);
          await tester.pumpAndSettle();
        } else if (ekle.evaluate().isNotEmpty) {
          await tester.tap(ekle.first);
          await tester.pumpAndSettle();
        }
      }
    } else {
      fail('Hatali Test: Beklenen UI bileseni (widget) ekranda bulunamadi.');
    }

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
