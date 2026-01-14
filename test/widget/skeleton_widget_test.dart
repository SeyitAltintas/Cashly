import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cashly/core/widgets/skeleton_widget.dart';

/// SkeletonWidget testleri
/// Widget rendering testleri
void main() {
  group('SkeletonWidget', () {
    testWidgets('belirtilen boyutlarla oluşturulabilmeli', (tester) async {
      const testWidth = 100.0;
      const testHeight = 50.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SkeletonWidget(
              width: testWidth,
              height: testHeight,
              borderRadius: 12,
            ),
          ),
        ),
      );

      await tester.pump();

      // Widget'ın varlığını kontrol et
      expect(find.byType(SkeletonWidget), findsOneWidget);
    });

    testWidgets('circle modunda çalışabilmeli', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: SkeletonWidget(height: 50, isCircle: true)),
        ),
      );

      await tester.pump();

      expect(find.byType(SkeletonWidget), findsOneWidget);
    });
  });

  group('ExpenseCardSkeleton', () {
    testWidgets('oluşturulabilmeli', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: ExpenseCardSkeleton())),
      );

      await tester.pump();

      expect(find.byType(ExpenseCardSkeleton), findsOneWidget);
    });
  });

  group('IncomeCardSkeleton', () {
    testWidgets('oluşturulabilmeli', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: IncomeCardSkeleton())),
      );

      await tester.pump();

      expect(find.byType(IncomeCardSkeleton), findsOneWidget);
    });
  });

  group('PaymentMethodSkeleton', () {
    testWidgets('oluşturulabilmeli', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: PaymentMethodSkeleton())),
      );

      await tester.pump();

      expect(find.byType(PaymentMethodSkeleton), findsOneWidget);
    });
  });

  group('AssetCardSkeleton', () {
    testWidgets('oluşturulabilmeli', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: AssetCardSkeleton())),
      );

      await tester.pump();

      expect(find.byType(AssetCardSkeleton), findsOneWidget);
    });
  });

  group('AssetSummarySkeleton', () {
    testWidgets('oluşturulabilmeli', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: AssetSummarySkeleton())),
      );

      await tester.pump();

      expect(find.byType(AssetSummarySkeleton), findsOneWidget);
    });
  });

  group('Page Skeleton Testleri', () {
    testWidgets('ExpensesPageSkeleton oluşturulabilmeli', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: ExpensesPageSkeleton())),
      );

      await tester.pump();

      expect(find.byType(ExpensesPageSkeleton), findsOneWidget);
      expect(find.byType(ExpenseSummarySkeleton), findsOneWidget);
    });

    testWidgets('IncomePageSkeleton oluşturulabilmeli', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: IncomePageSkeleton())),
      );

      await tester.pump();

      expect(find.byType(IncomePageSkeleton), findsOneWidget);
      expect(find.byType(IncomeSummarySkeleton), findsOneWidget);
    });

    testWidgets('PaymentMethodsPageSkeleton oluşturulabilmeli', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: PaymentMethodsPageSkeleton())),
      );

      await tester.pump();

      expect(find.byType(PaymentMethodsPageSkeleton), findsOneWidget);
    });

    testWidgets('AssetsPageSkeleton oluşturulabilmeli', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: AssetsPageSkeleton())),
      );

      await tester.pump();

      expect(find.byType(AssetsPageSkeleton), findsOneWidget);
      expect(find.byType(AssetSummarySkeleton), findsOneWidget);
    });
  });
}
