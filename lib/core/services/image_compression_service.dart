import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

/// Image Compression Service
/// Profil resmi ve varlık görselleri için sıkıştırma ve boyutlandırma servisi.
/// Yükleme öncesi resimleri native C++ (flutter_image_compress) ile optimize ederek
/// RAM ve CPU dostu yüksek performanslı sıkıştırma sağlar.
class ImageCompressionService {
  // Varsayılan değerler
  static const int defaultMaxWidth = 800;
  static const int defaultMaxHeight = 800;
  static const int defaultQuality = 85;
  static const int thumbnailSize = 150;

  // Singleton pattern
  static final ImageCompressionService _instance = ImageCompressionService._internal();
  factory ImageCompressionService() => _instance;
  ImageCompressionService._internal();

  /// Not editörü için statik kolaylık metodu.
  ///
  /// [file] dosyasını sıkıştırıp [File] olarak döndürür.
  /// Hata durumunda orijinal dosyayı güvenle döndürür.
  static Future<File> compress(
    File file, {
    int maxWidth = defaultMaxWidth,
    int quality = defaultQuality,
  }) async {
    final service = ImageCompressionService();
    final compressedBytes = await service.compressImage(
      file,
      maxWidth: maxWidth,
      maxHeight: maxWidth, // Constraint mantığı için eşit verebiliriz, kütüphane aspect ratio korur.
      quality: quality,
    );
    if (compressedBytes == null) return file;

    try {
      final tmpDir = await getTemporaryDirectory();
      final ts = DateTime.now().millisecondsSinceEpoch;
      final out = File('${tmpDir.path}/note_img_$ts.jpg');
      await out.writeAsBytes(compressedBytes);
      return out;
    } catch (_) {
      return file;
    }
  }

  /// Resmi sıkıştır ve boyutlandır
  Future<Uint8List?> compressImage(
    File imageFile, {
    int maxWidth = defaultMaxWidth,
    int maxHeight = defaultMaxHeight,
    int quality = defaultQuality,
  }) async {
    try {
      if (!await imageFile.exists()) {
        debugPrint('ImageCompressionService: Dosya bulunamadı');
        return null;
      }

      final bytes = await imageFile.readAsBytes();

      // Boyut kontrolü - 100KB'dan küçükse sıkıştırma gereksiz
      if (bytes.length < 100 * 1024) {
        debugPrint('ImageCompressionService: Dosya zaten küçük, atlandı');
        return bytes;
      }

      // flutter_image_compress doğrudan native katmanda çalışır
      final result = await FlutterImageCompress.compressWithFile(
        imageFile.absolute.path,
        minWidth: maxWidth,
        minHeight: maxHeight,
        quality: quality,
        format: CompressFormat.jpeg,
      );

      if (result == null) {
        debugPrint('ImageCompressionService: Resim encode edilemedi');
        return bytes;
      }

      debugPrint(
        'ImageCompressionService: Sıkıştırma - '
        'Orijinal: ${_formatBytes(bytes.length)}, '
        'Sıkıştırılmış: ${_formatBytes(result.length)}',
      );

      return result;
    } catch (e, s) {
      debugPrint('ImageCompressionService hata: $e\n$s');
      try {
        return await imageFile.readAsBytes();
      } catch (_) {
        return null;
      }
    }
  }

  /// Thumbnail oluştur
  Future<Uint8List?> createThumbnail(File imageFile, {int size = thumbnailSize}) async {
    return compressImage(
      imageFile,
      maxWidth: size,
      maxHeight: size,
      quality: 70,
    );
  }

  /// Profil resmi için optimize et
  Future<Uint8List?> optimizeProfileImage(File imageFile) async {
    return compressImage(imageFile, maxWidth: 800, maxHeight: 800, quality: 75);
  }

  /// Varlık görseli için optimize et
  Future<Uint8List?> optimizeAssetImage(File imageFile) async {
    return compressImage(imageFile, maxWidth: 800, maxHeight: 800, quality: 75);
  }

  /// Profil resmini optimize et ve dosyaya kaydet
  Future<String?> optimizeAndSaveProfileImage(File imageFile) async {
    try {
      final compressedBytes = await optimizeProfileImage(imageFile);
      if (compressedBytes == null) return null;

      final directory = imageFile.parent;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final newPath = '${directory.path}/profile_$timestamp.png';

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

  Future<int> getFileSize(File file) async {
    if (await file.exists()) {
      return await file.length();
    }
    return 0;
  }

  Future<bool> deleteDirectoryIfExists(Directory dir) async {
    try {
      if (await dir.exists()) {
        await dir.delete(recursive: true);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
