import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cashly/core/extensions/l10n_extensions.dart';
import 'package:cashly/core/services/image_compression_service.dart';
import 'package:cashly/core/widgets/app_snackbar.dart';

class NoteMediaHelper {
  static final ImagePicker _imagePicker = ImagePicker();
  static const int _kImageMaxWidth = 1280;
  static const int _kImageQuality = 78;

  static Future<String?> pickVideo(BuildContext context, {required bool fromCamera}) async {
    try {
      final XFile? picked = await _imagePicker.pickVideo(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
      );
      if (picked == null) return null;

      final appDir = await getApplicationDocumentsDirectory();
      final notesVidDir = Directory('${appDir.path}/note_videos');
      if (!await notesVidDir.exists()) {
        await notesVidDir.create(recursive: true);
      }
      final parts = picked.path.split('.');
      final ext = parts.length > 1 ? parts.last : 'mp4';
      final fileName = '${DateTime.now().microsecondsSinceEpoch}_${Random().nextInt(9000) + 1000}.$ext';
      final dest = File('${notesVidDir.path}/$fileName');
      await File(picked.path).copy(dest.path);
      return dest.path;
    } catch (e) {
      if (context.mounted) {
        AppSnackBar.error(context, context.l10n.videoUploadError);
      }
      debugPrint('Video pick error: $e');
      return null;
    }
  }

  static Future<String?> pickImage(BuildContext context, {required bool fromCamera}) async {
    try {
      final XFile? picked = await _imagePicker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        imageQuality: 100,
      );
      if (picked == null) return null;

      final File compressed = await ImageCompressionService.compress(
        File(picked.path),
        maxWidth: _kImageMaxWidth,
        quality: _kImageQuality,
      );

      final docsDir = await getApplicationDocumentsDirectory();
      final notesImgDir = Directory('${docsDir.path}/note_images');
      if (!notesImgDir.existsSync()) notesImgDir.createSync(recursive: true);

      final parts = compressed.path.split('.');
      final ext = parts.length > 1 ? parts.last : 'jpg';
      final fileName = '${DateTime.now().microsecondsSinceEpoch}_${Random().nextInt(9000) + 1000}.$ext';
      final dest = File('${notesImgDir.path}/$fileName');
      await compressed.copy(dest.path);

      return dest.path;
    } catch (_) {
      if (context.mounted) {
        AppSnackBar.error(context, context.l10n.imageLoadError);
      }
      return null;
    }
  }

  static void insertMedia({
    required QuillController controller,
    required String path,
    required bool isVideo,
    VoidCallback? onMediaInserted,
  }) {
    final index = controller.selection.baseOffset;
    final length = controller.selection.extentOffset - index;

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
