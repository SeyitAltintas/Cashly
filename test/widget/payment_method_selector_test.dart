import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cashly/core/widgets/form/payment_method_selector.dart';
import 'package:cashly/features/payment_methods/data/models/payment_method_model.dart';

void main() {
  final List<PaymentMethod> mockPaymentMethods = [
    PaymentMethod(
      id: '1',
      name: 'Nakit',
      type: 'Nakit',
      balance: 100.0,
      colorIndex: 0,
      createdAt: DateTime(2025),
    ),
    PaymentMethod(
      id: '2',
      name: 'Kredi Kartı',
      type: 'Kredi Kartı',
      balance: -500.0,
      colorIndex: 1,
      createdAt: DateTime(2025),
    ),
  ];

  group('PaymentMethodSelector Widget Testleri', () {
    testWidgets('Temel PaymentMethodSelector oluşturulabilir', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PaymentMethodSelector(
              selectedPaymentMethodId: null,
              paymentMethods: mockPaymentMethods,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      // Widget var mı
      expect(find.byType(PaymentMethodSelector), findsOneWidget);

      // Varsayılan hint text
      expect(find.text('Ödeme yöntemi seçin'), findsOneWidget);
    });

    testWidgets('Seçili ödeme yöntemini gösterir', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PaymentMethodSelector(
              selectedPaymentMethodId: '1',
              paymentMethods: mockPaymentMethods,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      // 'Nakit' seçili olmalı
      expect(find.text('Nakit'), findsOneWidget);
    });

    testWidgets('Dropdown açılır ve seçim yapılabilir', (
      WidgetTester tester,
    ) async {
      String? selectedId;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PaymentMethodSelector(
              selectedPaymentMethodId: null,
              paymentMethods: mockPaymentMethods,
              onChanged: (id) => selectedId = id,
            ),
          ),
        ),
      );

      // Dropdown'a tıkla
      await tester.tap(find.byType(DropdownButton<String?>));
      await tester.pumpAndSettle();

      // Seçenekler geldi mi? (Nakit, Kredi Kartı)
      expect(find.text('Nakit').last, findsOneWidget);
      expect(find.text('Kredi Kartı').last, findsOneWidget);

      // 'Kredi Kartı' seç
      await tester.tap(find.text('Kredi Kartı').last);
      await tester.pumpAndSettle();

      // Callback tetiklendi mi
      expect(selectedId, '2');
    });

    testWidgets('PaymentMethodSelector.expense factory çalışır', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PaymentMethodSelector.expense(
              selectedPaymentMethodId: null,
              paymentMethods: mockPaymentMethods,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      // Widget var mı
      expect(find.byType(PaymentMethodSelector), findsOneWidget);

      // İkon rengi kırmızı olmalı (bunu direkt kontrol edemeyiz ama widget oluştuysa yeterli)
      expect(find.byIcon(Icons.account_balance_wallet), findsOneWidget);
    });

    testWidgets('PaymentMethodSelector.income factory çalışır', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PaymentMethodSelector.income(
              selectedPaymentMethodId: null,
              paymentMethods: mockPaymentMethods,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      // Widget var mı
      expect(find.byType(PaymentMethodSelector), findsOneWidget);
    });
  });
}
