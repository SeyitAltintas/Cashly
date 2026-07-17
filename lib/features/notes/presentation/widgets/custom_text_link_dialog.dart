import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:cashly/core/extensions/l10n_extensions.dart';

class CustomTextLinkDialog {
  static void show(
    BuildContext context,
    QuillController controller,
    VoidCallback onLinkAdded,
  ) {
    final selection = controller.selection;
    String selectedText = '';
    if (selection.isValid && !selection.isCollapsed) {
      selectedText = controller.document.getPlainText(
        selection.start,
        selection.end - selection.start,
      );
    }

    final TextEditingController textController = TextEditingController(
      text: selectedText,
    );
    final TextEditingController linkController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        final cs = Theme.of(dialogContext).colorScheme;
        return AlertDialog(
          backgroundColor: Theme.of(dialogContext).brightness == Brightness.dark
              ? const Color(0xFF1E1E1E)
              : Colors.white,
          title: Text(
            dialogContext.l10n.addLink,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: textController,
                  decoration: InputDecoration(
                    labelText: dialogContext.l10n.displayTextOptional,
                    labelStyle: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: linkController,
                  decoration: InputDecoration(
                    labelText: dialogContext.l10n.webUrl,
                    hintText: 'https://...',
                    labelStyle: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                dialogContext.l10n.cancelAction,
                style: TextStyle(
                  color: cs.onSurface.withValues(alpha: 0.6),
                  fontFamily: 'Inter',
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                final text = textController.text.trim();
                final url = linkController.text.trim();
                if (url.isNotEmpty) {
                  if (selection.isValid && !selection.isCollapsed) {
                    if (text.isNotEmpty && text != selectedText) {
                      controller.replaceText(
                        selection.start,
                        selection.end - selection.start,
                        text,
                        TextSelection.collapsed(
                          offset: selection.start + text.length,
                        ),
                      );
                      controller.formatText(
                        selection.start,
                        text.length,
                        LinkAttribute(url),
                      );
                    } else {
                      controller.formatSelection(LinkAttribute(url));
                    }
                  } else {
                    final insertText = text.isNotEmpty ? text : url;
                    final index = selection.isValid
                        ? selection.baseOffset
                        : (controller.document.length - 1).clamp(0, controller.document.length);
                    controller.document.insert(index, insertText);
                    controller.formatText(
                      index,
                      insertText.length,
                      LinkAttribute(url),
                    );
                    controller.updateSelection(
                      TextSelection.collapsed(
                        offset: index + insertText.length,
                      ),
                      ChangeSource.local,
                    );
                  }
                  onLinkAdded();
                }
                Navigator.pop(dialogContext);
              },
              child: Text(
                dialogContext.l10n.addAction,
                style: TextStyle(
                  color: cs.primary,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Inter',
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
