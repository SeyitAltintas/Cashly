import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cashly/core/widgets/form/app_form_field.dart';
import 'package:cashly/core/services/currency_service.dart';
import 'package:get_it/get_it.dart';

void main() {
  setUpAll(() {
    // Register CurrencyService mock if not already registered
    if (!GetIt.instance.isRegistered<CurrencyService>()) {
      GetIt.instance.registerLazySingleton<CurrencyService>(
        () => CurrencyService(),
      );
    }
  });

  tearDownAll(() {
    GetIt.instance.reset();
  });

  group('AppFormField Widget Testleri', () {
    testWidgets('Temel AppFormField oluşturulabilir', (
      WidgetTester tester,
    ) async {
      // Controller oluştur
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppFormField(
              controller: controller,
              labelText: 'Test Label',
              hintText: 'Test Hint',
            ),
          ),
        ),
      );

      // Label ve hint text'in görünür olduğunu kontrol et
      expect(find.text('Test Label'), findsOneWidget);
      expect(find.text('Test Hint'), findsOneWidget);

      // Temizlik
      controller.dispose();
    });

    testWidgets('AppFormField.amount factory method çalışır', (
      WidgetTester tester,
    ) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: AppFormField.amount(controller: controller)),
        ),
      );

      // Widget oluşturulduğunu kontrol et
      expect(find.byType(AppFormField), findsOneWidget);

      // Para ikonu görünür mü
      expect(find.byIcon(Icons.attach_money), findsOneWidget);

      controller.dispose();
    });

    testWidgets('AppFormField.description factory method çalışır', (
      WidgetTester tester,
    ) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppFormField.description(controller: controller),
          ),
        ),
      );

      // Açıklama label'ının görünür olduğunu kontrol et
      expect(find.text('Açıklama'), findsOneWidget);

      // Açıklama ikonu görünür mü
      expect(find.byIcon(Icons.description), findsOneWidget);

      controller.dispose();
    });

    testWidgets('AppFormField text girişi kabul eder', (
      WidgetTester tester,
    ) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppFormField(controller: controller, labelText: 'Test'),
          ),
        ),
      );

      // Text girişi yap
      await tester.enterText(find.byType(TextFormField), 'Test Metin');
      expect(controller.text, equals('Test Metin'));

      controller.dispose();
    });

    testWidgets('AppFormField onChanged callback çalışır', (
      WidgetTester tester,
    ) async {
      final controller = TextEditingController();
      String? changedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppFormField(
              controller: controller,
              labelText: 'Test',
              onChanged: (value) => changedValue = value,
            ),
          ),
        ),
      );

      // Text girişi yap
      await tester.enterText(find.byType(TextFormField), 'Yeni Değer');
      expect(changedValue, equals('Yeni Değer'));

      controller.dispose();
    });

    testWidgets('AppFormField validator çalışır', (WidgetTester tester) async {
      final controller = TextEditingController();
      final formKey = GlobalKey<FormState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: AppFormField(
                controller: controller,
                labelText: 'Test',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Bu alan zorunludur';
                  }
                  return null;
                },
              ),
            ),
          ),
        ),
      );

      // Form'u validate et (boş değerle)
      formKey.currentState!.validate();
      await tester.pump();

      // Hata mesajının görünür olduğunu kontrol et
      expect(find.text('Bu alan zorunludur'), findsOneWidget);

      controller.dispose();
    });

    testWidgets('AppFormField özel accentColor kullanır', (
      WidgetTester tester,
    ) async {
      final controller = TextEditingController();
      const customColor = Colors.green;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppFormField(
              controller: controller,
              labelText: 'Test',
              accentColor: customColor,
              prefixIcon: const Icon(Icons.check),
            ),
          ),
        ),
      );

      // Widget'ın oluşturulduğunu kontrol et
      expect(find.byType(AppFormField), findsOneWidget);

      controller.dispose();
    });

    testWidgets('AppFormField readOnly modda çalışır', (
      WidgetTester tester,
    ) async {
      final controller = TextEditingController(text: 'ReadOnly Metin');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppFormField(
              controller: controller,
              labelText: 'Test',
              readOnly: true,
            ),
          ),
        ),
      );

      // Widget'ın oluşturulduğunu kontrol et
      expect(find.byType(AppFormField), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);

      // ReadOnly modda metin görünür olmalı
      expect(find.text('ReadOnly Metin'), findsOneWidget);

      controller.dispose();
    });

    testWidgets('AppFormField disabled modda çalışır', (
      WidgetTester tester,
    ) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppFormField(
              controller: controller,
              labelText: 'Test',
              enabled: false,
            ),
          ),
        ),
      );

      // Widget'ın oluşturulduğunu kontrol et
      expect(find.byType(AppFormField), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);

      controller.dispose();
    });
  });
}
