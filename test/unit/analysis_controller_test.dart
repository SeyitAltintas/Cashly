import 'package:flutter_test/flutter_test.dart';
import 'package:cashly/features/analysis/presentation/controllers/analysis_controller.dart';
import 'package:cashly/core/services/currency_service.dart';
import 'package:cashly/features/income/data/models/income_model.dart';
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

  group('AnalysisController Tests', () {
    late AnalysisController controller;

    setUp(() {
      controller = AnalysisController();
    });

    test('Ocak ayındaki harcamalar sadece o ayı listeler', () {
      controller.setSecilenAy(DateTime(2025, 1, 15));
      controller.updateData(
        harcamalar: [
          {
            'kategori': 'Market',
            'tutar': 500.0,
            'tarih': DateTime(2025, 1, 10).toIso8601String(),
          },
          {
            'kategori': 'Ulaşım',
            'tutar': 150.0,
            'tarih': DateTime(2024, 12, 5).toIso8601String(),
          }, // Başka ay
          {
            'kategori': 'Giyim',
            'silindi': true,
            'tutar': 200.0,
            'tarih': DateTime(2025, 1, 20).toIso8601String(),
          }, // Silinmiş
        ],
        gelirler: [],
        varliklar: [],
        odemeYontemleri: [],
        secilenAy: DateTime(2025, 1, 15),
      );

      final monthlyExp = controller.monthlyExpenses;
      expect(monthlyExp.length, equals(1));
      expect(monthlyExp.first['kategori'], equals('Market'));

      expect(controller.totalMonthlyExpense, equals(500.0));
      expect(controller.expenseCategoryTotals['Market'], equals(500.0));
    });

    test('Gelir oranları ve toplamı doğru hesaplanır', () {
      controller.setSecilenAy(DateTime(2025, 1, 15));
      controller.updateData(
        harcamalar: [],
        gelirler: [
          Income(
            id: '1',
            name: 'Maaş Geliri',
            category: 'Maaş',
            amount: 10000.0,
            date: DateTime(2025, 1, 10),
            paraBirimi: 'TRY',
            isDeleted: false,
          ),
          Income(
            id: '2',
            name: 'Hisse Senedi',
            category: 'Yatırım',
            amount: 2000.0,
            date: DateTime(2025, 1, 12),
            paraBirimi: 'TRY',
            isDeleted: false,
          ),
        ],
        varliklar: [],
        odemeYontemleri: [],
        secilenAy: DateTime(2025, 1, 15),
      );

      expect(controller.totalMonthlyIncome, equals(12000.0));
      // TopIncomeCategory objesini test edelim
      expect(controller.topIncomeCategory?.key, equals('Maaş'));
      expect(controller.topIncomeCategory?.value, equals(10000.0));
    });

    test(
      'Boş veri setlerinde Exception fırlatmaz, sıfır değerler döndürür',
      () {
        controller.setSecilenAy(DateTime.now());
        // Boş array ve listeler
        controller.updateData(
          harcamalar: [],
          gelirler: [],
          varliklar: [],
          odemeYontemleri: [],
          secilenAy: DateTime.now(),
        );

        expect(controller.totalMonthlyExpense, equals(0.0));
        expect(controller.totalMonthlyIncome, equals(0.0));
        expect(controller.totalAssetValue, equals(0.0));
        expect(controller.topExpenseCategory, isNull);
        expect(controller.topIncomeCategory, isNull);
      },
    );

    test('Grafik sekme değişimi (Tab Index) doğru index günceller', () {
      expect(
        controller.currentTabIndex,
        equals(0),
      ); // Varsayılan Harcama sekmesi
      controller.setTabIndex(1);
      expect(controller.currentTabIndex, equals(1)); // Gelir sekmesi
      controller.setTabIndex(2);
      expect(controller.currentTabIndex, equals(2)); // Varlıklar sekmesi

      // Touched index (pasta dilimine tıklanma) sıfırlanmalıdır.
      controller.setTouchedIndex(3);
      controller.setTabIndex(0);
      expect(controller.touchedIndex, equals(-1));
    });
  });
}
