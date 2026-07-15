import 'package:flutter/material.dart';
import 'package:cashly/core/extensions/l10n_extensions.dart';

class CameraOptionsDialog {
  static void show({
    required BuildContext context,
    required VoidCallback onTakePhoto,
    required VoidCallback onRecordVideo,
  }) {
    showModalBottomSheet(
      context: context,
      builder: (bottomSheetContext) {
        final cs = Theme.of(bottomSheetContext).colorScheme;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt_outlined, color: cs.primary),
                title: Text(
                  bottomSheetContext.l10n.takePhoto,
                  style: const TextStyle(fontFamily: 'Inter'),
                ),
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  onTakePhoto();
                },
              ),
              ListTile(
                leading: Icon(Icons.videocam_outlined, color: cs.primary),
                title: Text(
                  bottomSheetContext.l10n.recordVideo,
                  style: const TextStyle(fontFamily: 'Inter'),
                ),
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  onRecordVideo();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
