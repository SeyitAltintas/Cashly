import 'package:flutter_test/flutter_test.dart';
import 'package:cashly/core/services/currency_service.dart';
import 'package:get_it/get_it.dart';

void main() {
  group('CurrencyService', () {
    late CurrencyService currencyService;

    setUp(() {
      GetIt.instance.reset(); // Her testten önce GetIt'i sıfırlıyoruz.
      currencyService = CurrencyService();
    });

    test('Varsayılan para birimi TRY olmalıdır', () {
      expect(currencyService.currentCurrency, equals('TRY'));
    });

    // Hive mocklaması yapılmadığı için DB(setCurrency) testlerini atlıyoruz.
    // Fonksiyonel `convert` yeteneğini test edelim.
    test('Aynı para birimine çevirim 1:1 oranındadır', () {
      const tutar = 100.0;

      final try2try = currencyService.convert(tutar, 'TRY', 'TRY');
      expect(try2try, equals(100.0));

      final usd2usd = currencyService.convert(tutar, 'USD', 'USD');
      expect(usd2usd, equals(100.0));
    });

    test(
      'Bilinmeyen para biriminden çevirimler default kur kullanır (veya 1:1)',
      () {
        final result = currencyService.convert(100.0, 'XYZ', 'TRY');
        expect(result, equals(100.0));
      },
    );

    test('Sıfır tutarında çevirim hep sıfırdır', () {
      expect(currencyService.convert(0.0, 'USD', 'TRY'), equals(0.0));
    });
  });
}
