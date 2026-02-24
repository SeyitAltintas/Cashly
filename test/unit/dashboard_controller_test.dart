import 'package:flutter_test/flutter_test.dart';
import 'package:cashly/features/dashboard/presentation/controllers/dashboard_controller.dart';
import 'package:cashly/features/income/data/models/income_model.dart';
import 'package:cashly/features/payment_methods/data/models/payment_method_model.dart';
import 'package:cashly/core/services/currency_service.dart';
import 'package:get_it/get_it.dart';

void main() {
  setUpAll(() {
    if (!GetIt.instance.isRegistered<CurrencyService>()) {
      GetIt.instance.registerLazySingleton<CurrencyService>(
        () => CurrencyService(),
      );
    }
  });

  tearDownAll(() {
    GetIt.instance.reset();
  });

  group('DashboardController Local Calculation Tests', () {
    late DashboardController controller;

    setUp(() {
      controller = DashboardController();
      // Initialize without use cases, just test the fallback logic
      controller.setUserId(null);
    });

    test('Greeting mesaji saate gore degismeli', () {
      final greeting = controller.greeting;
      // greeting sadece anlik saate baglı; en azindan bir yazi dondugunu ve null olmadigini bilelim
      expect(greeting, isNotEmpty);
      expect(
        greeting == 'İyi geceler' ||
            greeting == 'Günaydın' ||
            greeting == 'İyi günler' ||
            greeting == 'İyi akşamlar',
        isTrue,
      );
    });

    test('Bütçe limit aşımı doğru kontrol edilmeli', () {
      controller.setSecilenAy(DateTime.now());

      controller.setButceLimiti(5000.0);
      controller.setHarcamalar([
        {
          'isim': 'Market',
          'tutar': 6000.0,
          'paraBirimi': 'TRY',
          'silindi': false,
          'tarih': DateTime.now().toIso8601String(),
        },
      ]);

      expect(controller.isBudgetExceeded, isTrue);
      // Aylık harcama = 6000, Limit = 5000 => Yüzde 100 olmalı (.clamp(0,100) var)
      expect(controller.budgetUsagePercentage, equals(100.0));
    });

    test('Net fark hesaplaması çalışmalı (Gelir - Gider)', () {
      controller.setSecilenAy(DateTime.now());

      controller.setHarcamalar([
        {
          'tutar': 2000.0,
          'paraBirimi': 'TRY',
          'silindi': false,
          'tarih': DateTime.now().toIso8601String(),
        },
      ]);

      controller.setGelirler([
        Income(
          id: '1',
          name: 'Maaş',
          amount: 5000.0,
          category: 'Diğer',
          date: DateTime.now(),
        ),
      ]);

      expect(controller.monthlyExpense, equals(2000.0));
      expect(controller.monthlyIncome, equals(5000.0));
      expect(controller.netDiff, equals(3000.0));
    });

    test(
      'Kredi kartı hariç totalBalance toplanır, kredi debt olarak toplanır',
      () {
        controller.setOdemeYontemleri([
          PaymentMethod(
            id: '1',
            name: 'Nakit',
            type: 'nakit',
            balance: 1000.0,
            createdAt: DateTime.now(),
          ),
          PaymentMethod(
            id: '2',
            name: 'Banka',
            type: 'banka',
            balance: 3000.0,
            createdAt: DateTime.now(),
          ),
          PaymentMethod(
            id: '3',
            name: 'Kredi Kartı',
            type: 'kredi',
            balance: 1500.0,
            limit: 5000.0,
            createdAt: DateTime.now(),
          ),
        ]);

        expect(controller.totalBalance, equals(4000.0));
        expect(controller.totalCreditDebt, equals(1500.0));
      },
    );
  });
}
