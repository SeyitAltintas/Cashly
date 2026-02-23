import 'package:flutter_test/flutter_test.dart';
import 'package:cashly/core/utils/validators.dart';
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

  group('Validators', () {
    group('validateEmail', () {
      test('geçerli email adresi için null döner', () {
        expect(Validators.validateEmail('test@example.com'), isNull);
        expect(Validators.validateEmail('user.name@domain.org'), isNull);
        expect(Validators.validateEmail('user123@test.co'), isNull);
      });

      test('boş email için hata mesajı döner', () {
        expect(Validators.validateEmail(null), isNotNull);
        expect(Validators.validateEmail(''), isNotNull);
        expect(Validators.validateEmail('   '), isNotNull);
      });

      test('geçersiz email formatı için hata mesajı döner', () {
        expect(Validators.validateEmail('invalid'), isNotNull);
        expect(Validators.validateEmail('no@domain'), isNotNull);
        expect(Validators.validateEmail('@nodomain.com'), isNotNull);
        expect(Validators.validateEmail('spaces in@email.com'), isNotNull);
      });
    });

    group('validatePIN', () {
      test('geçerli PIN için null döner (4-6 rakam)', () {
        expect(Validators.validatePIN('1234'), isNull);
        expect(Validators.validatePIN('12345'), isNull);
        expect(Validators.validatePIN('123456'), isNull);
      });

      test('boş PIN için hata mesajı döner', () {
        expect(Validators.validatePIN(null), isNotNull);
        expect(Validators.validatePIN(''), isNotNull);
      });

      test('çok kısa PIN için hata mesajı döner', () {
        expect(Validators.validatePIN('123'), isNotNull);
        expect(Validators.validatePIN('12'), isNotNull);
      });

      test('çok uzun PIN için hata mesajı döner', () {
        expect(Validators.validatePIN('1234567'), isNotNull);
      });

      test('rakam olmayan karakterler için hata mesajı döner', () {
        expect(Validators.validatePIN('abcd'), isNotNull);
        expect(Validators.validatePIN('12ab'), isNotNull);
        expect(Validators.validatePIN('12.34'), isNotNull);
      });
    });

    group('validateName', () {
      test('geçerli isim için null döner', () {
        expect(Validators.validateName('Ali'), isNull);
        expect(Validators.validateName('Ahmet Yılmaz'), isNull);
        expect(Validators.validateName('Ö. Demir'), isNull);
      });

      test('boş isim için hata mesajı döner', () {
        expect(Validators.validateName(null), isNotNull);
        expect(Validators.validateName(''), isNotNull);
        expect(Validators.validateName('   '), isNotNull);
      });

      test('çok kısa isim için hata mesajı döner', () {
        expect(Validators.validateName('A'), isNotNull);
      });

      test('çok uzun isim için hata mesajı döner', () {
        final longName = 'A' * 51;
        expect(Validators.validateName(longName), isNotNull);
      });
    });

    group('validateAmount', () {
      test('geçerli tutar için null döner', () {
        expect(Validators.validateAmount('100'), isNull);
        expect(Validators.validateAmount('100.50'), isNull);
        expect(Validators.validateAmount('0.01'), isNull);
        expect(Validators.validateAmount('100,50'), isNull); // Virgül desteği
      });

      test('boş tutar için hata mesajı döner', () {
        expect(Validators.validateAmount(null), isNotNull);
        expect(Validators.validateAmount(''), isNotNull);
      });

      test('negatif veya sıfır tutar için hata mesajı döner', () {
        expect(Validators.validateAmount('0'), isNotNull);
        expect(Validators.validateAmount('-10'), isNotNull);
        expect(Validators.validateAmount('-0.5'), isNotNull);
      });

      test('geçersiz format için hata mesajı döner', () {
        expect(Validators.validateAmount('abc'), isNotNull);
        expect(Validators.validateAmount('10abc'), isNotNull);
      });

      test('maksimum tutar sınırı için hata mesajı döner', () {
        expect(Validators.validateAmount('1500', maxAmount: 1000), isNotNull);
        expect(Validators.validateAmount('999', maxAmount: 1000), isNull);
      });
    });

    group('validateRequired', () {
      test('değer varsa null döner', () {
        expect(Validators.validateRequired('değer'), isNull);
        expect(Validators.validateRequired('test', fieldName: 'Alan'), isNull);
      });

      test('boş değer için hata mesajı döner', () {
        expect(Validators.validateRequired(null), isNotNull);
        expect(Validators.validateRequired(''), isNotNull);
        expect(Validators.validateRequired('   '), isNotNull);
      });

      test('özel alan adı ile hata mesajı döner', () {
        final result = Validators.validateRequired(null, fieldName: 'Kategori');
        expect(result, contains('Kategori'));
      });
    });

    group('validateDescription', () {
      test('opsiyonel alan - boş değer için null döner', () {
        expect(Validators.validateDescription(null), isNull);
        expect(Validators.validateDescription(''), isNull);
      });

      test('geçerli açıklama için null döner', () {
        expect(Validators.validateDescription('Kısa açıklama'), isNull);
      });

      test('çok uzun açıklama için hata mesajı döner', () {
        final longDesc = 'A' * 101;
        expect(
          Validators.validateDescription(longDesc, maxLength: 100),
          isNotNull,
        );
      });
    });

    group('validateItemName', () {
      test('geçerli öğe adı için null döner', () {
        expect(Validators.validateItemName('Market Alışverişi'), isNull);
      });

      test('boş öğe adı için hata mesajı döner', () {
        expect(Validators.validateItemName(null), isNotNull);
        expect(Validators.validateItemName(''), isNotNull);
      });

      test('özel öğe tipi ile hata mesajı döner', () {
        final result = Validators.validateItemName(null, itemType: 'Harcama');
        expect(result, contains('Harcama'));
      });
    });
  });
}
