import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';

/// Görsel önbellekleme servisi
/// Profil resimleri ve diğer görseller için yerel cache yönetimi sağlar.
///
/// Özellikler:
/// - LRU (Least Recently Used) eviction policy
/// - Byte bazlı bellek limiti (varsayılan 50MB)
/// - Disk cache desteği
/// - Otomatik bellek yönetimi
class ImageCacheService {
  static final ImageCacheService _instance = ImageCacheService._internal();
  factory ImageCacheService() => _instance;
  ImageCacheService._internal();

  String? _cacheDirPath;
  final Map<String, Uint8List> _memoryCache = {};
  final Map<String, DateTime> _accessTimes = {};

  /// Maksimum bellek cache boyutu (byte cinsinden)
  /// Varsayılan: 50MB
  static const int _maxMemoryCacheSizeBytes = 50 * 1024 * 1024; // 50MB

  /// Maksimum cache öğe sayısı
  static const int _maxCacheItems = 100;

  /// Mevcut cache boyutu (byte)
  int _currentCacheSizeBytes = 0;

  /// Cache istatistikleri
  int get memoryCacheSize => _currentCacheSizeBytes;
  int get memoryCacheItemCount => _memoryCache.length;
  double get memoryCacheUsagePercent =>
      (_currentCacheSizeBytes / _maxMemoryCacheSizeBytes) * 100;

  /// Cache dizinini başlat
  Future<void> initialize() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      _cacheDirPath = '${dir.path}/image_cache';
      final cacheDir = Directory(_cacheDirPath!);
      if (!await cacheDir.exists()) {
        await cacheDir.create(recursive: true);
      }
    } catch (e) {
      debugPrint('ImageCacheService initialize hatası: $e');
    }
  }

  /// URL'den cache key oluştur (basit hash)
  String _getCacheKey(String url) {
    // Basit hash: URL'i base64 ile encode edip dosya adına uygun hale getir
    final bytes = utf8.encode(url);
    final encoded = base64Encode(bytes);
    // Dosya adı için güvenli karakterler
    return encoded
        .replaceAll('/', '_')
        .replaceAll('+', '-')
        .replaceAll('=', '');
  }

  /// Görsel cache'den al (önce memory, sonra disk)
  Future<Uint8List?> get(String url) async {
    final key = _getCacheKey(url);

    // Önce memory cache'den bak
    if (_memoryCache.containsKey(key)) {
      // LRU: Erişim zamanını güncelle
      _accessTimes[key] = DateTime.now();
      return _memoryCache[key];
    }

    // Disk cache'den bak
    if (_cacheDirPath != null) {
      try {
        final file = File('$_cacheDirPath/$key');
        if (await file.exists()) {
          final bytes = await file.readAsBytes();
          // Memory cache'e de ekle
          _addToMemoryCache(key, bytes);
          return bytes;
        }
      } catch (e) {
        debugPrint('ImageCacheService get hatası: $e');
      }
    }

    return null;
  }

  /// Görseli cache'e kaydet
  Future<void> put(String url, Uint8List bytes) async {
    final key = _getCacheKey(url);

    // Memory cache'e ekle
    _addToMemoryCache(key, bytes);

    // Disk cache'e kaydet
    if (_cacheDirPath != null) {
      try {
        final file = File('$_cacheDirPath/$key');
        await file.writeAsBytes(bytes);
      } catch (e) {
        debugPrint('ImageCacheService put hatası: $e');
      }
    }
  }

  /// Memory cache'e ekle (LRU eviction ile)
  void _addToMemoryCache(String key, Uint8List bytes) {
    // Zaten cache'de varsa, önce eski boyutu çıkar
    if (_memoryCache.containsKey(key)) {
      _currentCacheSizeBytes -= _memoryCache[key]!.length;
    }

    // Bellek limiti kontrolü - gerekirse en eski öğeleri kaldır
    while ((_currentCacheSizeBytes + bytes.length > _maxMemoryCacheSizeBytes ||
            _memoryCache.length >= _maxCacheItems) &&
        _memoryCache.isNotEmpty) {
      _evictLeastRecentlyUsed();
    }

    // Yeni öğeyi ekle
    _memoryCache[key] = bytes;
    _accessTimes[key] = DateTime.now();
    _currentCacheSizeBytes += bytes.length;
  }

  /// En az kullanılan öğeyi kaldır (LRU eviction)
  void _evictLeastRecentlyUsed() {
    if (_accessTimes.isEmpty) return;

    // En eski erişim zamanına sahip öğeyi bul
    String? oldestKey;
    DateTime? oldestTime;

    for (final entry in _accessTimes.entries) {
      if (oldestTime == null || entry.value.isBefore(oldestTime)) {
        oldestKey = entry.key;
        oldestTime = entry.value;
      }
    }

    if (oldestKey != null && _memoryCache.containsKey(oldestKey)) {
      _currentCacheSizeBytes -= _memoryCache[oldestKey]!.length;
      _memoryCache.remove(oldestKey);
      _accessTimes.remove(oldestKey);
      debugPrint('ImageCacheService: LRU evicted $oldestKey');
    }
  }

  /// Belirli bir görseli cache'den sil
  Future<void> remove(String url) async {
    final key = _getCacheKey(url);

    if (_memoryCache.containsKey(key)) {
      _currentCacheSizeBytes -= _memoryCache[key]!.length;
      _memoryCache.remove(key);
      _accessTimes.remove(key);
    }

    if (_cacheDirPath != null) {
      try {
        final file = File('$_cacheDirPath/$key');
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        debugPrint('ImageCacheService remove hatası: $e');
      }
    }
  }

  /// Sadece memory cache'i temizle
  void clearMemoryCache() {
    _memoryCache.clear();
    _accessTimes.clear();
    _currentCacheSizeBytes = 0;
    debugPrint('ImageCacheService: Memory cache cleared');
  }

  /// Tüm cache'i temizle (memory + disk)
  Future<void> clear() async {
    clearMemoryCache();

    if (_cacheDirPath != null) {
      try {
        final cacheDir = Directory(_cacheDirPath!);
        if (await cacheDir.exists()) {
          await cacheDir.delete(recursive: true);
          await cacheDir.create();
        }
      } catch (e) {
        debugPrint('ImageCacheService clear hatası: $e');
      }
    }
  }

  /// Cache boyutunu hesapla (bytes)
  Future<int> getCacheSize() async {
    int size = _currentCacheSizeBytes;

    // Disk cache boyutu
    if (_cacheDirPath != null) {
      try {
        final cacheDir = Directory(_cacheDirPath!);
        if (await cacheDir.exists()) {
          await for (final file in cacheDir.list()) {
            if (file is File) {
              size += await file.length();
            }
          }
        }
      } catch (e) {
        debugPrint('ImageCacheService getCacheSize hatası: $e');
      }
    }

    return size;
  }

  /// Cache durumunu debug için yazdır
  void printCacheStatus() {
    debugPrint('=== ImageCacheService Status ===');
    debugPrint('Memory items: ${_memoryCache.length}/$_maxCacheItems');
    debugPrint(
      'Memory size: ${(_currentCacheSizeBytes / 1024 / 1024).toStringAsFixed(2)}MB / ${_maxMemoryCacheSizeBytes / 1024 / 1024}MB',
    );
    debugPrint('Usage: ${memoryCacheUsagePercent.toStringAsFixed(1)}%');
    debugPrint('================================');
  }
}
