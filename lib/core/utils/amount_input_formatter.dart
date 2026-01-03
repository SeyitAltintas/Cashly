import 'package:flutter/services.dart';

/// Tutar giriş alanları için özel formatter
/// Binlik ayraç (nokta) ve kuruş desteği (virgül) ile
class AmountInputFormatter extends TextInputFormatter {
  // Maksimum tam kısım uzunluğu (12 hane = 999.999.999.999)
  static const int maxIntegerDigits = 12;
  // Maksimum ondalık kısım uzunluğu (2 hane = kuruş)
  static const int maxDecimalDigits = 2;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    String text = newValue.text;

    // Sadece rakam ve virgül kabul et (nokta kabul edilmiyor - binlik olarak eklenecek)
    text = text.replaceAll(RegExp(r'[^\d,]'), '');

    // Birden fazla virgül varsa sadece ilkini tut
    int commaCount = ','.allMatches(text).length;
    if (commaCount > 1) {
      int firstComma = text.indexOf(',');
      text =
          '${text.substring(0, firstComma + 1)}${text.substring(firstComma + 1).replaceAll(',', '')}';
    }

    // Tam ve ondalık kısımları ayır
    String integerPart = '';
    String decimalPart = '';
    bool hasDecimal = text.contains(',');

    if (hasDecimal) {
      final parts = text.split(',');
      integerPart = parts[0];
      if (parts.length > 1) {
        decimalPart = parts[1];
        // Max 2 hane kuruş
        if (decimalPart.length > maxDecimalDigits) {
          decimalPart = decimalPart.substring(0, maxDecimalDigits);
        }
      }
    } else {
      integerPart = text;
    }

    // Öndeki sıfırları temizle
    integerPart = integerPart.replaceFirst(RegExp(r'^0+'), '');
    if (integerPart.isEmpty) {
      integerPart = decimalPart.isNotEmpty || hasDecimal ? '0' : '';
    }

    // Maksimum uzunluk kontrolü
    if (integerPart.length > maxIntegerDigits) {
      integerPart = integerPart.substring(0, maxIntegerDigits);
    }

    // Binlik ayraç ekle
    final formattedInteger = _addThousandSeparators(integerPart);

    // Sonucu birleştir
    String result = formattedInteger;

    // Ondalık kısım varsa veya kullanıcı virgül bastıysa
    if (hasDecimal) {
      result = '$formattedInteger,$decimalPart';
    }

    // Boş sonuç kontrolü
    if (result.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    return TextEditingValue(
      text: result,
      selection: TextSelection.collapsed(offset: result.length),
    );
  }

  /// Sayıya binlik ayraç (nokta) ekler
  static String _addThousandSeparators(String value) {
    if (value.isEmpty) return value;

    final buffer = StringBuffer();
    final length = value.length;

    for (int i = 0; i < length; i++) {
      if (i > 0 && (length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(value[i]);
    }

    return buffer.toString();
  }

  /// Formatlanmış tutar metnini sayıya çevirir
  /// Örn: "1.234,56" -> 1234.56
  static double? parseFormattedAmount(String? text) {
    if (text == null || text.isEmpty) return null;

    // Noktaları kaldır (binlik ayraç)
    String cleaned = text.replaceAll('.', '');
    // Virgülü noktaya çevir (ondalık)
    cleaned = cleaned.replaceAll(',', '.');

    return double.tryParse(cleaned);
  }

  /// Tutar validation fonksiyonu
  /// Edge cases: Boş, negatif, çok büyük, geçersiz format
  static String? validateAmount(
    String? value, {
    double maxAmount = 100000000,
    bool required = true,
  }) {
    // Edge case: Boş değer
    if (value == null || value.isEmpty) {
      return required ? 'Tutar giriniz' : null;
    }

    final amount = parseFormattedAmount(value);

    // Edge case: Geçersiz sayı formatı
    if (amount == null) {
      return 'Geçerli bir tutar giriniz';
    }

    // Edge case: Sıfır veya negatif
    if (amount <= 0) {
      return 'Tutar 0\'dan büyük olmalı';
    }

    // Edge case: Maksimum değer aşımı
    if (amount > maxAmount) {
      return 'Maksimum tutar aşıldı';
    }

    return null;
  }
}
