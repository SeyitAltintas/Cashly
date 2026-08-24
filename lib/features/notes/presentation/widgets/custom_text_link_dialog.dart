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

    showDialog(
      context: context,
      builder: (dialogContext) => _CustomTextLinkDialogContent(
        controller: controller,
        selection: selection,
        selectedText: selectedText,
        onLinkAdded: onLinkAdded,
      ),
    );
  }
}

/// BUG 33 FIX: TextEditingController'lar artık StatefulWidget içinde
/// yönetilir ve dispose() ile serbest bırakılır. Önceki static
/// yaklaşımda controller'lar dialog kapanınca leak oluyordu.
class _CustomTextLinkDialogContent extends StatefulWidget {
  final QuillController controller;
  final TextSelection selection;
  final String selectedText;
  final VoidCallback onLinkAdded;

  const _CustomTextLinkDialogContent({
    required this.controller,
    required this.selection,
    required this.selectedText,
    required this.onLinkAdded,
  });

  @override
  State<_CustomTextLinkDialogContent> createState() =>
      _CustomTextLinkDialogContentState();
}

class _CustomTextLinkDialogContentState
    extends State<_CustomTextLinkDialogContent> {
  late final TextEditingController _textController;
  late final TextEditingController _linkController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.selectedText);
    _linkController = TextEditingController();
  }

  @override
  void dispose() {
    _textController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  void _onConfirm() {
    final text = _textController.text.trim();
    final url = _linkController.text.trim();
    final selection = widget.selection;
    final controller = widget.controller;

    if (url.isNotEmpty) {
      if (selection.isValid && !selection.isCollapsed) {
        if (text.isNotEmpty && text != widget.selectedText) {
          controller.replaceText(
            selection.start,
            selection.end - selection.start,
            text,
            TextSelection.collapsed(offset: selection.start + text.length),
          );
          controller.formatText(
            selection.start, text.length, LinkAttribute(url),
          );
        } else {
          controller.formatSelection(LinkAttribute(url));
        }
      } else {
        final insertText = text.isNotEmpty ? text : url;
        // BUG 34 FIX: clamp üst sınırı document.length - 1 olmalı;
        // boş doc (length=1, newline) için de 0'a clamp edilir.
        final docLength = controller.document.length;
        final index = selection.isValid
            ? selection.baseOffset
            : (docLength - 1).clamp(0, docLength > 0 ? docLength - 1 : 0);
        controller.document.insert(index, insertText);
        controller.formatText(index, insertText.length, LinkAttribute(url));
        controller.updateSelection(
          TextSelection.collapsed(offset: index + insertText.length),
          ChangeSource.local,
        );
      }
      widget.onLinkAdded();
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AlertDialog(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF1E1E1E)
          : Colors.white,
      title: Text(
        context.l10n.addLink,
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
              controller: _textController,
              decoration: InputDecoration(
                labelText: context.l10n.displayTextOptional,
                labelStyle: const TextStyle(fontFamily: 'Inter', fontSize: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _linkController,
              decoration: InputDecoration(
                labelText: context.l10n.webUrl,
                hintText: 'https://...',
                labelStyle: const TextStyle(fontFamily: 'Inter', fontSize: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            context.l10n.cancelAction,
            style: TextStyle(
              color: cs.onSurface.withValues(alpha: 0.6),
              fontFamily: 'Inter',
            ),
          ),
        ),
        TextButton(
          onPressed: _onConfirm,
          child: Text(
            context.l10n.addAction,
            style: TextStyle(
              color: cs.primary,
              fontWeight: FontWeight.bold,
              fontFamily: 'Inter',
            ),
          ),
        ),
      ],
    );
  }
}
