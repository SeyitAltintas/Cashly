import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Basit persistent cache servisi
/// Sık erişilen verileri bellekte ve diskte tutarak 0-frame gecikme sağlar
class CacheService {
  CacheService._();

  static const String _boxName = 'app_cache_box';
  static final Map<String, _CacheEntry> _cache = {};
  static const Duration defaultTtl = Duration(minutes: 5);

  static Future<void> init() async {
    final box = await Hive.openBox(_boxName);
    
    // Diskten belleğe yükle
    for (final key in box.keys) {
      try {
        final jsonStr = box.get(key);
        if (jsonStr != null) {
          final map = jsonDecode(jsonStr);
          final expiresAt = DateTime.tryParse(map['expiresAt'] ?? '');
          
          if (expiresAt != null) {
            if (DateTime.now().isAfter(expiresAt)) {
              box.delete(key);
            } else {
              _cache[key.toString()] = _CacheEntry(
                value: map['value'],
                expiresAt: expiresAt,
              );
            }
          }
        }
      } catch (e) {
        // Hatalı/Eski formatları temizle
        box.delete(key);
      }
    }
  }

  static T? get<T>(String key) {
    final entry = _cache[key];
    if (entry == null) return null;

    if (entry.isExpired) {
      _cache.remove(key);
      try {
        if (Hive.isBoxOpen(_boxName)) {
          Hive.box(_boxName).delete(key);
        }
      } catch (_) {}
      return null;
    }

    try {
      if (T.toString().contains('List<Map<String, dynamic>>')) {
        return (entry.value as List)
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList() as T;
      }
      return entry.value as T?;
    } catch (e) {
      return entry.value as T?;
    }
  }

  static void set<T>(String key, T value, {Duration? ttl}) {
    final entry = _CacheEntry(
      value: value,
      expiresAt: DateTime.now().add(ttl ?? defaultTtl),
    );
    _cache[key] = entry;
    
    if (Hive.isBoxOpen(_boxName)) {
      // GÜVENLİK/PERFORMANS YAMASI (ANR FIX): 
      // jsonEncode senkron çalışarak ana thread'i bloke ettiği için ANR'a sebep oluyordu.
      // Compute ile ayrı bir Isolate'e taşıyoruz. (Memory cache hemen güncellenir, disk yazması arkada asenkron biter.)
      compute(_encodeJson, {
        'value': value,
        'expiresAt': entry.expiresAt.toIso8601String(),
      }).then((jsonStr) {
        try {
          if (Hive.isBoxOpen(_boxName)) {
            Hive.box(_boxName).put(key, jsonStr);
          }
        } catch (_) {}
      }).catchError((_) {});
    }
  }

  // Top-level function for compute
  static String _encodeJson(Map<String, dynamic> data) {
    return jsonEncode(data);
  }

  static void invalidate(String key) {
    _cache.remove(key);
    try {
      if (Hive.isBoxOpen(_boxName)) Hive.box(_boxName).delete(key);
    } catch (_) {}
  }

  static void invalidateByPrefix(String prefix) {
    final keysToRemove = _cache.keys.where((k) => k.startsWith(prefix)).toList();
    for (final key in keysToRemove) {
      _cache.remove(key);
      try {
        if (Hive.isBoxOpen(_boxName)) Hive.box(_boxName).delete(key);
      } catch (_) {}
    }
  }

  static void clear() {
    _cache.clear();
    try {
      if (Hive.isBoxOpen(_boxName)) Hive.box(_boxName).clear();
    } catch (_) {}
  }

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

class _CacheEntry {
  final dynamic value;
  final DateTime expiresAt;

  _CacheEntry({required this.value, required this.expiresAt});

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}
