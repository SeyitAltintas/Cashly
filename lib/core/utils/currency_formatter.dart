import 'package:intl/intl.dart';

/// Para birimi formatlama yardımcı sınıfı
/// Türk Lirası formatı: 50.000,00 ₺ (binlik ayracı nokta, ondalık ayracı virgül, sembol sonda)
class CurrencyFormatter {
  // Türk formatı için NumberFormat (sembolsüz - manuel ekleyeceğiz)
  static final NumberFormat _trFormatter = NumberFormat.decimalPatternDigits(
    locale: 'tr_TR',
    decimalDigits: 2,
  );

  // Sembolsüz formatlama için (ondalıksız)
  static final NumberFormat _trFormatterNoDecimal = NumberFormat.decimalPattern(
    'tr_TR',
  );

  /// Para değerini Türk formatında döndürür (sembol sonda)
  /// Örnek: 50000.00 -> "50.000,00 ₺"
  static String format(double amount) {
    return '${_trFormatter.format(amount)} ₺';
  }

  /// Para değerini Türk formatında döndürür (sembolsüz)
  /// Örnek: 50000.00 -> "50.000,00"
  static String formatWithoutSymbol(double amount) {
    return _trFormatter.format(amount);
  }

  /// Para değerini Türk formatında döndürür (işaretli, sembol sonda)
  /// Örnek: -50000.00 -> "-50.000,00 ₺"
  /// Örnek: 50000.00 -> "+50.000,00 ₺" (showPlus true ise)
  static String formatSigned(double amount, {bool showPlus = false}) {
    final prefix = amount >= 0 && showPlus ? '+' : '';
    return '$prefix${_trFormatter.format(amount)} ₺';
  }

  /// Para değerini kısaltılmış formatta döndürür (sembol sonda)
  /// Örnek: 1500000 -> "1,5M ₺"
  /// Örnek: 50000 -> "50K ₺"
  static String formatCompact(double amount) {
    if (amount.abs() >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1).replaceAll('.', ',')}M ₺';
    } else if (amount.abs() >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1).replaceAll('.', ',')}K ₺';
    }
    return format(amount);
  }

  /// Tam sayı olarak formatla (ondalık yok, sembol sonda)
  /// Örnek: 50000.50 -> "50.001 ₺"
  static String formatInteger(double amount) {
    return '${_trFormatterNoDecimal.format(amount.round())} ₺';
  }
}
