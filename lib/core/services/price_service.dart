import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class PriceService {
  static const String _truncgilUrl = 'https://finans.truncgil.com/today.json';
  static const String _coingeckoBaseUrl =
      'https://api.coingecko.com/api/v3/simple/price';

  // Truncgil API'den veri çek
  Future<Map<String, dynamic>?> _fetchTruncgilData() async {
    try {
      final response = await http.get(Uri.parse(_truncgilUrl));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      debugPrint('Truncgil API hatası: $e');
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
      // Örn: 2.138,86 -> 2138,86
      // Ancak API bazen 42,45 veriyor (nokta yok).
      // Truncgil formatı genelde: Binlik nokta, ondalık virgül.

      if (priceStr.contains('.') && priceStr.contains(',')) {
        priceStr = priceStr.replaceAll('.', '');
      }

      // Virgülü noktaya çevir
      priceStr = priceStr.replaceAll(',', '.');

      return double.tryParse(priceStr);
    } catch (e) {
      debugPrint('Parse hatası ($value): $e');
      return null;
    }
  }

  // Döviz kurlarını çek
  Future<double?> getCurrencyPrice(String currencyCode) async {
    if (currencyCode == 'TRY') return 1.0;

    final data = await _fetchTruncgilData();
    if (data != null && data.containsKey(currencyCode)) {
      // Satış fiyatını al
      return _parsePrice(data[currencyCode]['Satış']);
    }
    return null;
  }

  // Kripto fiyatlarını çek (CoinGecko - Değişmedi)
  Future<double?> getCryptoPrice(String id, {String currency = 'try'}) async {
    try {
      final response = await http.get(
        Uri.parse('$_coingeckoBaseUrl?ids=$id&vs_currencies=$currency'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data[id] != null && data[id][currency] != null) {
          return (data[id][currency] as num).toDouble();
        }
      }
    } catch (e) {
      debugPrint('Kripto hatası ($id): $e');
    }
    return null;
  }

  // Altın fiyatlarını çek (Direkt Truncgil'den)
  Future<double?> getGoldPrice(String type) async {
    final data = await _fetchTruncgilData();
    if (data == null) return null;

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

    if (data.containsKey(key)) {
      double? price = _parsePrice(data[key]['Satış']);
      // Ons fiyatı zaten USD geliyor, çevirmeye gerek yok.
      // Diğerleri TL geliyor.
      return price;
    }
    return null;
  }

  // Gümüş fiyatlarını çek
  Future<double?> getSilverPrice(String type) async {
    final data = await _fetchTruncgilData();
    if (data != null && data.containsKey('gumus')) {
      double? gramPrice = _parsePrice(data['gumus']['Satış']);

      if (gramPrice != null) {
        if (type == 'Ons') {
          // Gümüş ons genelde USD takip edilir ama Truncgil 'gumus' genelde gram TL verir.
          // API'de 'gumus' -> "71,25" (TL).
          // Ons istenirse: Gram TL / USD Kuru * 31.1035 = Ons USD?
          // Veya direkt Gram TL * 31.1035 = Ons TL.
          // Kullanıcı Ons fiyatını USD mi bekliyor TL mi?
          // Altın Ons USD idi. Gümüş Ons da USD beklenebilir.
          // Ancak basitlik için TL karşılığını verelim veya USD'ye çevirelim.
          // Şimdilik Ons TL olarak hesaplayalım:
          return gramPrice * 31.1035;
        } else {
          return gramPrice;
        }
      }
    }
    return null;
  }
}
