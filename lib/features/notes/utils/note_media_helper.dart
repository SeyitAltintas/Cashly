import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cashly/core/extensions/l10n_extensions.dart';
import 'package:cashly/core/services/image_compression_service.dart';
import 'package:cashly/core/widgets/app_snackbar.dart';
import 'package:cashly/core/di/injection_container.dart';
import 'package:cashly/features/notes/data/repositories/note_repository.dart';

class NoteMediaHelper {
  static final ImagePicker _imagePicker = ImagePicker();
  static const int _kImageMaxWidth = 1280;
  static const int _kImageQuality = 78;

  static Future<String?> pickVideo(BuildContext context, {required bool fromCamera, bool isSecure = false}) async {
    final repo = getIt<NoteRepository>();
    repo.isMediaPicking = true;
    try {
      final XFile? picked = await _imagePicker.pickVideo(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
      );
      if (picked == null) return null;

      final parts = picked.path.split('.');
      final ext = parts.length > 1 ? parts.last : 'mp4';
      final originalFile = File(picked.path);

      if (isSecure) {
        final bytes = await originalFile.readAsBytes();
        final secureUrl = await repo.saveSecureMedia(bytes, ext);
        
        // EC-DATA-LEAK: Daima image_picker'ın cache dosyasını temizle,
        // yoksa galeriden seçilen şifreli medyaların düz kopyaları önbellekte kalır.
        if (await originalFile.exists()) {
          await originalFile.delete();
        }
        return secureUrl;
      }

      final appDir = await getApplicationDocumentsDirectory();
      final notesVidDir = Directory('${appDir.path}/note_videos');
      if (!await notesVidDir.exists()) {
        await notesVidDir.create(recursive: true);
      }
      final fileName = '${DateTime.now().microsecondsSinceEpoch}_${Random().nextInt(9000) + 1000}.$ext';
      final dest = File('${notesVidDir.path}/$fileName');
      await originalFile.copy(dest.path);
      
      // Storage Bloat'u engellemek için geçici dosyayı temizle
      if (await originalFile.exists()) {
        await originalFile.delete();
      }
      return dest.path;
    } catch (e) {
      if (context.mounted) {
        AppSnackBar.error(context, context.l10n.videoUploadError);
      }
      debugPrint('Video pick error: $e');
      return null;
    } finally {
      repo.isMediaPicking = false;
    }
  }

  static Future<String?> pickImage(BuildContext context, {bool fromCamera = false, bool isSecure = false}) async {
    final repo = getIt<NoteRepository>();
    repo.isMediaPicking = true;
    try {
      final XFile? picked = await _imagePicker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        imageQuality: 100,
      );
      if (picked == null) return null;

      final originalFile = File(picked.path);
      final File compressed = await ImageCompressionService.compress(
        originalFile,
        maxWidth: _kImageMaxWidth,
        quality: _kImageQuality,
      );

      final parts = compressed.path.split('.');
      final ext = parts.length > 1 ? parts.last : 'jpg';

      if (isSecure) {
        final bytes = await compressed.readAsBytes();
        final secureUrl = await repo.saveSecureMedia(bytes, ext);
        
        // EC-DATA-LEAK: Remove temporary compressed file to leave no trace
        if (await compressed.exists()) {
          await compressed.delete();
        }
        
        // Remove the original unencrypted image_picker cache file
        if (await originalFile.exists()) {
          await originalFile.delete();
        }
        return secureUrl;
      }

      final docsDir = await getApplicationDocumentsDirectory();
      final notesImgDir = Directory('${docsDir.path}/note_images');
      if (!notesImgDir.existsSync()) notesImgDir.createSync(recursive: true);

      final fileName = '${DateTime.now().microsecondsSinceEpoch}_${Random().nextInt(9000) + 1000}.$ext';
      final dest = File('${notesImgDir.path}/$fileName');
      await compressed.copy(dest.path);
      
      // Cleanup to prevent storage bloat
      if (await compressed.exists()) {
        await compressed.delete();
      }
      if (await originalFile.exists()) {
        await originalFile.delete();
      }
      
      // Delay slightly to ensure the file is completely flushed to disk
      // and available for FileImage to read, preventing the 'image load error' warning.
      await Future.delayed(const Duration(milliseconds: 250));

      return dest.path;
    } catch (e) {
      if (context.mounted) {
        AppSnackBar.error(context, context.l10n.imageLoadError);
      }
      return null;
    } finally {
      repo.isMediaPicking = false;
    }
  }

  static void insertMedia({
    required QuillController controller,
    required String path,
    required bool isVideo,
    VoidCallback? onMediaInserted,
  }) {
    // EC-SELECTION: Kullanıcı metni sağdan sola (ters) seçerse
    // baseOffset > extentOffset olur ve length negatif çıkar!
    // Bu yüzden start ve end kullanmalıyız.
    final index = controller.selection.start;
    final length = controller.selection.end - index;

    if (length > 0) {
      controller.document.delete(index, length);
    }

    controller.document.insert(
      index,
      isVideo ? BlockEmbed.video(path) : BlockEmbed.image(path),
    );

    controller.document.insert(index + 1, '\n');
    controller.updateSelection(
      TextSelection.collapsed(offset: index + 2),
      ChangeSource.local,
    );

    onMediaInserted?.call();
  }
}
