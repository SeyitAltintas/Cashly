import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';

/// Image Compression Service
/// Profil resmi ve varlık görselleri için sıkıştırma ve boyutlandırma servisi.
/// Yükleme öncesi resimleri optimize ederek depolama alanından tasarruf sağlar.
class ImageCompressionService {
  // Varsayılan değerler
  static const int defaultMaxWidth = 800;
  static const int defaultMaxHeight = 800;
  static const int defaultQuality = 85;
  static const int thumbnailSize = 150;

  // Singleton pattern
  static final ImageCompressionService _instance =
      ImageCompressionService._internal();
  factory ImageCompressionService() => _instance;
  ImageCompressionService._internal();

  /// Resmi sıkıştır ve boyutlandır
  ///
  /// [imageFile] - Sıkıştırılacak resim dosyası
  /// [maxWidth] - Maksimum genişlik (varsayılan: 800)
  /// [maxHeight] - Maksimum yükseklik (varsayılan: 800)
  /// [quality] - JPEG kalitesi 0-100 (varsayılan: 85)
  ///
  /// Döndürür: Sıkıştırılmış resmin byte verileri
  Future<Uint8List?> compressImage(
    File imageFile, {
    int maxWidth = defaultMaxWidth,
    int maxHeight = defaultMaxHeight,
    int quality = defaultQuality,
  }) async {
    try {
      // Dosya var mı kontrol et
      if (!await imageFile.exists()) {
        debugPrint('ImageCompressionService: Dosya bulunamadı');
        return null;
      }

      // Orijinal dosyayı oku
      final bytes = await imageFile.readAsBytes();

      // Boyut kontrolü - 100KB'dan küçükse sıkıştırma gereksiz
      if (bytes.length < 100 * 1024) {
        debugPrint(
          'ImageCompressionService: Dosya zaten küçük, sıkıştırma atlandı',
        );
        return bytes;
      }

      // Resmi decode et
      final codec = await ui.instantiateImageCodec(
        bytes,
        targetWidth: maxWidth,
        targetHeight: maxHeight,
      );
      final frame = await codec.getNextFrame();
      final image = frame.image;

      // PNG olarak encode et (Flutter'da JPEG encode yok, PNG kullanıyoruz)
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        debugPrint('ImageCompressionService: Resim encode edilemedi');
        return bytes; // Orijinali döndür
      }

      final compressedBytes = byteData.buffer.asUint8List();

      debugPrint(
        'ImageCompressionService: Sıkıştırma tamamlandı - '
        'Orijinal: ${_formatBytes(bytes.length)}, '
        'Sıkıştırılmış: ${_formatBytes(compressedBytes.length)}',
      );

      return compressedBytes;
    } catch (e, s) {
      debugPrint('ImageCompressionService hata: $e\n$s');
      // Hata durumunda orijinal dosyayı oku ve döndür
      try {
        return await imageFile.readAsBytes();
      } catch (_) {
        return null;
      }
    }
  }

  /// Thumbnail oluştur
  ///
  /// [imageFile] - Thumbnail oluşturulacak resim dosyası
  /// [size] - Thumbnail boyutu (kare, varsayılan: 150)
  Future<Uint8List?> createThumbnail(
    File imageFile, {
    int size = thumbnailSize,
  }) async {
    return compressImage(
      imageFile,
      maxWidth: size,
      maxHeight: size,
      quality: 70,
    );
  }

  /// Profil resmi için optimize et
  /// Yüksek kaliteli kare formata sıkıştırır (800x800, %95 kalite)
  Future<Uint8List?> optimizeProfileImage(File imageFile) async {
    return compressImage(imageFile, maxWidth: 800, maxHeight: 800, quality: 95);
  }

  /// Varlık görseli için optimize et
  Future<Uint8List?> optimizeAssetImage(File imageFile) async {
    return compressImage(imageFile, maxWidth: 600, maxHeight: 600, quality: 80);
  }

  /// Profil resmini optimize et ve dosyaya kaydet
  /// Sıkıştırılmış dosyanın yolunu döndürür
  Future<String?> optimizeAndSaveProfileImage(File imageFile) async {
    try {
      final compressedBytes = await optimizeProfileImage(imageFile);
      if (compressedBytes == null) return null;

      // Yeni dosya yolu oluştur
      final directory = imageFile.parent;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final newPath = '${directory.path}/profile_$timestamp.png';

      // Sıkıştırılmış resmi kaydet
      final newFile = File(newPath);
      await newFile.writeAsBytes(compressedBytes);

      debugPrint('ImageCompressionService: Profil resmi kaydedildi - $newPath');
      return newPath;
    } catch (e) {
      debugPrint('ImageCompressionService: Profil kaydetme hatası - $e');
      return null;
    }
  }

  /// Byte boyutunu okunabilir formata çevir
  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  /// Dosya boyutunu kontrol et
  Future<int> getFileSize(File file) async {
    if (await file.exists()) {
      return await file.length();
    }
    return 0;
  }

  /// Resmin boyutlarını al
  Future<Size?> getImageDimensions(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      return Size(frame.image.width.toDouble(), frame.image.height.toDouble());
    } catch (e) {
      debugPrint('ImageCompressionService: Boyut alınamadı - $e');
      return null;
    }
  }

  /// Sıkıştırma gerekli mi kontrol et
  Future<bool> needsCompression(
    File imageFile, {
    int maxSizeKB = 500,
    int maxDimension = 1000,
  }) async {
    try {
      // Dosya boyutu kontrolü
      final fileSize = await getFileSize(imageFile);
      if (fileSize > maxSizeKB * 1024) {
        return true;
      }

      // Boyut kontrolü
      final dimensions = await getImageDimensions(imageFile);
      if (dimensions != null) {
        if (dimensions.width > maxDimension ||
            dimensions.height > maxDimension) {
          return true;
        }
      }

      return false;
    } catch (e) {
      return false;
    }
  }
}

/// Boyut sınıfı (dart:ui'den bağımsız)
class Size {
  final double width;
  final double height;

  const Size(this.width, this.height);

  @override
  String toString() => 'Size($width, $height)';
}
