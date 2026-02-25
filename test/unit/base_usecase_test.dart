import 'package:flutter_test/flutter_test.dart';
import 'package:cashly/core/domain/usecases/base_usecase.dart';

/// Base Use Case ve Result pattern testleri
/// NoParams, Result.success/failure, Result.fold
void main() {
  group('NoParams', () {
    test('const constructor', () {
      const params1 = NoParams();
      const params2 = NoParams();
      expect(params1, isNotNull);
      expect(params2, isNotNull);
    });
  });

  group('Result — Success', () {
    test('success factory doğru alanları set eder', () {
      final result = Result<int>.success(42);

      expect(result.isSuccess, isTrue);
      expect(result.data, equals(42));
      expect(result.error, isNull);
    });

    test('success String tipinde', () {
      final result = Result<String>.success('merhaba');

      expect(result.isSuccess, isTrue);
      expect(result.data, equals('merhaba'));
    });

    test('success List tipinde', () {
      final result = Result<List<int>>.success([1, 2, 3]);

      expect(result.isSuccess, isTrue);
      expect(result.data, equals([1, 2, 3]));
    });

    test('success Map tipinde', () {
      final result = Result<Map<String, dynamic>>.success({'key': 'value'});

      expect(result.isSuccess, isTrue);
      expect(result.data!['key'], equals('value'));
    });
  });

  group('Result — Failure', () {
    test('failure factory doğru alanları set eder', () {
      final result = Result<int>.failure('Bir hata oluştu');

      expect(result.isSuccess, isFalse);
      expect(result.error, equals('Bir hata oluştu'));
      expect(result.data, isNull);
    });

    test('failure boş mesaj', () {
      final result = Result<String>.failure('');

      expect(result.isSuccess, isFalse);
      expect(result.error, equals(''));
    });
  });

  group('Result.fold', () {
    test('success durumunda onSuccess çağrılır', () {
      final result = Result<int>.success(42);

      final value = result.fold(
        onSuccess: (data) => 'Başarılı: $data',
        onFailure: (error) => 'Hata: $error',
      );

      expect(value, equals('Başarılı: 42'));
    });

    test('failure durumunda onFailure çağrılır', () {
      final result = Result<int>.failure('Veri bulunamadı');

      final value = result.fold(
        onSuccess: (data) => 'Başarılı: $data',
        onFailure: (error) => 'Hata: $error',
      );

      expect(value, equals('Hata: Veri bulunamadı'));
    });

    test('fold farklı dönüş tipi (int)', () {
      final result = Result<String>.success('test');

      final length = result.fold<int>(
        onSuccess: (data) => data.length,
        onFailure: (error) => -1,
      );

      expect(length, equals(4));
    });

    test('fold farklı dönüş tipi failure', () {
      final result = Result<String>.failure('hata');

      final length = result.fold<int>(
        onSuccess: (data) => data.length,
        onFailure: (error) => -1,
      );

      expect(length, equals(-1));
    });
  });

  group('Result — Tip Güvenliği', () {
    test('double tipinde result', () {
      final result = Result<double>.success(3.14);
      expect(result.data, isA<double>());
      expect(result.data, equals(3.14));
    });

    test('bool tipinde result', () {
      final result = Result<bool>.success(true);
      expect(result.data, isA<bool>());
      expect(result.data, isTrue);
    });

    test('nullable data success', () {
      // data != null koşulu nedeniyle fold onSuccess çağrılır
      final result = Result<int>.success(0);
      final value = result.fold(
        onSuccess: (data) => data,
        onFailure: (error) => -1,
      );
      expect(value, equals(0));
    });
  });
}
