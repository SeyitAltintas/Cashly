import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

/// Dosya sistemi ve medya yönetimi için statik yardımcı servis.
///
/// Kasıtlı olarak stateless tutulmuştur; Hive box referansları parametre
/// olarak alınır. Böylece NoteLocalDataSource ve SecureVaultService arasında
/// çember bağımlılık (circular dependency) oluşmaz.
class NoteMediaService {
  NoteMediaService._();

  // ─── Sandbox Path Onarma ─────────────────────────────────────────────────

  /// iOS'ta uygulama yeniden yüklendiğinde Documents dizini değişebilir.
  /// Bu metot tüm notlardaki medya yollarını güncel dizinle günceller.
  static Future<void> fixSandboxPaths(LazyBox lazyDataBox) async {
    try {
      final docsDir = await getApplicationDocumentsDirectory();
      final imgDir = Directory('${docsDir.path}/note_images');
      final vidDir = Directory('${docsDir.path}/note_videos');
      final updates = <String, String>{};

      for (final key in lazyDataBox.keys) {
        if (key == 'prefs_is_grid_view') continue;
        final deltaStr = await lazyDataBox.get(key) as String?;
        if (deltaStr == null) continue;

        bool changed = false;
        List<dynamic> ops;
        try {
          ops = jsonDecode(deltaStr) as List<dynamic>;
        } catch (_) {
          continue;
        }

        for (final op in ops) {
          if (op is! Map) continue;
          final insert = op['insert'];
          if (insert is! Map) continue;

          if (insert.containsKey('image')) {
            final mediaPath = insert['image'];
            if (mediaPath is String && !mediaPath.startsWith('http')) {
              final fileName = mediaPath.split('/').last.split('\\').last;
              final correctPath = '${imgDir.path}/$fileName';
              if (mediaPath != correctPath) {
                insert['image'] = correctPath;
                changed = true;
              }
            }
          }

          if (insert.containsKey('video')) {
            final mediaPath = insert['video'];
            if (mediaPath is String && !mediaPath.startsWith('http')) {
              final fileName = mediaPath.split('/').last.split('\\').last;
              final correctPath = '${vidDir.path}/$fileName';
              if (mediaPath != correctPath) {
                insert['video'] = correctPath;
                changed = true;
              }
            }
          }
        }

        if (changed) {
          await lazyDataBox.put(key, jsonEncode(ops));
          updates[key as String] = 'updated';
        }
      }

      if (updates.isNotEmpty) {
        debugPrint(
          'EC-26: ${updates.length} notun kırık medya yolları onarıldı.',
        );
      }
    } catch (e) {
      debugPrint('Path migration error: $e');
    }
  }

  // ─── Orphan Temizleme (Public) ────────────────────────────────────────────

  /// Aktif veya çöp kutusundaki hiçbir nota ait olmayan
  /// public resim/video dosyalarını diskten siler (EC-25).
  static Future<void> cleanOrphanImages(LazyBox lazyDataBox) async {
    try {
      final docsDir = await getApplicationDocumentsDirectory();
      final imgDir = Directory('${docsDir.path}/note_images');
      final vidDir = Directory('${docsDir.path}/note_videos');
      final activeFileNames = <String>{};

      // Aktif notlar VE çöp kutusundakiler — ikisinin medyaları da korunmalı.
      for (final key in lazyDataBox.keys) {
        try {
          final deltaStr = await lazyDataBox.get(key) as String?;
          if (deltaStr == null) continue;
          final ops = jsonDecode(deltaStr) as List<dynamic>;
          for (final op in ops) {
            if (op is! Map) continue;
            final insert = op['insert'];
            if (insert is! Map) continue;
            final mediaPath = insert['image'] ?? insert['video'];
            if (mediaPath is String && !mediaPath.startsWith('http')) {
              final fileName = mediaPath.split('/').last.split('\\').last;
              activeFileNames.add(fileName);
            }
          }
        } catch (_) {}
      }

      if (await imgDir.exists()) {
        for (final entity in imgDir.listSync()) {
          if (entity is File) {
            final fileName = entity.path.split('/').last.split('\\').last;
            if (!activeFileNames.contains(fileName)) {
              await entity.delete();
              debugPrint('EC-25: Orphan resim silindi → ${entity.path}');
            }
          }
        }
      }

      if (await vidDir.exists()) {
        for (final entity in vidDir.listSync()) {
          if (entity is File) {
            final fileName = entity.path.split('/').last.split('\\').last;
            if (!activeFileNames.contains(fileName)) {
              await entity.delete();
              debugPrint('EC-25: Orphan video silindi → ${entity.path}');
            }
          }
        }
      }
    } catch (e) {
      debugPrint('EC-25: Orphan temizleme hatası: $e');
    }
  }

  // ─── Orphan Temizleme (Güvenli Kasa) ─────────────────────────────────────

