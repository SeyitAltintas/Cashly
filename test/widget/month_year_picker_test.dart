import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:cashly/l10n/generated/app_localizations.dart';
import 'package:cashly/core/widgets/month_year_picker.dart';
import 'package:intl/date_symbol_data_local.dart';

/// Turkish locale wrapping helper for MonthYearPicker tests
Widget buildTestableWidget(Widget child, {Locale locale = const Locale('tr')}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: child),
  );
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('tr_TR', null);
  });

  group('MonthYearPicker Widget Testleri', () {
    testWidgets('Temel MonthYearPicker oluşturulabilir', (
      WidgetTester tester,
    ) async {
      final now = DateTime(2026, 1, 15);

      await tester.pumpWidget(
        buildTestableWidget(
          MonthYearPicker(initialDate: now, onDateSelected: (_) {}),
        ),
      );

      // Widget var mı
      expect(find.byType(MonthYearPicker), findsOneWidget);

      // Başlık l10n'den geliyor — "Ay ve Yıl Seç" (tr) veya "Select Month and Year" (en)
      // Türkçe locale kullanıyoruz
      expect(find.text('Ay ve Yıl Seç'), findsOneWidget);

      // 'Bitti' butonu var mı
      expect(find.text('Bitti'), findsOneWidget);
    });

    testWidgets('Bitti butonuna tıklayınca onDateSelected çalışır', (
      WidgetTester tester,
    ) async {
      final now = DateTime(2026, 1, 15);
      DateTime? selectedDate;

      await tester.pumpWidget(
        buildTestableWidget(
          MonthYearPicker(
            initialDate: now,
            onDateSelected: (date) => selectedDate = date,
          ),
        ),
      );

      // Bitti'ye tıkla
      await tester.tap(find.text('Bitti'));
      await tester.pump();

      expect(selectedDate, isNotNull);
      expect(selectedDate?.year, 2026);
      expect(selectedDate?.month, 1);
    });

    testWidgets('Static show metodu çalışır', (WidgetTester tester) async {
      final now = DateTime(2026, 1, 15);

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('tr'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () {
                  MonthYearPicker.show(context, initialDate: now);
                },
                child: const Text('Picker Aç'),
              ),
            ),
          ),
        ),
      );

      // Butona tıkla
      await tester.tap(find.text('Picker Aç'));
      await tester.pumpAndSettle();

      // BottomSheet açıldı mı (MonthYearPicker içinde)
      expect(find.byType(MonthYearPicker), findsOneWidget);

      // Kapatmak için Bitti'ye tıkla
      await tester.tap(find.text('Bitti'));
      await tester.pumpAndSettle();

      // Kapandı mı
      expect(find.byType(MonthYearPicker), findsNothing);
    });
  });
}
