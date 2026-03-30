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

    test('Zaman limitine göre (Son 30 gün) harcamalar listelenir', () async {
      final now = DateTime.now();
      final validDate = now.subtract(
        const Duration(days: 10),
      ); // Son 30 gün içinde
      final invalidDate = now.subtract(
        const Duration(days: 40),
      ); // Son 30 gün dışında
      final anotherValidDate = now.subtract(
        const Duration(days: 5),
      ); // Silinmiş

      await controller.setHistoryLimit(30);
      await controller.updateData(
        harcamalar: [
          {
            'kategori': 'Market',
            'tutar': 500.0,
            'tarih': validDate.toIso8601String(),
          },
          {
            'kategori': 'Ulaşım',
            'tutar': 150.0,
            'tarih': invalidDate.toIso8601String(),
          }, // Başka ay
          {
            'kategori': 'Giyim',
            'silindi': true,
            'tutar': 200.0,
            'tarih': anotherValidDate.toIso8601String(),
          }, // Silinmiş
        ],
        gelirler: [],
        varliklar: [],
        odemeYontemleri: [],
        secilenAy: now,
      );

      final currentExp = controller.currentExpenses;
      expect(currentExp.length, equals(1));
      expect(currentExp.first['kategori'], equals('Market'));

      expect(controller.totalMonthlyExpense, equals(500.0));
      expect(controller.expenseCategoryTotals['Market'], equals(500.0));
    });

    test('Gelir oranları ve toplamı doğru hesaplanır', () async {
      final now = DateTime.now();
      await controller.setHistoryLimit(30);
      await controller.updateData(
        harcamalar: [],
        gelirler: [
          Income(
            id: '1',
            name: 'Maaş Geliri',
            category: 'Maaş',
            amount: 10000.0,
            date: now.subtract(const Duration(days: 2)),
            paraBirimi: 'TRY',
            isDeleted: false,
          ),
          Income(
            id: '2',
            name: 'Hisse Senedi',
            category: 'Yatırım',
            amount: 2000.0,
            date: now.subtract(const Duration(days: 5)),
            paraBirimi: 'TRY',
            isDeleted: false,
          ),
        ],
        varliklar: [],
        odemeYontemleri: [],
        secilenAy: now,
      );

      expect(controller.totalMonthlyIncome, equals(12000.0));
      // TopIncomeCategory objesini test edelim
      expect(controller.topIncomeCategory?.key, equals('Maaş'));
      expect(controller.topIncomeCategory?.value, equals(10000.0));
    });

    test(
      'Boş veri setlerinde Exception fırlatmaz, sıfır değerler döndürür',
      () async {
        await controller.setHistoryLimit(30);
        // Boş array ve listeler
        await controller.updateData(
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

    test(
      'Edge Case: Bozuk tarih formatı, eksik veri ve extreme tutarlar (Hata Toleransı)',
      () async {
        await controller.setHistoryLimit(30);
        await controller.updateData(
          harcamalar: [
            {
              // Eksik kategori, eksik tutar, geçerli tarih
              'tarih': DateTime.now().toIso8601String(),
            },
            {
              // Bozuk tarih formatı
              'kategori': 'Market',
              'tarih': 'b0zUk-TaR1H-formati',
              'tutar': 100.0,
            },
            {
              // Negatif tutar
              'kategori': 'Fatura',
              'tarih': DateTime.now().toIso8601String(),
              'tutar': -50.0,
            },
            {
              // Çok büyük tutar (overflow & precision loss check)
              'kategori': 'Araba',
              'tarih': DateTime.now().toIso8601String(),
              'tutar': 999999999999.0,
            },
          ],
          gelirler: [],
          varliklar: [],
          odemeYontemleri: [],
          secilenAy: DateTime.now(),
        );

        // Bozuk tarihli harcama listeye alınmamalı ("invalid-date-format"), diğer 3 harcama alınmalı
        expect(controller.currentExpenses.length, equals(3));

        // Eksik kategorili harcama "Diğer" olarak atanmalı, eksik tutar 0.0 kabul edilmeli
        expect(controller.expenseCategoryTotals['Diğer'], equals(0.0));

        // Negatif tutar crash vermeden işlenebilir olmalı
        expect(controller.expenseCategoryTotals['Fatura'], equals(-50.0));

        // Büyük tutar başarılı şekilde işlenmeli
        expect(
          controller.expenseCategoryTotals['Araba'],
          equals(999999999999.0),
        );

        // Toplam aylık harcama hesabı (0 - 50 + 999999999999)
        expect(controller.totalMonthlyExpense, equals(999999999949.0));
      },
    );
  });
}
