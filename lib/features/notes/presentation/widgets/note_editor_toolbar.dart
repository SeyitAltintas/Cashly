import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:cashly/core/extensions/l10n_extensions.dart';
import 'package:cashly/features/notes/presentation/widgets/custom_text_link_dialog.dart';
import 'package:cashly/features/notes/presentation/widgets/camera_options_dialog.dart';

class NoteEditorToolbar extends StatefulWidget {
  final QuillController controller;
  final VoidCallback onMarkUnsaved;
  final VoidCallback onStartVoiceDictation;
  final Future<String?> Function(BuildContext) onPickImageFromGallery;
  final Future<String?> Function(BuildContext) onPickVideoFromGallery;
  final VoidCallback onTakePhoto;
  final VoidCallback onRecordVideo;

  const NoteEditorToolbar({
    super.key,
    required this.controller,
    required this.onMarkUnsaved,
    required this.onStartVoiceDictation,
    required this.onPickImageFromGallery,
    required this.onPickVideoFromGallery,
    required this.onTakePhoto,
    required this.onRecordVideo,
  });

  @override
  State<NoteEditorToolbar> createState() => _NoteEditorToolbarState();
}

class _NoteEditorToolbarState extends State<NoteEditorToolbar> {
  bool _isFormatMode = false;
  bool _isMediaMode = false;

  void _decreaseFontSize() {
    final attrs = widget.controller.getSelectionStyle().attributes;
    final sizeAttr = attrs['size'];
    final currentSize = sizeAttr?.value;

    if (currentSize == 'small') {
      return;
    } else if (currentSize == 'large' || currentSize == 'huge') {
      widget.controller.formatSelection(Attribute.size); // normal
    } else if (currentSize == null || currentSize == '0') {
      final attr = Attribute.fromKeyValue('size', 'small');
      if (attr != null) widget.controller.formatSelection(attr);
    }
  }

