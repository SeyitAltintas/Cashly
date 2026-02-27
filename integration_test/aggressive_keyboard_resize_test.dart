import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:cashly/main.dart' as app;

/// 88. Unexpected Keyboard Resize & Layout Break Test
/// Amaç: TextField'lara odaklanıldığında (Focus) cihazın sanal klavyesinin
/// (Soft Keyboard) ekranı daraltması, aniden kaybolması ve UI elementlerini
/// alt/üst etmesi (BottomOverflowedBy) kaynaklı çökmeleri bulmak.

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Aggressive Keyboard Layout Resize Test', (
    WidgetTester tester,
  ) async {
    app.main();
    await tester.pumpAndSettle();

    // Alt sekmelerden form yoğunluğu çok olan (örn: Ayarlar -> Profil veya İşlem Ekle) sekmesine geç
    final sekmeler = find.text('Ayarlar');
    if (sekmeler.evaluate().isNotEmpty) {
      await tester.tap(sekmeler.first);
      await tester.pumpAndSettle();
    }

    final formFields = find.byType(TextField);
    if (formFields.evaluate().isNotEmpty) {
      // Sayfadaki son inputa git (klavye en çok bunu iter)
      final bottomInput = formFields.last;

      // Kaydırıp inputu bul
      await tester.ensureVisible(bottomInput);
      await tester.pumpAndSettle();

      // ==============================================================
      // SİMÜLASYON: Klavyeyi Asenkron & Ani Tetikle / Gizle Döngüsü
      // Amaç: Scaffold'un "resizeToAvoidBottomInset" sınırını zorlamak.
      // ==============================================================
      for (int i = 0; i < 5; i++) {
        // Klavyeyi aç (Focus)
        await tester.tap(bottomInput);
        await tester.pump(const Duration(milliseconds: 200));

        // Klavyeyi aniden, fiziksel olarak kapat (Unfocus all)
        FocusManager.instance.primaryFocus?.unfocus();
        // Veya "Bitti" tuşuna basmış gibi:
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pump(const Duration(milliseconds: 200));
      }

      // Render limitlerine çarpıldığında "RenderFlex overflowed" genellikle Sessiz fırlar
      // Bunu net bir exception olarak yakalayıp yakalayamayacağımıza bakarız:
      expect(
        tester.takeException(),
        null,
        reason:
            "Klavyenin açılıp kapanması sırasında RenderFlex Overflow ve BoxConstraints kırılması oluştu.",
      );
    }
  });
}