  /// GÜVENLİK: Gizli kasadaki yetim/çöp şifreli medyaları temizler.
  /// 5 dakikalık Grace Period: yeni eklenen medyalar kazayla silinmez.
  static Future<void> cleanOrphanSecureMedia({
    required LazyBox secureLazyDataBox,
    required LazyBox secureMediaBox,
  }) async {
    try {
      final activeMediaIds = <String>{};
      for (final key in secureLazyDataBox.keys) {
        final deltaStr = await secureLazyDataBox.get(key) as String?;
        if (deltaStr == null) continue;
        final ops = jsonDecode(deltaStr) as List<dynamic>;
        for (final op in ops) {
          if (op is! Map) continue;
          final insert = op['insert'];
          if (insert is! Map) continue;
          final mediaPath = insert['image'] ?? insert['video'];
          if (mediaPath is String && mediaPath.startsWith('secure-media://')) {
            activeMediaIds.add(mediaPath.replaceFirst('secure-media://', ''));
          }
        }
      }

      final allKeys = secureMediaBox.keys.toList();
      for (final key in allKeys) {
        if (!activeMediaIds.contains(key)) {
          // GÜVENLİK (EDGE CASE): Yeni oluşturulan şifreli medyaların not
          // kaydedilmeden silinmesini önlemek için 5 dk tolerans süresi.
          final timestampStr = key
              .toString()
              .replaceFirst('secure_media_', '')
              .split('.')
              .first;
          final timestamp = int.tryParse(timestampStr);
          if (timestamp != null) {
            final now = DateTime.now().microsecondsSinceEpoch;
            if (now - timestamp < 5 * 60 * 1000000) continue;
          }
          await secureMediaBox.delete(key);
          debugPrint('EC-26: Orphan şifreli medya temizlendi → $key');
        }
      }
    } catch (_) {}
  }

  // ─── Güvenli Medya Kayıt/Okuma ───────────────────────────────────────────

  /// Baytları şifreli medya kutusuna kaydeder ve `secure-media://id` URL'si döner.
  static Future<String> saveSecureMedia({
    required LazyBox secureMediaBox,
    required Uint8List bytes,
    required String extension,
  }) async {
    final id =
        'secure_media_${DateTime.now().microsecondsSinceEpoch}.$extension';
    await secureMediaBox.put(id, bytes);
    return 'secure-media://$id';
  }

  /// `secure-media://id` URL'sine karşılık gelen baytları okur.
  static Future<Uint8List?> getSecureMedia({
    required LazyBox secureMediaBox,
    required String id,
  }) async {
    return await secureMediaBox.get(id) as Uint8List?;
  }

  // ─── Medya Migrasyon ─────────────────────────────────────────────────────

  /// Public dosya yollarındaki medyaları şifreli kutoya taşır.
  /// Kullanım: not public'ten güvenli kasaya taşınırken.
  static Future<String> migrateMediaToSecure({
    required String deltaJson,
    required LazyBox secureMediaBox,
  }) async {
    if (deltaJson.isEmpty || deltaJson == '[]') return deltaJson;
    try {
      final ops = jsonDecode(deltaJson) as List<dynamic>;
      bool changed = false;

      for (final op in ops) {
        if (op is! Map) continue;
        final insert = op['insert'];
        if (insert is! Map) continue;
        final isImage = insert.containsKey('image');
        final isVideo = insert.containsKey('video');

        if (isImage || isVideo) {
          final mediaPath = isImage ? insert['image'] : insert['video'];
          if (mediaPath is String &&
              !mediaPath.startsWith('http') &&
              !mediaPath.startsWith('secure-media://')) {
            final file = File(mediaPath);
            if (await file.exists()) {
              final bytes = await file.readAsBytes();
              final ext = mediaPath.split('.').last;
              final secureUrl = await saveSecureMedia(
                secureMediaBox: secureMediaBox,
                bytes: bytes,
                extension: ext,
              );
              if (isImage) {
                insert['image'] = secureUrl;
              } else {
                insert['video'] = secureUrl;
              }
              changed = true;
            }
          }
        }
      }

      if (changed) return jsonEncode(ops);
    } catch (_) {}
    return deltaJson;
  }

  /// Şifreli medyaları public dosya sistemine taşır.
  /// Kullanım: not güvenli kasadan public'e taşınırken.
  static Future<String> migrateMediaToPublic({
    required String deltaJson,
    required LazyBox secureMediaBox,
  }) async {
    if (deltaJson.isEmpty || deltaJson == '[]') return deltaJson;
    try {
      final ops = jsonDecode(deltaJson) as List<dynamic>;
      bool changed = false;

      for (final op in ops) {
        if (op is! Map) continue;
        final insert = op['insert'];
        if (insert is! Map) continue;
        final isImage = insert.containsKey('image');
        final isVideo = insert.containsKey('video');

        if (isImage || isVideo) {
          final mediaPath = isImage ? insert['image'] : insert['video'];
          if (mediaPath is String && mediaPath.startsWith('secure-media://')) {
            final mediaId = mediaPath.replaceFirst('secure-media://', '');
            final bytes = await getSecureMedia(
              secureMediaBox: secureMediaBox,
              id: mediaId,
            );
            if (bytes != null) {
              final docsDir = await getApplicationDocumentsDirectory();
              final ext = mediaId.split('.').last;
              final isVid = ext == 'mp4';
              final folderName = isVid ? 'note_videos' : 'note_images';
              final dir = Directory('${docsDir.path}/$folderName');
              if (!await dir.exists()) await dir.create(recursive: true);
              final publicPath =
                  '${dir.path}/${DateTime.now().microsecondsSinceEpoch}.$ext';
              await File(publicPath).writeAsBytes(bytes);
              if (isImage) {
                insert['image'] = publicPath;
              } else {
                insert['video'] = publicPath;
              }
              changed = true;
            }
          }
        }
      }

      if (changed) return jsonEncode(ops);
    } catch (_) {}
    return deltaJson;
  }
}