  void _increaseFontSize() {
    final attrs = widget.controller.getSelectionStyle().attributes;
    final sizeAttr = attrs['size'];
    final currentSize = sizeAttr?.value;

    if (currentSize == 'huge') {
      return;
    } else if (currentSize == 'small') {
      widget.controller.formatSelection(Attribute.size); // normal
    } else if (currentSize == null || currentSize == '0') {
      final attr = Attribute.fromKeyValue('size', 'large');
      if (attr != null) widget.controller.formatSelection(attr);
    } else if (currentSize == 'large') {
      final attr = Attribute.fromKeyValue('size', 'huge');
      if (attr != null) widget.controller.formatSelection(attr);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final colorScheme = Theme.of(context).colorScheme;

    final formatToolbar = Row(
      mainAxisSize: MainAxisSize.min,
      key: const ValueKey('format_mode'),
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                QuillSimpleToolbar(
                  controller: widget.controller,
                  config: QuillSimpleToolbarConfig(
                    color: Colors.transparent,
                    headerStyleType: HeaderStyleType.buttons,
                    buttonOptions: const QuillSimpleToolbarButtonOptions(
                      base: QuillToolbarBaseButtonOptions(
                        iconTheme: QuillIconTheme(
                          iconButtonUnselectedData: IconButtonData(
                            style: ButtonStyle(
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                        ),
                      ),
                    ),
                    customButtons: [
                      QuillToolbarCustomButtonOptions(
                        icon: Text(
                          'A-',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        tooltip: context.l10n.decreaseFontSize,
                        onPressed: _decreaseFontSize,
                      ),
                      QuillToolbarCustomButtonOptions(
                        icon: Text(
                          'A+',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        tooltip: context.l10n.increaseFontSize,
                        onPressed: _increaseFontSize,
                      ),
                    ],
                    showDividers: true,
                    showFontFamily: false,
                    showFontSize: false,
                    showBoldButton: true,
                    showItalicButton: true,
                    showSmallButton: false,
                    showUnderLineButton: true,
                    showLineHeightButton: false,
                    showStrikeThrough: true,
                    showInlineCode: true,
                    showCodeBlock: true,
                    showSubscript: true,
                    showSuperscript: true,
                    showColorButton: true,
                    showBackgroundColorButton: true,
                    showClearFormat: true,
                    showAlignmentButtons: false,
                    showLeftAlignment: true,
                    showCenterAlignment: true,
                    showRightAlignment: true,
                    showJustifyAlignment: true,
                    showHeaderStyle: true,
                    showListNumbers: true,
                    showListBullets: true,
                    showListCheck: true,
                    showQuote: true,
                    showIndent: true,
                    showLink: false,
                    showUndo: false,
                    showRedo: false,
                    multiRowsDisplay: true,
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: IconButton(
            icon: const Icon(Icons.close_rounded, size: 20),
            tooltip: context.l10n.closeAction,
            onPressed: () => setState(() {
              _isFormatMode = false;
              _isMediaMode = false;
            }),
          ),
        ),
      ],
    );

    final mainToolbar = SingleChildScrollView(
      key: const ValueKey('main_mode'),
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: IconButton(
              icon: const Icon(Icons.font_download_outlined, size: 20),
              tooltip: context.l10n.textStyle,
              onPressed: () => setState(() {
                _isFormatMode = true;
                _isMediaMode = false;
              }),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: IconButton(
              icon: const Icon(Icons.perm_media_outlined, size: 20),
              tooltip: context.l10n.addMedia,
              onPressed: () => setState(() {
                _isMediaMode = true;
                _isFormatMode = false;
              }),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: IconButton(
              icon: const Icon(Icons.link_rounded, size: 20),
              tooltip: context.l10n.addLink,
              onPressed: () => CustomTextLinkDialog.show(
                context,
                widget.controller,
                widget.onMarkUnsaved,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: IconButton(
              icon: const Icon(Icons.mic_none_rounded, size: 22),
              tooltip: context.l10n.voiceDictate,
              onPressed: widget.onStartVoiceDictation,
            ),
          ),
          QuillSimpleToolbar(
            controller: widget.controller,
            config: const QuillSimpleToolbarConfig(
              color: Colors.transparent,
              buttonOptions: QuillSimpleToolbarButtonOptions(
                base: QuillToolbarBaseButtonOptions(
                  iconTheme: QuillIconTheme(
                    iconButtonUnselectedData: IconButtonData(
                      style: ButtonStyle(
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ),
                ),
              ),
              showDividers: true,
              showFontFamily: false,
              showFontSize: false,
              showBoldButton: false,
              showItalicButton: false,
              showSmallButton: false,
              showUnderLineButton: false,
              showLineHeightButton: false,
              showStrikeThrough: false,
              showInlineCode: false,
              showCodeBlock: false,
              showSubscript: false,
              showSuperscript: false,
              showColorButton: false,
              showBackgroundColorButton: false,
              showClearFormat: false,
              showAlignmentButtons: false,
              showLeftAlignment: false,
              showCenterAlignment: false,
              showRightAlignment: false,
              showJustifyAlignment: false,
              showHeaderStyle: false,
              showListNumbers: false,
              showListBullets: false,
              showListCheck: false,
              showQuote: false,
              showIndent: false,
              showLink: false,
              showUndo: false,
              showRedo: false,
              multiRowsDisplay: true,
            ),
          ),
        ],
      ),
    );

    final mediaToolbar = Row(
      mainAxisSize: MainAxisSize.min,
      key: const ValueKey('media_mode'),
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.camera_alt_outlined, size: 20),
                  tooltip: context.l10n.camera,
                  onPressed: () => CameraOptionsDialog.show(
                    context: context,
                    onTakePhoto: widget.onTakePhoto,
                    onRecordVideo: widget.onRecordVideo,
                  ),
                ),
                QuillSimpleToolbar(
                  controller: widget.controller,
                  config: QuillSimpleToolbarConfig(
                    color: Colors.transparent,
                    buttonOptions: const QuillSimpleToolbarButtonOptions(
                      base: QuillToolbarBaseButtonOptions(
                        iconTheme: QuillIconTheme(
                          iconButtonUnselectedData: IconButtonData(
                            style: ButtonStyle(
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                        ),
                      ),
                    ),
                    showDividers: true,
                    showFontFamily: false,
                    showFontSize: false,
                    showBoldButton: false,
                    showItalicButton: false,
                    showSmallButton: false,
                    showUnderLineButton: false,
                    showLineHeightButton: false,
                    showStrikeThrough: false,
                    showInlineCode: false,
                    showCodeBlock: false,
                    showSubscript: false,
                    showSuperscript: false,
                    showColorButton: false,
                    showBackgroundColorButton: false,
                    showClearFormat: false,
                    showAlignmentButtons: false,
                    showLeftAlignment: false,
                    showCenterAlignment: false,
                    showRightAlignment: false,
                    showJustifyAlignment: false,
                    showHeaderStyle: false,
                    showListNumbers: false,
                    showListBullets: false,
                    showListCheck: false,
                    showQuote: false,
                    showIndent: false,
                    showLink: false,
                    showUndo: false,
                    showRedo: false,
                    showSearchButton: false,
                    multiRowsDisplay: true,
                    embedButtons: FlutterQuillEmbeds.toolbarButtons(
                      imageButtonOptions: QuillToolbarImageButtonOptions(
                        imageButtonConfig: QuillToolbarImageConfig(
                          onRequestPickImage: widget.onPickImageFromGallery,
                        ),
                      ),
                      videoButtonOptions: QuillToolbarVideoButtonOptions(
                        videoConfig: QuillToolbarVideoConfig(
                          onRequestPickVideo: widget.onPickVideoFromGallery,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: IconButton(
            icon: const Icon(Icons.close_rounded, size: 20),
            tooltip: context.l10n.closeAction,
            onPressed: () => setState(() {
              _isFormatMode = false;
              _isMediaMode = false;
            }),
          ),
        ),
      ],
    );

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Theme(
        data: Theme.of(context).copyWith(
          menuTheme: const MenuThemeData(
            style: MenuStyle(alignment: Alignment.topLeft),
          ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: _isFormatMode
              ? formatToolbar
              : _isMediaMode
                  ? mediaToolbar
                  : mainToolbar,
        ),
      ),
    );
  }
}
