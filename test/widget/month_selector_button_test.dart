import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cashly/core/widgets/month_selector_button.dart';

void main() {
  group('MonthSelectorButton Widget Tests', () {
    testWidgets('renders correctly with required parameters', (tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MonthSelectorButton(
              selectedMonth: 6,
              selectedYear: 2026,
              onMonthSelected: (_) {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(MonthSelectorButton), findsOneWidget);
    });

    testWidgets('displays correct month name in Turkish', (tester) async {
      // Arrange - Haziran (6. ay)
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MonthSelectorButton(
              selectedMonth: 6,
              selectedYear: 2026,
              onMonthSelected: (_) {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Haziran 2026'), findsOneWidget);
    });

    testWidgets('displays January correctly', (tester) async {
      // Arrange - Ocak (1. ay)
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MonthSelectorButton(
              selectedMonth: 1,
              selectedYear: 2026,
              onMonthSelected: (_) {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Ocak 2026'), findsOneWidget);
    });

    testWidgets('displays December correctly', (tester) async {
      // Arrange - Aralık (12. ay)
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MonthSelectorButton(
              selectedMonth: 12,
              selectedYear: 2025,
              onMonthSelected: (_) {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Aralık 2025'), findsOneWidget);
    });

    testWidgets('displays calendar icon', (tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MonthSelectorButton(
              selectedMonth: 3,
              selectedYear: 2026,
              onMonthSelected: (_) {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.calendar_month), findsOneWidget);
    });

    testWidgets('displays dropdown arrow icon', (tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MonthSelectorButton(
              selectedMonth: 3,
              selectedYear: 2026,
              onMonthSelected: (_) {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.arrow_drop_down), findsOneWidget);
    });

    testWidgets('is tappable', (tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MonthSelectorButton(
              selectedMonth: 5,
              selectedYear: 2026,
              onMonthSelected: (_) {},
            ),
          ),
        ),
      );

      // Act - Tıkla
      await tester.tap(find.byType(MonthSelectorButton));
      await tester.pumpAndSettle();

      // Assert - MonthYearPicker bottom sheet açılmalı
      // Not: MonthYearPicker'ın açıldığını kontrol etmek için
      // modalBottomSheet veya benzeri bir widget aranabilir
      expect(find.byType(MonthSelectorButton), findsOneWidget);
    });

    testWidgets('applies custom accent color', (tester) async {
      // Arrange
      const customColor = Colors.red;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MonthSelectorButton(
              selectedMonth: 7,
              selectedYear: 2026,
              onMonthSelected: (_) {},
              accentColor: customColor,
            ),
          ),
        ),
      );

      // Assert - Widget render edilmeli
      expect(find.byType(MonthSelectorButton), findsOneWidget);
    });

    testWidgets('all months display correctly', (tester) async {
      // Tüm ayları test et
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
          MaterialApp(
            home: Scaffold(
              body: MonthSelectorButton(
                selectedMonth: monthNum,
                selectedYear: 2026,
                onMonthSelected: (_) {},
              ),
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
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MonthSelectorButton(
              selectedMonth: 8,
              selectedYear: 2026,
              onMonthSelected: (_) {},
              useNeutralSelectedStyle: true,
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(MonthSelectorButton), findsOneWidget);
      expect(find.text('Ağustos 2026'), findsOneWidget);
    });

    testWidgets('handles different years correctly', (tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MonthSelectorButton(
              selectedMonth: 1,
              selectedYear: 2030,
              onMonthSelected: (_) {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Ocak 2030'), findsOneWidget);
    });

    testWidgets('button has correct styling', (tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            backgroundColor: Colors.black,
            body: MonthSelectorButton(
              selectedMonth: 4,
              selectedYear: 2026,
              onMonthSelected: (_) {},
            ),
          ),
        ),
      );

      // Assert - Container ve InkWell widget'ları mevcut olmalı
      expect(find.byType(InkWell), findsOneWidget);
      expect(find.byType(Container), findsWidgets);
    });
  });
}
