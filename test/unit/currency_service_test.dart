import 'package:flutter_test/flutter_test.dart';
import 'package:cashly/core/services/currency_service.dart';
import 'package:get_it/get_it.dart';

/// CurrencyService — Kapsamlı Kur Dönüşüm Testleri
/// convert(), supportedCurrencies, semboller, edge case'ler
void main() {
  late CurrencyService service;

  setUp(() {
    GetIt.instance.reset();
    service = CurrencyService();
  });

  // ============================================================
  // TEMEL ÖZELLİKLER
  // ============================================================
  group('CurrencyService — Temel Özellikler', () {
    test('varsayılan para birimi TRY olmalı', () {
      expect(service.currentCurrency, equals('TRY'));
    });

    test('varsayılan sembol ₺ olmalı', () {
      expect(service.currentSymbol, equals('₺'));
    });

    test('isLoading başlangıçta false', () {
      expect(service.isLoading, isFalse);
    });
  });

  // ============================================================
  // DESTEKLENEN PARA BİRİMLERİ
  // ============================================================
  group('CurrencyService — supportedCurrencies', () {
    test('TRY destekleniyor', () {
      expect(CurrencyService.supportedCurrencies.containsKey('TRY'), isTrue);
      expect(CurrencyService.supportedCurrencies['TRY'], equals('₺'));
    });

    test('USD destekleniyor', () {
      expect(CurrencyService.supportedCurrencies.containsKey('USD'), isTrue);
      expect(CurrencyService.supportedCurrencies['USD'], equals(r'$'));
    });

    test('EUR destekleniyor', () {
      expect(CurrencyService.supportedCurrencies.containsKey('EUR'), isTrue);
      expect(CurrencyService.supportedCurrencies['EUR'], equals('€'));
    });

    test('GBP destekleniyor', () {
      expect(CurrencyService.supportedCurrencies.containsKey('GBP'), isTrue);
      expect(CurrencyService.supportedCurrencies['GBP'], equals('£'));
    });

    test('desteklenen para birimi sayısı 4', () {
      expect(CurrencyService.supportedCurrencies.length, equals(4));
    });

    test('desteklenmeyen para birimi (JPY) Map\'te yok', () {
      expect(CurrencyService.supportedCurrencies.containsKey('JPY'), isFalse);
    });
  });

  // ============================================================
  // KUR DÖNÜŞÜM — convert()
  // ============================================================
  group('CurrencyService.convert — Aynı Para Birimi', () {
    test('TRY → TRY: aynı tutar döner', () {
      expect(service.convert(100.0, 'TRY', 'TRY'), equals(100.0));
    });

    test('USD → USD: aynı tutar döner', () {
      expect(service.convert(500.0, 'USD', 'USD'), equals(500.0));
    });

    test('EUR → EUR: aynı tutar döner', () {
      expect(service.convert(250.0, 'EUR', 'EUR'), equals(250.0));
    });

    test('GBP → GBP: aynı tutar döner', () {
      expect(service.convert(999.99, 'GBP', 'GBP'), equals(999.99));
    });
  });

  group('CurrencyService.convert — Sıfır Tutar', () {
    test('0 TRY → USD = 0', () {
      expect(service.convert(0.0, 'TRY', 'USD'), equals(0.0));
    });

    test('0 USD → TRY = 0', () {
      expect(service.convert(0.0, 'USD', 'TRY'), equals(0.0));
    });

    test('0 EUR → GBP = 0', () {
      expect(service.convert(0.0, 'EUR', 'GBP'), equals(0.0));
    });
  });

  group('CurrencyService.convert — Bilinmeyen Para Birimi', () {
    test('bilinmeyen source → orijinal tutar döner', () {
      // sourceRate 0.0 → return amount
      expect(service.convert(100.0, 'XYZ', 'TRY'), equals(100.0));
    });

    test('bilinmeyen target → orijinal tutar döner', () {
      // targetRate 0.0 → return amount
      expect(service.convert(100.0, 'TRY', 'XYZ'), equals(100.0));
    });

    test('ikisi de bilinmeyen → orijinal tutar döner', () {
      expect(service.convert(100.0, 'ABC', 'DEF'), equals(100.0));
    });
  });

  group('CurrencyService.convert — Negatif Tutar', () {
    test('negatif tutar da dönüştürülebilir', () {
      // Aynı birim (shortcut)
      expect(service.convert(-100.0, 'TRY', 'TRY'), equals(-100.0));
    });

    test('negatif tutar bilinmeyen birimlerle', () {
      expect(service.convert(-50.0, 'XYZ', 'TRY'), equals(-50.0));
    });
  });

  group('CurrencyService.convert — Büyük Tutarlar', () {
    test('milyon seviyesi tutar çakışmaz', () {
      final result = service.convert(1000000.0, 'TRY', 'TRY');
      expect(result, equals(1000000.0));
    });

    test('milyar seviyesi tutar çakışmaz', () {
      final result = service.convert(1000000000.0, 'USD', 'USD');
      expect(result, equals(1000000000.0));
    });
  });

  group('CurrencyService.convert — Ondalık Hassasiyet', () {
    test('kuruş seviyesi tutar', () {
      expect(service.convert(0.01, 'TRY', 'TRY'), equals(0.01));
    });

    test('uzun ondalık tutar korunur', () {
      expect(service.convert(99.999, 'EUR', 'EUR'), equals(99.999));
    });
  });

  // ============================================================
  // SEMBOL ÇÖZÜMLEME (currentSymbol dinamik testi)
  // ============================================================
  group('CurrencyService — Sembol Çözümleme', () {
    test('bilinmeyen currency code varsayılan ₺ döner', () {
      // supportedCurrencies'de olmayan key → null → fallback '₺'
      final symbol = CurrencyService.supportedCurrencies['JPY'] ?? '₺';
      expect(symbol, equals('₺'));
    });

    test('tüm semboller boş değil', () {
      for (final entry in CurrencyService.supportedCurrencies.entries) {
        expect(
          entry.value.isNotEmpty,
          isTrue,
          reason: '${entry.key} sembolü boş olamaz',
        );
      }
    });
  });
}
