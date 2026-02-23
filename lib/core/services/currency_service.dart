import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;

class CurrencyService extends ChangeNotifier {
  static const String _boxName = 'settings';
  static const String _currencyKey = 'app_currency';
  static const String _ratesKey = 'exchange_rates';
  static const String _lastUpdateKey = 'exchange_rates_last_update';

  // Desteklenen para birimleri ve sembolleri
  static const Map<String, String> supportedCurrencies = {
    'TRY': '₺',
    'USD': '\$',
    'EUR': '€',
    'GBP': '£',
  };

  late Box _box;
  String _currentCurrency = 'TRY';
  Map<String, double> _rates = {'TRY': 1.0};
  bool _isLoading = false;

  String get currentCurrency => _currentCurrency;
  String get currentSymbol => supportedCurrencies[_currentCurrency] ?? '₺';
  bool get isLoading => _isLoading;

  Future<void> init() async {
    _box = await Hive.openBox(_boxName);
    _currentCurrency = _box.get(_currencyKey, defaultValue: 'TRY') as String;

    // Cache'den kurları yükle
    final cachedRates = _box.get(_ratesKey);
    if (cachedRates != null) {
      _rates = Map<String, double>.from(jsonDecode(cachedRates as String));
    } else {
      // Sinyal yoksa daima kendi para birimi 1.0 olsun
      for (var key in supportedCurrencies.keys) {
        _rates[key] = key == 'TRY' ? 1.0 : 0.0;
      }
    }

    _fetchRatesIfNeeded();
  }

  Future<void> setCurrency(String currencyCode) async {
    if (supportedCurrencies.containsKey(currencyCode) &&
        _currentCurrency != currencyCode) {
      _currentCurrency = currencyCode;
      await _box.put(_currencyKey, currencyCode);
      notifyListeners();

      // Kurları güncel tutmak için
      _fetchRatesIfNeeded(force: true);
    }
  }

  // Live Exchange Rates via free API (base is USD, but we calculate relative)
  Future<void> _fetchRatesIfNeeded({bool force = false}) async {
    final lastUpdateStr = _box.get(_lastUpdateKey) as String?;
    DateTime? lastUpdate;
    if (lastUpdateStr != null) {
      lastUpdate = DateTime.tryParse(lastUpdateStr);
    }

    // Günde en fazla 1 kez güncelle (veya force ile zorla)
    if (!force &&
        lastUpdate != null &&
        DateTime.now().difference(lastUpdate).inHours < 12) {
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      // ExchangeRate-API is a reliable free endpoint
      final response = await http.get(
        Uri.parse('https://api.exchangerate-api.com/v4/latest/USD'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final fetchedRates = data['rates'] as Map<String, dynamic>;

        // Sadece desteklenenleri al
        final Map<String, double> newRates = {};
        for (var code in supportedCurrencies.keys) {
          if (fetchedRates.containsKey(code)) {
            newRates[code] = (fetchedRates[code] as num).toDouble();
          }
        }

        if (newRates.isNotEmpty) {
          _rates = newRates;
          await _box.put(_ratesKey, jsonEncode(_rates));
          await _box.put(_lastUpdateKey, DateTime.now().toIso8601String());
        }
      }
    } catch (e) {
      debugPrint('Döviz kurları alınamadı: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Verilen tutarı hedef para birimine çevirir.
  /// İşlemler "Global Tek Ayar" mantığına uygundur.
  /// Örn: source TRY, target USD -> amount / tryRate * usdRate
  double convert(double amount, String sourceCurrency, String targetCurrency) {
    if (sourceCurrency == targetCurrency) return amount;

    final sourceRate = _rates[sourceCurrency] ?? 0.0;
    final targetRate = _rates[targetCurrency] ?? 0.0;

    if (sourceRate == 0.0 || targetRate == 0.0) return amount;

    // Base API is USD (1.0).
    // USD -> TRY = amount * tryRate
    // TRY -> USD = amount / tryRate
    // TRY -> EUR = (amount / tryRate) * eurRate
    final amountInUsd = amount / sourceRate;
    return amountInUsd * targetRate;
  }
}
