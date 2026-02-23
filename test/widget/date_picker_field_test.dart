import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cashly/core/widgets/form/date_picker_field.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:cashly/l10n/generated/app_localizations.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('tr_TR', null);
  });

  group('DatePickerField Widget Testleri', () {
    testWidgets('Temel DatePickerField oluşturulabilir', (
      WidgetTester tester,
    ) async {
      final testDate = DateTime(2026, 1, 15);

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('tr'),
          home: Scaffold(
            body: DatePickerField(
              selectedDate: testDate,
              onDateChanged: (_) {},
            ),
          ),
        ),
      );

      // Widget'ın oluşturulduğunu kontrol et
      expect(find.byType(DatePickerField), findsOneWidget);

      // Takvim ikonu görünür mü
      expect(find.byIcon(Icons.calendar_today), findsOneWidget);
    });

    testWidgets('DatePickerField seçilen tarihi gösterir', (
      WidgetTester tester,
    ) async {
      final testDate = DateTime(2026, 1, 15);

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('tr'),
          home: Scaffold(
            body: DatePickerField(
              selectedDate: testDate,
              onDateChanged: (_) {},
            ),
          ),
        ),
      );

      // Tarih formatının görünür olduğunu kontrol et (format: dd MMMM yyyy)
      // '15 Ocak 2026' şeklinde görünmeli
      expect(find.textContaining('15'), findsOneWidget);
    });

    testWidgets('DatePickerField.expense factory çalışır', (
      WidgetTester tester,
    ) async {
      final testDate = DateTime(2026, 1, 15);

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('tr'),
          home: Scaffold(
            body: DatePickerField.expense(
              selectedDate: testDate,
              onDateChanged: (_) {},
            ),
          ),
        ),
      );

      // Widget'ın oluşturulduğunu kontrol et
      expect(find.byType(DatePickerField), findsOneWidget);

      // Harcama label'ının görünür olduğunu kontrol et
      expect(find.text('Tarih'), findsOneWidget);
    });

    testWidgets('DatePickerField.income factory çalışır', (
      WidgetTester tester,
    ) async {
      final testDate = DateTime(2026, 1, 15);

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('tr'),
          home: Scaffold(
            body: DatePickerField.income(
              selectedDate: testDate,
              onDateChanged: (_) {},
            ),
          ),
        ),
      );

      // Widget'ın oluşturulduğunu kontrol et
      expect(find.byType(DatePickerField), findsOneWidget);

      // Gelir label'ının görünür olduğunu kontrol et
      expect(find.text('Tarih'), findsOneWidget);
    });

    testWidgets('DatePickerField özel labelText gösterir', (
      WidgetTester tester,
    ) async {
      final testDate = DateTime(2026, 1, 15);

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('tr'),
          home: Scaffold(
            body: DatePickerField(
              selectedDate: testDate,
              onDateChanged: (_) {},
              labelText: 'Özel Label',
            ),
          ),
        ),
      );

      // Özel label'ın görünür olduğunu kontrol et
      expect(find.text('Özel Label'), findsOneWidget);
    });

    testWidgets('DatePickerField tıklanabilir', (WidgetTester tester) async {
      final testDate = DateTime(2026, 1, 15);

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('tr'),
          home: Scaffold(
            body: DatePickerField(
              selectedDate: testDate,
              onDateChanged: (_) {},
            ),
          ),
        ),
      );

      // GestureDetector var mı kontrol et
      expect(find.byType(GestureDetector), findsOneWidget);

      // DatePicker'ı açmak için tıkla
      await tester.tap(find.byType(DatePickerField));
      await tester.pumpAndSettle();

      // DatePicker dialog açıldı mı (OK veya İptal butonları var mı)
      expect(find.byType(Dialog), findsOneWidget);
    });

    testWidgets('DatePickerField labelText null olabilir', (
      WidgetTester tester,
    ) async {
      final testDate = DateTime(2026, 1, 15);

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('tr'),
          home: Scaffold(
            body: DatePickerField(
              selectedDate: testDate,
              onDateChanged: (_) {},
              labelText: null,
            ),
          ),
        ),
      );

      // Widget'ın oluşturulduğunu kontrol et
      expect(find.byType(DatePickerField), findsOneWidget);

      // Varsayılan 'Tarih' label'ı görünür. Localization fallback'i.
      expect(find.text('Tarih'), findsOneWidget);
    });
  });
}
