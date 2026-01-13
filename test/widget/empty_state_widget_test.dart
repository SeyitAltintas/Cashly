import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cashly/core/widgets/empty_state_widget.dart';

void main() {
  group('EmptyStateWidget Testleri', () {
    testWidgets('Temel EmptyStateWidget oluşturulabilir', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(icon: Icons.inbox, title: 'Test Başlık'),
          ),
        ),
      );

      // Widget'ın oluşturulduğunu kontrol et
      expect(find.byType(EmptyStateWidget), findsOneWidget);

      // İkon görünür mü
      expect(find.byIcon(Icons.inbox), findsOneWidget);

      // Başlık görünür mü
      expect(find.text('Test Başlık'), findsOneWidget);
    });

    testWidgets('EmptyStateWidget subtitle gösterir', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(
              icon: Icons.inbox,
              title: 'Test Başlık',
              subtitle: 'Test Alt Başlık',
            ),
          ),
        ),
      );

      // Alt başlık görünür mü
      expect(find.text('Test Alt Başlık'), findsOneWidget);
    });

    testWidgets('EmptyStateWidget.noExpenses factory çalışır', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: EmptyStateWidget.noExpenses())),
      );

      // Widget'ın oluşturulduğunu kontrol et
      expect(find.byType(EmptyStateWidget), findsOneWidget);

      // Harcama yok mesajı görünür mü
      expect(find.text('Henüz harcama yok'), findsOneWidget);

      // İkon görünür mü
      expect(find.byIcon(Icons.receipt_long_outlined), findsOneWidget);
    });

    testWidgets('EmptyStateWidget.noIncomes factory çalışır', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: EmptyStateWidget.noIncomes())),
      );

      // Gelir yok mesajı görünür mü
      expect(find.text('Henüz gelir yok'), findsOneWidget);

      // İkon görünür mü
      expect(find.byIcon(Icons.trending_up), findsOneWidget);
    });

    testWidgets('EmptyStateWidget.noAssets factory çalışır', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: EmptyStateWidget.noAssets())),
      );

      // Varlık yok mesajı görünür mü
      expect(find.text('Henüz varlık yok'), findsOneWidget);

      // İkon görünür mü
      expect(
        find.byIcon(Icons.account_balance_wallet_outlined),
        findsOneWidget,
      );
    });

    testWidgets('EmptyStateWidget.noTransactions factory çalışır', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: EmptyStateWidget.noTransactions())),
      );

      // İşlem yok mesajı görünür mü
      expect(find.text('Henüz işlem yok'), findsOneWidget);

      // İkon görünür mü
      expect(find.byIcon(Icons.swap_horiz), findsOneWidget);
    });

    testWidgets('EmptyStateWidget aksiyon butonu gösterir', (
      WidgetTester tester,
    ) async {
      bool actionCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(
              icon: Icons.inbox,
              title: 'Test Başlık',
              actionLabel: 'Ekle',
              onAction: () => actionCalled = true,
            ),
          ),
        ),
      );

      // Buton görünür mü
      expect(find.text('Ekle'), findsOneWidget);

      // Butona tıkla
      await tester.tap(find.text('Ekle'));
      await tester.pump();

      // Callback çağrıldı mı
      expect(actionCalled, isTrue);
    });

    testWidgets('EmptyStateWidget özel iconColor kullanır', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(
              icon: Icons.inbox,
              title: 'Test Başlık',
              iconColor: Colors.purple,
            ),
          ),
        ),
      );

      // Widget'ın oluşturulduğunu kontrol et
      expect(find.byType(EmptyStateWidget), findsOneWidget);
    });
  });
}
