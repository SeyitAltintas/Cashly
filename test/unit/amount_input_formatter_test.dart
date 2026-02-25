import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:cashly/core/utils/amount_input_formatter.dart';

/// AmountInputFormatter testleri
/// Binlik ayraç, kuruş virgülü, parse/format round-trip, validation
void main() {
  late AmountInputFormatter formatter;

  setUp(() {
    formatter = AmountInputFormatter();
  });

  /// Helper: Yeni değer girişi simüle et
  TextEditingValue applyFormat(String text) {
    const oldValue = TextEditingValue(text: '');
    final newValue = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
    return formatter.formatEditUpdate(oldValue, newValue);
  }

  group('AmountInputFormatter — Binlik Ayraç', () {
    test('1000 → 1.000', () {
      final result = applyFormat('1000');
      expect(result.text, equals('1.000'));
    });

    test('10000 → 10.000', () {
      final result = applyFormat('10000');
      expect(result.text, equals('10.000'));
    });

    test('1000000 → 1.000.000', () {
      final result = applyFormat('1000000');
      expect(result.text, equals('1.000.000'));
    });

    test('999 → 999 (binlik ayraç yok)', () {
      final result = applyFormat('999');
      expect(result.text, equals('999'));
    });

    test('100 → 100', () {
      final result = applyFormat('100');
      expect(result.text, equals('100'));
    });
  });

  group('AmountInputFormatter — Ondalık (Virgül)', () {
    test('virgüllü giriş: 100,50', () {
      final result = applyFormat('100,50');
      expect(result.text, equals('100,50'));
    });

    test('binlik + kuruş: 1000,99', () {
      final result = applyFormat('1000,99');
      expect(result.text, equals('1.000,99'));
    });

    test('sadece virgül: 0,', () {
      final result = applyFormat('0,');
      expect(result.text, equals('0,'));
    });

    test('kuruş max 2 hane: 100,999 → 100,99', () {
      final result = applyFormat('100,999');
      expect(result.text, equals('100,99'));
    });

    test(
      'birden fazla virgül: ikinci virgül sonrası birleşir ve kuruş limiti uygulanır',
      () {
        final result = applyFormat('100,50,30');
        // İkinci virgül kaldırılır → '100,5030' → kuruş max 2 hane → '100,50'
        expect(result.text, equals('100,50'));
      },
    );
  });

  group('AmountInputFormatter — Özel Karakter Temizleme', () {
    test('harf içeren giriş temizlenir', () {
      final result = applyFormat('abc123');
      expect(result.text, equals('123'));
    });

    test('boşluk temizlenir', () {
      final result = applyFormat('1 000');
      expect(result.text, equals('1.000'));
    });

    test('özel karakterler temizlenir', () {
      final result = applyFormat('1@2#3');
      expect(result.text, equals('123'));
    });

    test('boş giriş', () {
      final result = applyFormat('');
      expect(result.text, equals(''));
    });
  });

  group('AmountInputFormatter — Öndeki Sıfırlar', () {
    test('00100 → 100', () {
      final result = applyFormat('00100');
      expect(result.text, equals('100'));
    });

    test('0,50 → 0,50 (korunur)', () {
      final result = applyFormat('0,50');
      expect(result.text, equals('0,50'));
    });
  });

  group('AmountInputFormatter.parseFormattedAmount', () {
    test('"1.234,56" → 1234.56', () {
      expect(
        AmountInputFormatter.parseFormattedAmount('1.234,56'),
        equals(1234.56),
      );
    });

    test('"50.000,00" → 50000.00', () {
      expect(
        AmountInputFormatter.parseFormattedAmount('50.000,00'),
        equals(50000.0),
      );
    });

    test('"100" → 100.0', () {
      expect(AmountInputFormatter.parseFormattedAmount('100'), equals(100.0));
    });

    test('"1.000.000" → 1000000.0', () {
      expect(
        AmountInputFormatter.parseFormattedAmount('1.000.000'),
        equals(1000000.0),
      );
    });

    test('null → null', () {
      expect(AmountInputFormatter.parseFormattedAmount(null), isNull);
    });

    test('boş string → null', () {
      expect(AmountInputFormatter.parseFormattedAmount(''), isNull);
    });
  });

  group('AmountInputFormatter.formatInitialValue', () {
    test('1234.56 → "1.234,56"', () {
      expect(
        AmountInputFormatter.formatInitialValue(1234.56),
        equals('1.234,56'),
      );
    });

    test('50000.0 → "50.000,00"', () {
      expect(
        AmountInputFormatter.formatInitialValue(50000.0),
        equals('50.000,00'),
      );
    });

    test('0.0 → "0,00"', () {
      expect(AmountInputFormatter.formatInitialValue(0.0), equals('0,00'));
    });

    test('99.9 → "99,90"', () {
      expect(AmountInputFormatter.formatInitialValue(99.9), equals('99,90'));
    });
  });

  group('AmountInputFormatter.validateAmount', () {
    test('geçerli tutar → null (hata yok)', () {
      expect(AmountInputFormatter.validateAmount('1.000,00'), isNull);
    });

    test('boş zorunlu alan → hata mesajı', () {
      expect(AmountInputFormatter.validateAmount(''), isNotNull);
      expect(AmountInputFormatter.validateAmount(null), isNotNull);
    });

    test('boş opsiyonel alan → null (hata yok)', () {
      expect(AmountInputFormatter.validateAmount('', required: false), isNull);
    });

    test('sıfır tutar → hata mesajı', () {
      final result = AmountInputFormatter.validateAmount('0');
      expect(result, isNotNull);
    });

    test('negatif tutar → hata mesajı (parse edilemez)', () {
      // Formatter negatif karakterleri temizliyor, yani bu "-100" → null parse
      final result = AmountInputFormatter.validateAmount('-100');
      // parseFormattedAmount("-100") => null (nokta/virgül treatment sonrası)
      expect(result, isNotNull);
    });

    test('maksimum aşımı → hata mesajı', () {
      final result = AmountInputFormatter.validateAmount(
        '999.999.999',
        maxAmount: 100000000,
      );
      expect(result, isNotNull);
    });

    test('geçerli büyük tutar → null', () {
      final result = AmountInputFormatter.validateAmount('99.999.999');
      expect(result, isNull);
    });
  });

  group('AmountInputFormatter — Round-trip', () {
    test('format → parse geri dönüşüm tutarlı', () {
      final formatted = AmountInputFormatter.formatInitialValue(12345.67);
      final parsed = AmountInputFormatter.parseFormattedAmount(formatted);
      expect(parsed, equals(12345.67));
    });

    test('büyük tutar round-trip', () {
      final formatted = AmountInputFormatter.formatInitialValue(1500000.0);
      final parsed = AmountInputFormatter.parseFormattedAmount(formatted);
      expect(parsed, equals(1500000.0));
    });
  });
}
