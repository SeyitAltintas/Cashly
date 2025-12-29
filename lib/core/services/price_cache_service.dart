import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart';

/// Fiyat verilerini cache'leyen servis
/// API başarısız olduğunda son başarılı değerleri döndürür
class PriceCacheService {
  static const String _boxName = 'priceCache';
  static Box? _box;

  /// Singleton instance
  static final PriceCacheService _instance = PriceCacheService._internal();
  factory PriceCacheService() => _instance;
  PriceCacheService._internal();

  /// Cache box'ını başlat
  Future<void> init() async {
    if (_box != null && _box!.isOpen) return;
    _box = await Hive.openBox(_boxName);
    debugPrint('PriceCacheService: Cache başlatıldı');
  }

  /// Fiyatı cache'e kaydet
  Future<void> cachePrice(String key, double price) async {
    if (_box == null || !_box!.isOpen) {
      debugPrint('PriceCacheService: Box açık değil, cache atlanıyor');
      return;
    }

    await _box!.put(key, {
      'price': price,
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    });
    debugPrint('PriceCacheService: $key = $price cache\'lendi');
  }

  /// Cache'ten fiyat oku
  double? getCachedPrice(String key) {
    if (_box == null || !_box!.isOpen) return null;

    final data = _box!.get(key);
    if (data != null && data is Map) {
      final price = data['price'];
      if (price is double) {
        debugPrint('PriceCacheService: $key = $price cache\'ten okundu');
        return price;
      }
    }
    return null;
  }

  /// Son güncelleme zamanını al
  DateTime? getLastUpdateTime(String key) {
    if (_box == null || !_box!.isOpen) return null;

    final data = _box!.get(key);
    if (data != null && data is Map && data['updatedAt'] != null) {
      return DateTime.fromMillisecondsSinceEpoch(data['updatedAt'] as int);
    }
    return null;
  }

  /// Cache'in ne kadar eski olduğunu kontrol et (dakika cinsinden)
  int? getCacheAgeMinutes(String key) {
    final lastUpdate = getLastUpdateTime(key);
    if (lastUpdate == null) return null;
    return DateTime.now().difference(lastUpdate).inMinutes;
  }

  /// Tüm cache'i temizle
  Future<void> clearCache() async {
    if (_box != null && _box!.isOpen) {
      await _box!.clear();
      debugPrint('PriceCacheService: Cache temizlendi');
    }
  }

  /// Cache box'ını kapat
  Future<void> close() async {
    if (_box != null && _box!.isOpen) {
      await _box!.close();
      _box = null;
    }
  }
}
