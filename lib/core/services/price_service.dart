import 'dart:convert';
import 'package:http/http.dart' as http;
import 'price_cache_service.dart';

/// Fiyat API servisi - Döviz, kripto, altın ve gümüş fiyatlarını çeker
/// Offline fallback: API başarısız olursa cache'ten okur
class PriceService {
  static const String _truncgilUrl = 'https://finans.truncgil.com/today.json';
  static const String _coingeckoBaseUrl =
      'https://api.coingecko.com/api/v3/simple/price';

  final PriceCacheService _cache = PriceCacheService();

  // Truncgil API'den veri çek
  Future<Map<String, dynamic>?> _fetchTruncgilData() async {
    try {
      final response = await http
          .get(Uri.parse(_truncgilUrl))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      // API hatası - cache'ten okunacak
    }
    return null;
  }

  // String fiyatı double'a çevir (Örn: "2.138,86" -> 2138.86 veya "42,45" -> 42.45)
  double? _parsePrice(dynamic value) {
    if (value == null) return null;
    try {
      String priceStr = value.toString();
      // $ ve boşlukları temizle
      priceStr = priceStr.replaceAll('\$', '').replaceAll(' ', '');

      // Binlik ayracı olan noktayı kaldır (varsa)
      if (priceStr.contains('.') && priceStr.contains(',')) {
        priceStr = priceStr.replaceAll('.', '');
      }

      // Virgülü noktaya çevir
      priceStr = priceStr.replaceAll(',', '.');

      return double.tryParse(priceStr);
    } catch (e) {
      return null;
    }
  }

  /// Döviz kurlarını çek
  /// Offline fallback: Cache'ten son başarılı değeri döndürür
  Future<double?> getCurrencyPrice(String currencyCode) async {
    if (currencyCode == 'TRY') return 1.0;

    final cacheKey = 'currency_$currencyCode';

    // API'den çekmeyi dene
    final data = await _fetchTruncgilData();
    if (data != null && data.containsKey(currencyCode)) {
      final price = _parsePrice(data[currencyCode]['Satış']);
      if (price != null) {
        // Başarılı - cache'e kaydet
        await _cache.cachePrice(cacheKey, price);
        return price;
      }
    }

    // API başarısız - cache'ten oku
    final cachedPrice = _cache.getCachedPrice(cacheKey);
    return cachedPrice;
  }

  /// Kripto fiyatlarını çek (CoinGecko)
  /// Offline fallback: Cache'ten son başarılı değeri döndürür
  Future<double?> getCryptoPrice(String id, {String currency = 'try'}) async {
    final cacheKey = 'crypto_${id}_$currency';

    try {
      final response = await http
          .get(Uri.parse('$_coingeckoBaseUrl?ids=$id&vs_currencies=$currency'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data[id] != null && data[id][currency] != null) {
          final price = (data[id][currency] as num).toDouble();
          // Başarılı - cache'e kaydet
          await _cache.cachePrice(cacheKey, price);
          return price;
        }
      }
    } catch (e) {
      // API hatası - cache'ten okunacak
    }

    // API başarısız - cache'ten oku
    final cachedPrice = _cache.getCachedPrice(cacheKey);
    return cachedPrice;
  }

  /// Altın fiyatlarını çek (Truncgil)
  /// Offline fallback: Cache'ten son başarılı değeri döndürür
  Future<double?> getGoldPrice(String type) async {
    final cacheKey = 'gold_$type';

    final data = await _fetchTruncgilData();

    String key = '';
    switch (type.toLowerCase()) {
      case 'gram':
        key = 'gram-altin';
        break;
      case 'çeyrek':
        key = 'ceyrek-altin';
        break;
      case 'yarım':
        key = 'yarim-altin';
        break;
      case 'tam':
        key = 'tam-altin';
        break;
      case 'cumhuriyet':
        key = 'cumhuriyet-altini';
        break;
      case 'ata':
        key = 'ata-altin';
        break;
      case 'ons':
        key = 'ons';
        break;
      default:
        key = 'gram-altin';
    }

    if (data != null && data.containsKey(key)) {
      final price = _parsePrice(data[key]['Satış']);
      if (price != null) {
        // Başarılı - cache'e kaydet
        await _cache.cachePrice(cacheKey, price);
        return price;
      }
    }

    // API başarısız - cache'ten oku
    final cachedPrice = _cache.getCachedPrice(cacheKey);
    return cachedPrice;
  }

  /// Gümüş fiyatlarını çek
  /// Offline fallback: Cache'ten son başarılı değeri döndürür
  Future<double?> getSilverPrice(String type) async {
    final cacheKey = 'silver_$type';

    final data = await _fetchTruncgilData();
    if (data != null && data.containsKey('gumus')) {
      double? gramPrice = _parsePrice(data['gumus']['Satış']);

      if (gramPrice != null) {
        double price;
        if (type == 'Ons') {
          // Gram TL * 31.1035 = Ons TL
          price = gramPrice * 31.1035;
        } else {
          price = gramPrice;
        }
        // Başarılı - cache'e kaydet
        await _cache.cachePrice(cacheKey, price);
        return price;
      }
    }

    // API başarısız - cache'ten oku
    final cachedPrice = _cache.getCachedPrice(cacheKey);
    return cachedPrice;
  }

  /// Son güncelleme zamanını al (UI için)
  DateTime? getLastPriceUpdate(String cacheKey) {
    return _cache.getLastUpdateTime(cacheKey);
  }

  /// Cache'in yaşını al (dakika cinsinden)
  int? getCacheAgeMinutes(String cacheKey) {
    return _cache.getCacheAgeMinutes(cacheKey);
  }
}
