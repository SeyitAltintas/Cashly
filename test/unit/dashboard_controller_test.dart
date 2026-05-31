import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:cashly/features/dashboard/presentation/controllers/dashboard_controller.dart';
import 'package:cashly/features/income/data/models/income_model.dart';
import 'package:cashly/features/payment_methods/data/models/payment_method_model.dart';
import 'package:cashly/core/services/currency_service.dart';
import 'package:get_it/get_it.dart';

class MockCurrencyService extends CurrencyService {
  String _mockCurrentCurrency = 'TRY';

  @override
  String get currentCurrency => _mockCurrentCurrency;

  @override
  Future<void> setCurrency(String currencyCode) async {
    _mockCurrentCurrency = currencyCode;
    notifyListeners();
  }
}

/// compute() isolate'inin tamamlanması için bekler.
/// (Çoklu notifyListeners çakışmalarını önlemek için güvenli bekleme)
Future<void> _waitForNotify(DashboardController ctrl) async {
  await Future.delayed(const Duration(milliseconds: 150));
}

void main() {
  setUpAll(() {
    if (!GetIt.instance.isRegistered<CurrencyService>()) {
      GetIt.instance.registerLazySingleton<CurrencyService>(
        () => MockCurrencyService(),
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
      controller.setUserId(null);
    });

    tearDown(() {
      controller.dispose();
    });

    // Not: greeting mantığı UI katmanına taşındı (_GreetingSection widget'ı).
    // DashboardController artık saat tabanlı greeting içermez.

    test('Bütçe limit aşımı doğru kontrol edilmeli', () async {
      controller.setSecilenAy(DateTime.now());
      controller.setButceLimiti(5000.0);

      final waitFuture = _waitForNotify(controller);
      controller.setHarcamalar([
        {
          'isim': 'Market',
          'tutar': 6000.0,
          'paraBirimi': 'TRY',
          'silindi': false,
          'tarih': DateTime.now().toIso8601String(),
        },
      ]);
      await waitFuture;

      expect(controller.isBudgetExceeded, isTrue);
      // Aylık harcama = 6000, Limit = 5000 => Yüzde 100 olmalı (.clamp(0,100) var)
      expect(controller.budgetUsagePercentage, equals(100.0));
    });

    test('Net fark hesaplaması çalışmalı (Gelir - Gider)', () async {
      controller.setSecilenAy(DateTime.now());

      final waitFuture1 = _waitForNotify(controller);
      controller.setHarcamalar([
        {
          'tutar': 2000.0,
          'paraBirimi': 'TRY',
          'silindi': false,
          'tarih': DateTime.now().toIso8601String(),
        },
      ]);
      await waitFuture1;

      final waitFuture2 = _waitForNotify(controller);
      controller.setGelirler([
        Income(
          id: '1',
          name: 'Maaş',
          amount: 5000.0,
          category: 'Diğer',
          date: DateTime.now(),
        ),
      ]);
      await waitFuture2;

      expect(controller.monthlyExpense, equals(2000.0));
      expect(controller.monthlyIncome, equals(5000.0));
      expect(controller.netDiff, equals(3000.0));
    });

    test(
      'Kredi kartı hariç totalBalance toplanır, kredi debt olarak toplanır',
      () async {
        final waitFuture = _waitForNotify(controller);
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
        await waitFuture;

        expect(controller.totalBalance, equals(4000.0));
        expect(controller.totalCreditDebt, equals(1500.0));
      },
    );

    test(
      'CurrencyService değiştiğinde DashboardController kendini yeniler',
      () async {
        final waitFuture1 = _waitForNotify(controller);
        controller.setOdemeYontemleri([
          PaymentMethod(
            id: '1',
            name: 'Nakit',
            type: 'nakit',
            balance: 100.0,
            createdAt: DateTime.now(),
          ),
        ]);
        await waitFuture1;

        bool wasNotified = false;
        controller.addListener(() {
          wasNotified = true;
        });

        final currencyService = GetIt.instance<CurrencyService>();
        final waitFuture2 = _waitForNotify(controller);
        await currencyService.setCurrency('USD');
        await waitFuture2;

        expect(
          wasNotified,
          isTrue,
          reason:
              'DashboardController, CurrencyService deki değişikliği dinleyip refresh atmalı',
        );

        await currencyService.setCurrency('TRY');
      },
    );
  });
}
