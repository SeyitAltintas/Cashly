import 'package:intl/intl.dart';
import '../di/injection_container.dart';
import '../services/currency_service.dart';

/// Para birimi formatlama yardımcı sınıfı
/// Sembol konumu para birimine göre değişir:
/// - TRY: sonda (50.000,00 ₺)
/// - USD, EUR, GBP: başta ($500.00, €500.00, £500.00)
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

  // Sembolün başa mı sona mı geleceğini belirleyen para birimleri
  static const Set<String> _prefixCurrencies = {'USD', 'EUR', 'GBP'};

  // Aktif para birimi kodunu getIt ile CurrencyService'ten bul
  static String get _currentCurrencyCode {
    if (getIt.isRegistered<CurrencyService>()) {
      return getIt<CurrencyService>().currentCurrency;
    }
    return 'TRY';
  }

  // Aktif sembolü getIt ile CurrencyService'ten bul
  static String get _symbol {
    if (getIt.isRegistered<CurrencyService>()) {
      return getIt<CurrencyService>().currentSymbol;
    }
    return '₺';
  }

  // Özel sembol döndürür, yoksa varsayılanı kullanır
  static String _getSymbolForCurrency(String? currencyCode) {
    if (currencyCode != null &&
        CurrencyService.supportedCurrencies.containsKey(currencyCode)) {
      return CurrencyService.supportedCurrencies[currencyCode]!;
    }
    return _symbol;
  }

  // Para birimi kodunu çöz
  static String _resolveCurrencyCode(String? currencyCode) {
    if (currencyCode != null &&
        CurrencyService.supportedCurrencies.containsKey(currencyCode)) {
      return currencyCode;
    }
    return _currentCurrencyCode;
  }

  /// Sembol ve tutarı doğru konumda birleştirir
  /// TRY: "50.000,00 ₺" (sonda)
  /// USD: "$50,000.00" (başta)
  static String _applySymbol(String formattedAmount, String? currencyCode) {
    final code = _resolveCurrencyCode(currencyCode);
    final symbol = _getSymbolForCurrency(currencyCode);

    if (_prefixCurrencies.contains(code)) {
      return '$symbol$formattedAmount';
    }
    return '$formattedAmount $symbol';
  }

  /// Para değerini formatlar (sembol konumu para birimine göre otomatik)
  /// TRY: "50.000,00 ₺"
  /// USD: "$50.000,00"
  static String format(double amount, {String? currency}) {
    return _applySymbol(_trFormatter.format(amount), currency);
  }

  /// Para değerini sembolsüz formatlar
  /// Örnek: 50000.00 -> "50.000,00"
  static String formatWithoutSymbol(double amount) {
    return _trFormatter.format(amount);
  }

  /// Para değerini işaretli formatlar (sembol konumu otomatik)
  /// TRY: "-50.000,00 ₺" / "+50.000,00 ₺"
  /// USD: "-$50.000,00" / "+$50.000,00"
  static String formatSigned(
    double amount, {
    bool showPlus = false,
    String? currency,
  }) {
    final prefix = amount >= 0 && showPlus ? '+' : '';
    final code = _resolveCurrencyCode(currency);
    final symbol = _getSymbolForCurrency(currency);
    final formatted = _trFormatter.format(amount);

    if (_prefixCurrencies.contains(code)) {
      return '$prefix$symbol$formatted';
    }
    return '$prefix$formatted $symbol';
  }

  /// Para değerini kısaltılmış formatta döndürür (sembol konumu otomatik)
  /// TRY: "1,5M ₺"  /  USD: "$1,5M"
  static String formatCompact(double amount, {String? currency}) {
    final code = _resolveCurrencyCode(currency);
    final sym = _getSymbolForCurrency(currency);
    final isPrefix = _prefixCurrencies.contains(code);

    String shortAmount;
    if (amount.abs() >= 1000000) {
      shortAmount =
          '${(amount / 1000000).toStringAsFixed(1).replaceAll('.', ',')}M';
    } else if (amount.abs() >= 1000) {
      shortAmount =
          '${(amount / 1000).toStringAsFixed(1).replaceAll('.', ',')}K';
    } else {
      return format(amount, currency: currency);
    }

    return isPrefix ? '$sym$shortAmount' : '$shortAmount $sym';
  }

  /// Tam sayı olarak formatla (ondalık yok, sembol konumu otomatik)
  /// TRY: "50.001 ₺"  /  USD: "$50,001"
  static String formatInteger(double amount, {String? currency}) {
    return _applySymbol(_trFormatterNoDecimal.format(amount.round()), currency);
  }
}
