import 'package:flutter_test/flutter_test.dart';
import 'package:cashly/core/utils/validators.dart';
import 'package:cashly/core/services/currency_service.dart';
import 'package:get_it/get_it.dart';

/// Validators unit testleri - ek testler
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

  group('Validators - Email', () {
    test('geçerli email formatını kabul etmeli', () {
      expect(Validators.validateEmail('test@example.com'), isNull);
    });

    test('geçersiz email formatını reddetmeli', () {
      expect(Validators.validateEmail('invalid-email'), isNotNull);
    });

    test('@ işareti olmayan emaili reddetmeli', () {
      expect(Validators.validateEmail('testexample.com'), isNotNull);
    });

    test('boş emaili reddetmeli', () {
      expect(Validators.validateEmail(''), isNotNull);
    });
  });

  group('Validators - Amount', () {
    test('geçerli tutarı kabul etmeli', () {
      expect(Validators.validateAmount('100'), isNull);
    });

    test('negatif tutarı reddetmeli', () {
      expect(Validators.validateAmount('-100'), isNotNull);
    });

    test('maksimum tutarı aşan değeri reddetmeli', () {
      expect(
        Validators.validateAmount('999999999', maxAmount: 1000000),
        isNotNull,
      );
    });

    test('sıfır tutarı reddetmeli', () {
      expect(Validators.validateAmount('0'), isNotNull);
    });

    test('boş tutarı reddetmeli', () {
      expect(Validators.validateAmount(''), isNotNull);
    });
  });

  group('Validators - Name', () {
    test('geçerli ismi kabul etmeli', () {
      expect(Validators.validateName('Ahmet Yılmaz'), isNull);
    });

    test('çok kısa ismi reddetmeli', () {
      expect(Validators.validateName('A'), isNotNull);
    });

    test('boş ismi reddetmeli', () {
      expect(Validators.validateName(''), isNotNull);
    });
  });
}
