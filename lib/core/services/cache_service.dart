import 'package:flutter/foundation.dart';

/// Basit in-memory cache servisi
/// Sık erişilen verileri bellekte tutarak disk I/O'yu azaltır
class CacheService {
  CacheService._();

  /// Cache deposu
  static final Map<String, _CacheEntry> _cache = {};

  /// Varsayılan cache süresi (5 dakika)
  static const Duration defaultTtl = Duration(minutes: 5);

  /// Cache'den veri okur
  /// [key] - Cache anahtarı
  /// Döndürür: Geçerli cache değeri veya null
  static T? get<T>(String key) {
    final entry = _cache[key];
    if (entry == null) return null;

    // Süresi dolmuş mu kontrol et
    if (entry.isExpired) {
      _cache.remove(key);
      debugPrint('Cache expired: $key');
      return null;
    }

    debugPrint('Cache hit: $key');
    return entry.value as T?;
  }

  /// Cache'e veri yazar
  /// [key] - Cache anahtarı
  /// [value] - Saklanacak değer
  /// [ttl] - Geçerlilik süresi (varsayılan: 5 dakika)
  static void set<T>(String key, T value, {Duration? ttl}) {
    _cache[key] = _CacheEntry(
      value: value,
      expiresAt: DateTime.now().add(ttl ?? defaultTtl),
    );
    debugPrint('Cache set: $key (TTL: ${ttl ?? defaultTtl})');
  }

  /// Belirli bir anahtarı cache'den siler
  static void invalidate(String key) {
    _cache.remove(key);
    debugPrint('Cache invalidated: $key');
  }

  /// Belirli bir prefix ile başlayan tüm anahtarları siler
  static void invalidateByPrefix(String prefix) {
    final keysToRemove = _cache.keys
        .where((k) => k.startsWith(prefix))
        .toList();
    for (final key in keysToRemove) {
      _cache.remove(key);
    }
    debugPrint(
      'Cache invalidated by prefix: $prefix (${keysToRemove.length} entries)',
    );
  }

  /// Tüm cache'i temizler
  static void clear() {
    _cache.clear();
    debugPrint('Cache cleared');
  }

  /// Cache içeriğini debug için gösterir
  static void debugPrintCache() {
    debugPrint('=== Cache Contents ===');
    for (final entry in _cache.entries) {
      debugPrint(
        '  ${entry.key}: expires in ${entry.value.expiresAt.difference(DateTime.now()).inSeconds}s',
      );
    }
    debugPrint('======================');
  }
}

/// Cache girdisi
class _CacheEntry {
  final dynamic value;
  final DateTime expiresAt;

  _CacheEntry({required this.value, required this.expiresAt});

  /// Süre dolmuş mu?
  bool get isExpired => DateTime.now().isAfter(expiresAt);
}
