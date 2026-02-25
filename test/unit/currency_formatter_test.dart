import 'package:flutter_test/flutter_test.dart';
import 'package:cashly/core/services/currency_service.dart';
import 'package:cashly/core/utils/currency_formatter.dart';
import 'package:get_it/get_it.dart';

/// CurrencyFormatter testleri
/// Para birimi formatlama, sembol konumu, compact format,
/// işaretli format ve tam sayı formatı
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

  group('CurrencyFormatter.format — TRY (Varsayılan)', () {
    test('50000 → "50.000,00 ₺"', () {
      final result = CurrencyFormatter.format(50000.0);
      expect(result, contains('50.000'));
      expect(result, contains('₺'));
    });

    test('0 → "0,00 ₺"', () {
      final result = CurrencyFormatter.format(0.0);
      expect(result, contains('0,00'));
      expect(result, contains('₺'));
    });

    test('99.99 → "99,99 ₺"', () {
      final result = CurrencyFormatter.format(99.99);
      expect(result, contains('99,99'));
    });

    test('1000000 → "1.000.000,00 ₺"', () {
      final result = CurrencyFormatter.format(1000000.0);
      expect(result, contains('1.000.000'));
    });
  });

  group('CurrencyFormatter.format — USD (Prefix Sembol)', () {
    test('USD sembol başta gelir', () {
      final result = CurrencyFormatter.format(500.0, currency: 'USD');
      expect(result, startsWith(r'$'));
    });

    test('EUR sembol başta gelir', () {
      final result = CurrencyFormatter.format(500.0, currency: 'EUR');
      expect(result, startsWith('€'));
    });

    test('GBP sembol başta gelir', () {
      final result = CurrencyFormatter.format(500.0, currency: 'GBP');
      expect(result, startsWith('£'));
    });
  });

  group('CurrencyFormatter.formatWithoutSymbol', () {
    test('sembolsüz format', () {
      final result = CurrencyFormatter.formatWithoutSymbol(50000.0);
      expect(result, equals('50.000,00'));
      expect(result, isNot(contains('₺')));
      expect(result, isNot(contains(r'$')));
    });

    test('küçük tutar', () {
      final result = CurrencyFormatter.formatWithoutSymbol(1.5);
      expect(result, equals('1,50'));
    });
  });

  group('CurrencyFormatter.formatSigned', () {
    test('negatif tutar "-" ile gösterilir', () {
      final result = CurrencyFormatter.formatSigned(-500.0);
      expect(result, contains('-'));
    });

    test('pozitif tutar showPlus=true ile "+" ile gösterilir', () {
      final result = CurrencyFormatter.formatSigned(500.0, showPlus: true);
      expect(result, startsWith('+'));
    });

    test('pozitif tutar showPlus=false ile "+" olmadan', () {
      final result = CurrencyFormatter.formatSigned(500.0, showPlus: false);
      expect(result, isNot(startsWith('+')));
    });

    test('sıfır tutar', () {
      final result = CurrencyFormatter.formatSigned(0.0, showPlus: true);
      expect(result, startsWith('+'));
    });

    test('USD prefix ile signed format', () {
      final result = CurrencyFormatter.formatSigned(
        500.0,
        showPlus: true,
        currency: 'USD',
      );
      expect(result, contains(r'$'));
      expect(result, startsWith('+'));
    });
  });

  group('CurrencyFormatter.formatCompact', () {
    test('milyon: 1500000 → "1,5M ₺"', () {
      final result = CurrencyFormatter.formatCompact(1500000.0);
      expect(result, contains('1,5M'));
      expect(result, contains('₺'));
    });

    test('bin: 50000 → "50,0K ₺"', () {
      final result = CurrencyFormatter.formatCompact(50000.0);
      expect(result, contains('K'));
      expect(result, contains('₺'));
    });

    test('1000 altı normal format döner', () {
      final result = CurrencyFormatter.formatCompact(999.0);
      expect(result, isNot(contains('K')));
      expect(result, isNot(contains('M')));
    });

    test('USD compact prefix', () {
      final result = CurrencyFormatter.formatCompact(
        2000000.0,
        currency: 'USD',
      );
      expect(result, startsWith(r'$'));
      expect(result, contains('M'));
    });
  });

  group('CurrencyFormatter.formatInteger', () {
    test('ondalıksız format', () {
      final result = CurrencyFormatter.formatInteger(50001.0);
      expect(result, contains('50.001'));
      expect(result, isNot(contains(','))); // ondalık yok
    });

    test('ondalıklı değer yuvarlanır', () {
      final result = CurrencyFormatter.formatInteger(50001.7);
      expect(result, contains('50.002'));
    });
  });
}
