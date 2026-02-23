import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:cashly/l10n/generated/app_localizations.dart';
import 'package:cashly/core/widgets/month_selector_button.dart';

/// Turkish locale wrapping helper for tests
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
  group('MonthSelectorButton Widget Tests', () {
    testWidgets('renders correctly with required parameters', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          MonthSelectorButton(
            selectedMonth: 6,
            selectedYear: 2026,
            onMonthSelected: (_) {},
          ),
        ),
      );

      expect(find.byType(MonthSelectorButton), findsOneWidget);
    });

    testWidgets('displays correct month name in Turkish', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          MonthSelectorButton(
            selectedMonth: 6,
            selectedYear: 2026,
            onMonthSelected: (_) {},
          ),
        ),
      );

      expect(find.text('Haziran 2026'), findsOneWidget);
    });

    testWidgets('displays correct month name in English', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          MonthSelectorButton(
            selectedMonth: 6,
            selectedYear: 2026,
            onMonthSelected: (_) {},
          ),
          locale: const Locale('en'),
        ),
      );

      expect(find.text('June 2026'), findsOneWidget);
    });

    testWidgets('displays January correctly', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          MonthSelectorButton(
            selectedMonth: 1,
            selectedYear: 2026,
            onMonthSelected: (_) {},
          ),
        ),
      );

      expect(find.text('Ocak 2026'), findsOneWidget);
    });

    testWidgets('displays December correctly', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          MonthSelectorButton(
            selectedMonth: 12,
            selectedYear: 2025,
            onMonthSelected: (_) {},
          ),
        ),
      );

      expect(find.text('Aralık 2025'), findsOneWidget);
    });

    testWidgets('displays calendar icon', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          MonthSelectorButton(
            selectedMonth: 3,
            selectedYear: 2026,
            onMonthSelected: (_) {},
          ),
        ),
      );

      expect(find.byIcon(Icons.calendar_month), findsOneWidget);
    });

    testWidgets('displays dropdown arrow icon', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          MonthSelectorButton(
            selectedMonth: 3,
            selectedYear: 2026,
            onMonthSelected: (_) {},
          ),
        ),
      );

      expect(find.byIcon(Icons.arrow_drop_down), findsOneWidget);
    });

    testWidgets('is tappable', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          MonthSelectorButton(
            selectedMonth: 5,
            selectedYear: 2026,
            onMonthSelected: (_) {},
          ),
        ),
      );

      await tester.tap(find.byType(MonthSelectorButton));
      await tester.pumpAndSettle();

      expect(find.byType(MonthSelectorButton), findsOneWidget);
    });

    testWidgets('applies custom accent color', (tester) async {
      const customColor = Colors.red;

      await tester.pumpWidget(
        buildTestableWidget(
          MonthSelectorButton(
            selectedMonth: 7,
            selectedYear: 2026,
            onMonthSelected: (_) {},
            accentColor: customColor,
          ),
        ),
      );

      expect(find.byType(MonthSelectorButton), findsOneWidget);
    });

    testWidgets('all months display correctly', (tester) async {
      const months = [
        (1, 'Ocak'),
        (2, 'Şubat'),
        (3, 'Mart'),
        (4, 'Nisan'),
        (5, 'Mayıs'),
        (6, 'Haziran'),
        (7, 'Temmuz'),
        (8, 'Ağustos'),
        (9, 'Eylül'),
        (10, 'Ekim'),
        (11, 'Kasım'),
        (12, 'Aralık'),
      ];

      for (final (monthNum, monthName) in months) {
        await tester.pumpWidget(
          buildTestableWidget(
            MonthSelectorButton(
              selectedMonth: monthNum,
              selectedYear: 2026,
              onMonthSelected: (_) {},
            ),
          ),
        );

        expect(
          find.text('$monthName 2026'),
          findsOneWidget,
          reason: 'Month $monthNum should display as "$monthName 2026"',
        );
      }
    });

    testWidgets('works with useNeutralSelectedStyle', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          MonthSelectorButton(
            selectedMonth: 8,
            selectedYear: 2026,
            onMonthSelected: (_) {},
            useNeutralSelectedStyle: true,
          ),
        ),
      );

      expect(find.byType(MonthSelectorButton), findsOneWidget);
      expect(find.text('Ağustos 2026'), findsOneWidget);
    });

    testWidgets('handles different years correctly', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          MonthSelectorButton(
            selectedMonth: 1,
            selectedYear: 2030,
            onMonthSelected: (_) {},
          ),
        ),
      );

      expect(find.text('Ocak 2030'), findsOneWidget);
    });

    testWidgets('button has correct styling', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          MonthSelectorButton(
            selectedMonth: 4,
            selectedYear: 2026,
            onMonthSelected: (_) {},
          ),
        ),
      );

      expect(find.byType(InkWell), findsOneWidget);
      expect(find.byType(Container), findsWidgets);
    });
  });
}
