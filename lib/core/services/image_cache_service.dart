import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';

/// Görsel önbellekleme servisi
/// Profil resimleri ve diğer görseller için yerel cache yönetimi sağlar.
class ImageCacheService {
  static final ImageCacheService _instance = ImageCacheService._internal();
  factory ImageCacheService() => _instance;
  ImageCacheService._internal();

  String? _cacheDirPath;
  final Map<String, Uint8List> _memoryCache = {};
  static const int _maxMemoryCacheSize = 50; // Maksimum 50 görsel RAM'de

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

  /// Memory cache'e ekle (LRU benzeri - en eski kaldırılır)
  void _addToMemoryCache(String key, Uint8List bytes) {
    if (_memoryCache.length >= _maxMemoryCacheSize) {
      // En eski öğeyi kaldır
      _memoryCache.remove(_memoryCache.keys.first);
    }
    _memoryCache[key] = bytes;
  }

  /// Belirli bir görseli cache'den sil
  Future<void> remove(String url) async {
    final key = _getCacheKey(url);
    _memoryCache.remove(key);

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

  /// Tüm cache'i temizle
  Future<void> clear() async {
    _memoryCache.clear();

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
    int size = 0;

    // Memory cache boyutu
    for (final bytes in _memoryCache.values) {
      size += bytes.length;
    }

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
}
