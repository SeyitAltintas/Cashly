import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cashly/features/payment_methods/data/models/payment_method_model.dart';
import 'package:cashly/features/settings/presentation/widgets/expense_settings/default_payment_section.dart';
import 'package:cashly/l10n/generated/app_localizations.dart';

/// DefaultPaymentSection testleri
/// ThemeManager bağımlılığı olmayan widget testi
void main() {
  group('DefaultPaymentSection - Temel Testler', () {
    testWidgets('boş ödeme listesiyle empty state göstermeli', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('tr'),
          theme: ThemeData.dark(),
          home: Scaffold(
            body: DefaultPaymentSection(
              odemeYontemleri: const [],
              varsayilanOdemeYontemiId: null,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(DefaultPaymentSection), findsOneWidget);
      expect(find.text('Varsayılan Ödeme Yöntemi'), findsOneWidget);
      expect(find.byIcon(Icons.info_outline), findsOneWidget);
    });

    testWidgets('ödeme yöntemi varken dropdown göstermeli', (tester) async {
      final testPaymentMethod = PaymentMethod(
        id: 'test-1',
        name: 'Test Kart',
        type: 'banka',
        balance: 1000,
        createdAt: DateTime.now(),
        isDeleted: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('tr'),
          theme: ThemeData.dark(),
          home: Scaffold(
            body: DefaultPaymentSection(
              odemeYontemleri: [testPaymentMethod],
              varsayilanOdemeYontemiId: null,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(DefaultPaymentSection), findsOneWidget);
      // Widget başlık ve dropdown satırında toplam 2 credit_card ikonu gösteriyor
      expect(find.byIcon(Icons.credit_card), findsNWidgets(2));
    });
  });
}
