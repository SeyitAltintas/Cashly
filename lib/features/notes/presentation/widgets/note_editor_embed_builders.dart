import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:cashly/core/extensions/l10n_extensions.dart';

class NoteEditorEmbedBuilders {
  static List<EmbedBuilder> build(BuildContext context) {
    return [
      ...FlutterQuillEmbeds.editorBuilders(
        imageEmbedConfig: QuillEditorImageEmbedConfig(
          imageProviderBuilder: (context, imageUrl) {
            if (!imageUrl.startsWith('http')) {
              return FileImage(File(imageUrl));
            }
            return NetworkImage(imageUrl);
          },
          // EC-15: Eksik/bozuk dosyada Flutter'in kirık ikon yerine
          // kullanıcı dostu ikon gösterilir.
          imageErrorWidgetBuilder: (context, imageUrl, error) {
            return Container(
              width: 120,
              height: 80,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.broken_image_outlined,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.35),
                    size: 28,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    context.l10n.imageLoadError,
                    style: TextStyle(
                      fontSize: 10,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.4),
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    ];
  }
}
