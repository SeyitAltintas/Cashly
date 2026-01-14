import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cashly/features/expenses/presentation/widgets/expense_summary_card.dart';
import 'package:cashly/features/income/presentation/widgets/income_summary_card.dart';
import 'package:cashly/features/assets/presentation/widgets/asset_summary_card.dart';

/// Summary Card Widget Testleri
/// Özet kartlarının doğru şekilde render edildigini test eder
void main() {
  group('ExpenseSummaryCard Testleri', () {
    testWidgets('widget oluşturulabilmeli', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExpenseSummaryCard(
              ayIsmi: 'Ocak 2026',
              toplamTutar: 5000.0,
              butceLimiti: 10000.0,
              oncekiAy: () {},
              sonrakiAy: () {},
              ayYilSeciciAc: () {},
              secilenAy: DateTime(2026, 1, 1),
              harcamalar: const [],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(ExpenseSummaryCard), findsOneWidget);
    });

    testWidgets('toplam harcama gösterilmeli', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExpenseSummaryCard(
              ayIsmi: 'Ocak 2026',
              toplamTutar: 5000.0,
              butceLimiti: 10000.0,
              oncekiAy: () {},
              sonrakiAy: () {},
              ayYilSeciciAc: () {},
              secilenAy: DateTime(2026, 1, 1),
              harcamalar: const [],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // "TOPLAM HARCAMA" etiketi görünür mü
      expect(find.text('TOPLAM HARCAMA'), findsOneWidget);
    });

    testWidgets('ay navigasyonu çalışmalı', (tester) async {
      bool oncekiAyCagirildi = false;
      bool sonrakiAyCagirildi = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExpenseSummaryCard(
              ayIsmi: 'Ocak 2026',
              toplamTutar: 5000.0,
              butceLimiti: 10000.0,
              oncekiAy: () => oncekiAyCagirildi = true,
              sonrakiAy: () => sonrakiAyCagirildi = true,
              ayYilSeciciAc: () {},
              secilenAy: DateTime(2026, 1, 1),
              harcamalar: const [],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Sol oka tıkla
      await tester.tap(find.byIcon(Icons.chevron_left));
      await tester.pump();
      expect(oncekiAyCagirildi, isTrue);

      // Sağ oka tıkla
      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.pump();
      expect(sonrakiAyCagirildi, isTrue);
    });

    testWidgets('carousel PageView ve page indicator içermeli', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExpenseSummaryCard(
              ayIsmi: 'Ocak 2026',
              toplamTutar: 5000.0,
              butceLimiti: 10000.0,
              oncekiAy: () {},
              sonrakiAy: () {},
              ayYilSeciciAc: () {},
              secilenAy: DateTime(2026, 1, 1),
              harcamalar: const [],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // PageView bulunmalı (carousel yapısı)
      expect(find.byType(PageView), findsOneWidget);

      // İlk sayfa görünür olmalı
      expect(find.text('TOPLAM HARCAMA'), findsOneWidget);
    });
  });

  group('IncomeSummaryCard Testleri', () {
    testWidgets('widget oluşturulabilmeli', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IncomeSummaryCard(
              ayIsmi: 'Ocak 2026',
              toplamGelir: 15000.0,
              oncekiAy: () {},
              sonrakiAy: () {},
              ayYilSeciciAc: () {},
              gelirSayisi: 5,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(IncomeSummaryCard), findsOneWidget);
    });

    testWidgets('toplam gelir gösterilmeli', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IncomeSummaryCard(
              ayIsmi: 'Ocak 2026',
              toplamGelir: 15000.0,
              oncekiAy: () {},
              sonrakiAy: () {},
              ayYilSeciciAc: () {},
              gelirSayisi: 5,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // TOPLAM GELİR etiketi görünür mü
      expect(find.text('TOPLAM GELİR'), findsOneWidget);
    });
  });

  group('AssetSummaryCard Testleri', () {
    testWidgets('widget oluşturulabilmeli', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AssetSummaryCard(totalAssets: 50000.0, assetCount: 5),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(AssetSummaryCard), findsOneWidget);
    });

    testWidgets('toplam varlık ve sayı gösterilmeli', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AssetSummaryCard(totalAssets: 50000.0, assetCount: 5),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // TOPLAM VARLIK etiketi görünür mü
      expect(find.text('TOPLAM VARLIK'), findsOneWidget);
    });
  });
}
