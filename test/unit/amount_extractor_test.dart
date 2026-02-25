import 'package:flutter_test/flutter_test.dart';
import 'package:cashly/core/services/speech/utils/amount_extractor.dart';

/// AmountExtractor testleri
/// Türkçe doğal dil ifadelerinden tutar çıkarma:
/// rakamlar, yazıyla sayılar, bin/milyon çarpanları, Türkçe binlik format
void main() {
  group('AmountExtractor — Basit Rakamlar', () {
    test('tam sayı: "100 lira"', () {
      expect(AmountExtractor.extractAmount('100 lira'), equals(100.0));
    });

    test('ondalıklı: "99,50 tl"', () {
      expect(AmountExtractor.extractAmount('99,50 tl'), equals(99.5));
    });

    test('sembollü: "250₺"', () {
      expect(AmountExtractor.extractAmount('250₺'), equals(250.0));
    });

    test('birimsiz rakam: "500"', () {
      expect(AmountExtractor.extractAmount('500'), equals(500.0));
    });

    test('cümle içinde: "markete 150 lira verdim"', () {
      expect(
        AmountExtractor.extractAmount('markete 150 lira verdim'),
        equals(150.0),
      );
    });
  });

  group('AmountExtractor — Türkçe Binlik Format', () {
    test('"10.000 lira" → 10000', () {
      expect(AmountExtractor.extractAmount('10.000 lira'), equals(10000.0));
    });

    test('"5.000 tl" → 5000', () {
      expect(AmountExtractor.extractAmount('5.000 tl'), equals(5000.0));
    });

    test('"150.000" → 150000', () {
      expect(AmountExtractor.extractAmount('150.000'), equals(150000.0));
    });

    test('"1.500.000" → 1500000', () {
      expect(AmountExtractor.extractAmount('1.500.000'), equals(1500000.0));
    });
  });

  group('AmountExtractor — "bin" Çarpanı', () {
    test('"10 bin" → 10000', () {
      expect(AmountExtractor.extractAmount('10 bin'), equals(10000.0));
    });

    test('"150 bin lira" → 150000', () {
      expect(AmountExtractor.extractAmount('150 bin lira'), equals(150000.0));
    });

    test('"1,5 bin" → 1500', () {
      expect(AmountExtractor.extractAmount('1,5 bin'), equals(1500.0));
    });

    test('sadece "bin" → 1000', () {
      expect(AmountExtractor.extractAmount('bin lira'), equals(1000.0));
    });
  });

  group('AmountExtractor — "milyon" Çarpanı', () {
    test('"2 milyon" → 2000000', () {
      expect(AmountExtractor.extractAmount('2 milyon'), equals(2000000.0));
    });

    test('"1,5 milyon" → 1500000', () {
      expect(AmountExtractor.extractAmount('1,5 milyon'), equals(1500000.0));
    });

    test('sadece "milyon" → 1000000', () {
      expect(AmountExtractor.extractAmount('milyon lira'), equals(1000000.0));
    });
  });

  group('AmountExtractor — Yazıyla Sayılar (Çarpanlı)', () {
    test('"on bin" → 10000', () {
      expect(AmountExtractor.extractAmount('on bin'), equals(10000.0));
    });

    test('"yirmi bin" → 20000', () {
      expect(AmountExtractor.extractAmount('yirmi bin'), equals(20000.0));
    });

    test('"elli bin" → 50000', () {
      expect(AmountExtractor.extractAmount('elli bin'), equals(50000.0));
    });

    test('"beş bin" → 5000', () {
      expect(AmountExtractor.extractAmount('beş bin'), equals(5000.0));
    });

    test('"üç milyon" → 3000000', () {
      expect(AmountExtractor.extractAmount('üç milyon'), equals(3000000.0));
    });

    test('"yüz bin" → 100000', () {
      expect(AmountExtractor.extractAmount('yüz bin'), equals(100000.0));
    });

    test('"iki yüz bin" → 200000', () {
      expect(AmountExtractor.extractAmount('iki yüz bin'), equals(200000.0));
    });
  });

  group('AmountExtractor — Yazıyla Bileşik Sayılar', () {
    test('"on beş bin" → 15000', () {
      expect(AmountExtractor.extractAmount('on beş bin'), equals(15000.0));
    });

    test('"yirmi üç bin" → 23000', () {
      expect(AmountExtractor.extractAmount('yirmi üç bin'), equals(23000.0));
    });

    test('"elli milyon" → 50000000', () {
      expect(AmountExtractor.extractAmount('elli milyon'), equals(50000000.0));
    });
  });

  group('AmountExtractor — Yazıyla Basit Sayılar (Çarpansız)', () {
    test('"yüz lira" → 100', () {
      expect(AmountExtractor.extractAmount('yüz lira'), equals(100.0));
    });

    test('"elli" → 50', () {
      expect(AmountExtractor.extractAmount('elli'), equals(50.0));
    });

    test('"yarım" → 0.5', () {
      expect(AmountExtractor.extractAmount('yarım'), equals(0.5));
    });

    test('"buçuk" → 0.5', () {
      expect(AmountExtractor.extractAmount('buçuk'), equals(0.5));
    });
  });

  group('AmountExtractor — Edge Cases', () {
    test('tutar bulunamayan metin → null', () {
      expect(AmountExtractor.extractAmount('merhaba dünya'), isNull);
    });

    test('boş string → null', () {
      expect(AmountExtractor.extractAmount(''), isNull);
    });
  });
}
