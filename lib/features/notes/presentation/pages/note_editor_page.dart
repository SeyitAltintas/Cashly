import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:path_provider/path_provider.dart';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cashly/core/extensions/l10n_extensions.dart';
import 'package:cashly/core/services/image_compression_service.dart';
import 'package:cashly/core/widgets/app_snackbar.dart';
import 'package:cashly/features/notes/data/models/note_model.dart';
import 'package:cashly/features/notes/data/repositories/note_repository.dart';

// ─── Sabitler ───────────────────────────────────────────────────────────────

const int _kImageMaxWidth = 1280;
const int _kImageQuality = 78;

// ─── Widget ─────────────────────────────────────────────────────────────────

/// Zengin metin not editörü sayfası.
///
/// [noteId] verilirse mevcut notu yükler ve günceller.
/// Verilmezse yeni bir not oluşturur.
class NoteEditorPage extends StatefulWidget {
  final String? noteId;
  final String? title;
  final String heroTag;

  const NoteEditorPage({
    super.key,
    this.noteId,
    this.title,
    required this.heroTag,
  });

  @override
  State<NoteEditorPage> createState() => _NoteEditorPageState();
}

class _NoteEditorPageState extends State<NoteEditorPage>
    with WidgetsBindingObserver {
  // Nullable: async _loadNote bitmeden dispose gelirse LateInitializationError önlenir.
  QuillController? _controller;
  NoteModel? _note;
  int? _selectedColor;

  Timer? _autoSaveTimer;
  final TextEditingController _titleController = TextEditingController();

  final FocusNode _editorFocusNode = FocusNode();
  final ScrollController _editorScrollController = ScrollController();
  final ImagePicker _imagePicker = ImagePicker();
  final NoteRepository _repository = NoteRepository();

  bool _isSaving = false;
  bool _isLoading = true;

  /// Kullanıcı yükleme sonrası değişiklik yaptı mı?
  /// PopScope buna bakarak "kaydetmeden çık?" diyaloğunu tetikler.
  bool _hasUnsavedChanges = false;

  // ─── Lifecycle ──────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadNote();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.removeListener(_onDocumentChanged);
    _autoSaveTimer?.cancel();
    _titleController.dispose();
    _controller?.dispose();
    _editorFocusNode.dispose();
    _editorScrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // EC-22: Uygulama arka plana atıldığında (veya inaktif olduğunda) otomatik kaydet.
    // Bu, işletim sisteminin bellek açmak için uygulamayı öldürdüğü durumlarda veri kaybını önler.
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      if (_hasUnsavedChanges) {
        _saveNote();
      }
    }
  }

  // ─── Veri Yönetimi ──────────────────────────────────────────────────────

  Future<void> _loadNote() async {
    await _repository.init();

    // Edge case: noteId verildi ama Hive'da kayıt yok (silinmiş olabilir).
    // NoteModel.empty() yerine noteId'yi sabit tutan model oluşturulur.
    final NoteModel note;
    if (widget.noteId != null) {
      note =
          _repository.getNoteById(widget.noteId!) ??
          NoteModel(
            id: widget.noteId!,
            deltaJson: '[]',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
    } else {
      note = NoteModel.empty();
    }

    final controller = _buildController(note.deltaJson);
    controller.addListener(_onDocumentChanged);

    // mounted kontrolü: dispose erken çağrılmışsa state güncelleme yapma.
    if (!mounted) {
      controller.dispose();
      return;
    }

    setState(() {
      _note = note;
      _controller = controller;
      _selectedColor = note.color;
      _isLoading = false;
      _titleController.text = note.title;
      _titleController.addListener(_scheduleAutoSave);
    });
  }

  QuillController _buildController(String deltaJson) {
    Document doc;
    try {
      final data = jsonDecode(deltaJson);
      doc = Document.fromJson(data as List<dynamic>);
    } catch (_) {
      doc = Document();
    }
    return QuillController(
      document: doc,
      selection: const TextSelection.collapsed(offset: 0),
    );
  }

  /// Her belge değişikliğinde kaydedilmemiş değişiklik işareti set edilir.
  /// EC-12: Yükleme sırasında Quill'in kendi olaylarını filtrele.
  void _onDocumentChanged() {
    if (_isLoading) return; // yükleme bitmeden tetiklenen event — görmezden gel
    _markUnsaved();
    _scheduleAutoSave();
  }

  void _markUnsaved() {
    if (!_hasUnsavedChanges && mounted) {
      setState(() => _hasUnsavedChanges = true);
    }
  }

  void _scheduleAutoSave() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer(const Duration(seconds: 1), () {
      if (mounted) _saveNote();
    });
  }

  Future<void> _saveNote() async {
    final note = _note;
    final controller = _controller;
    if (_isSaving || note == null || controller == null) return;

    // EC-19: Sadece \n içeren belgeyi kaydetme — içerik yok demektir.
    final plainText = controller.document.toPlainText().trim();
    final title = _titleController.text.trim();
    if (plainText.isEmpty && title.isEmpty) {
      return;
    }

    if (mounted) {
      setState(() => _isSaving = true);
    } else {
      _isSaving = true;
    }

    try {
      final deltaJson = jsonEncode(controller.document.toDelta().toJson());
      final title = _titleController.text.trim();
      await _repository.updateNote(
        id: note.id,
        deltaJson: deltaJson,
        title: title,
        color: _selectedColor,
        clearColor: _selectedColor == null,
        originalCreatedAt: note.createdAt, // EC-16: orijinal tarihi koru
      );
      if (mounted) {
        setState(() => _hasUnsavedChanges = false);
        // Sessiz otomatik kayıt (seamless save)
      }
    } catch (_) {
      if (mounted) AppSnackBar.error(context, context.l10n.saveFailed);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ─── Renk Seçimi ────────────────────────────────────────────────────────

  static const List<Color> _noteColors = [
    Color(0xFFFFF9C4), // Sarı
    Color(0xFFB2DFDB), // Yeşil
    Color(0xFFBBDEFB), // Mavi
    Color(0xFFF8BBD0), // Pembe
    Color(0xFFE1BEE7), // Mor
  ];

  void _showColorPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: [
                _ColorOption(
                  color: null,
                  isSelected: _selectedColor == null,
                  onTap: () {
                    setState(() => _selectedColor = null);
                    _markUnsaved();
                    Navigator.pop(context);
                  },
                ),
                for (final color in _noteColors)
                  _ColorOption(
                    color: color,
                    isSelected: _selectedColor == color.toARGB32(),
                    onTap: () {
                      setState(() => _selectedColor = color.toARGB32());
                      _markUnsaved();
                      Navigator.pop(context);
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ─── Resim İşlemi ───────────────────────────────────────────────────────

  /// EC-5: Galeriden seçilen resmi Documents dizinine kopyalar.
  /// Cache silinse veya uygulama güncellense bile resim kaybolmaz.
  Future<String?> _pickAndReturnImagePath(BuildContext context) async {
    try {
      final XFile? picked = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100,
      );
      if (picked == null) return null;

      final File compressed = await ImageCompressionService.compress(
        File(picked.path),
        maxWidth: _kImageMaxWidth,
        quality: _kImageQuality,
      );

      // Kalıcı dizine kopyala — cache dosyası silinirse resim hala erişilebilir.
      final docsDir = await getApplicationDocumentsDirectory();
      final notesImgDir = Directory('${docsDir.path}/note_images');
      if (!notesImgDir.existsSync()) notesImgDir.createSync(recursive: true);

      // EC-14: Uzantsız dosyalarda split('.').last tamamı alır → 'jpg' fallback.
      final parts = compressed.path.split('.');
      final ext = parts.length > 1 ? parts.last : 'jpg';
      final fileName =
          '${DateTime.now().microsecondsSinceEpoch}_${Random().nextInt(9000) + 1000}.$ext';
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

  // ─── Build ──────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (_isLoading || controller == null) return const _LoadingScaffold();

    final colorScheme = Theme.of(context).colorScheme;
    final bgColor = _selectedColor != null
        ? Color(_selectedColor!)
        : colorScheme.surface;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) return;
        _saveNote();
      },
      child: Hero(
        tag: widget.heroTag,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          color: bgColor,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: _buildAppBar(colorScheme),
            body: Stack(
              children: [
                Column(
                  children: [
                    _buildTitleField(colorScheme),
                    _buildDateInfo(colorScheme),
                    Expanded(child: _buildEditor(colorScheme, controller)),
                  ],
                ),
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: _buildFloatingToolbar(colorScheme, controller),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitleField(ColorScheme colorScheme) {
    final fgColor = _selectedColor != null
        ? Colors.black87
        : colorScheme.onSurface;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: TextField(
        controller: _titleController,
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: fgColor,
          fontFamily: 'Inter',
          letterSpacing: -0.5,
        ),
        decoration: InputDecoration(
          hintText: context.l10n.noteEditorHint,
          hintStyle: TextStyle(color: fgColor.withValues(alpha: 0.3)),
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.zero,
        ),
        maxLines: null,
        textInputAction: TextInputAction.next,
      ),
    );
  }

  Widget _buildDateInfo(ColorScheme colorScheme) {
    final fgColor = _selectedColor != null
        ? Colors.black87
        : colorScheme.onSurface;
    final date = _note?.updatedAt ?? DateTime.now();
    final timeString =
        '${date.hour.toString().padLeft(2, "0")}:${date.minute.toString().padLeft(2, "0")}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'Son düzenleme: $timeString',
          style: TextStyle(
            fontSize: 12,
            color: fgColor.withValues(alpha: 0.5),
            fontFamily: 'Inter',
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(ColorScheme colorScheme) {
    final fgColor = _selectedColor != null
        ? Colors.black87
        : colorScheme.onSurface;

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      iconTheme: IconThemeData(color: fgColor),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        tooltip: context.l10n.back,
        onPressed: () {
          FocusScope.of(context).unfocus();
          Navigator.of(context).pop();
        },
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.color_lens_outlined, color: fgColor),
          onPressed: _showColorPicker,
        ),
        if (_isSaving)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: fgColor.withValues(alpha: 0.5),
              ),
            ),
          )
        else
          IconButton(
            icon: Icon(Icons.check_rounded, color: fgColor),
            onPressed: () {
              FocusScope.of(context).unfocus();
              Navigator.of(context).pop();
            },
          ),
      ],
    );
  }

  Widget _buildFloatingToolbar(
    ColorScheme colorScheme,
    QuillController controller,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

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
      child: QuillSimpleToolbar(
        controller: controller,
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
          showFontSize: true,
          showBoldButton: true,
          showItalicButton: true,
          showSmallButton: false,
          showUnderLineButton: true,
          showLineHeightButton: false,
          showStrikeThrough: true,
          showInlineCode: true,
          showColorButton: true,
          showBackgroundColorButton: true,
          showClearFormat: true,
          showAlignmentButtons: true,
          showLeftAlignment: true,
          showCenterAlignment: true,
          showRightAlignment: true,
          showJustifyAlignment: true,
          showHeaderStyle: true,
          showListNumbers: true,
          showListBullets: true,
          showListCheck: true,
          showCodeBlock: true,
          showQuote: true,
          showIndent: true,
          showLink: true,
          showUndo: true,
          showRedo: true,
          multiRowsDisplay: false,
          embedButtons: FlutterQuillEmbeds.toolbarButtons(
            imageButtonOptions: QuillToolbarImageButtonOptions(
              imageButtonConfig: QuillToolbarImageConfig(
                onRequestPickImage: _pickAndReturnImagePath,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEditor(ColorScheme colorScheme, QuillController controller) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return QuillEditor(
      focusNode: _editorFocusNode,
      scrollController: _editorScrollController,
      controller: controller,
      config: QuillEditorConfig(
        scrollable: true,
        expands: true,
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 80),
        autoFocus: false,
        placeholder: context.l10n.noteEditorHint,
        embedBuilders: [
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
        ],
        customStyles: _buildEditorStyles(
          colorScheme,
          isDark && _selectedColor == null,
        ),
      ),
    );
  }

  DefaultStyles _buildEditorStyles(ColorScheme cs, bool isDark) {
    final bodyColor = _selectedColor != null ? Colors.black87 : cs.onSurface;

    return DefaultStyles(
      paragraph: DefaultTextBlockStyle(
        TextStyle(
          fontSize: 15,
          height: 1.6,
          color: bodyColor,
          fontFamily: 'Inter',
        ),
        const HorizontalSpacing(0, 0),
        const VerticalSpacing(0, 0),
        const VerticalSpacing(0, 0),
        null,
      ),
      placeHolder: DefaultTextBlockStyle(
        TextStyle(
          fontSize: 15,
          color: bodyColor.withValues(alpha: 0.35),
          fontFamily: 'Inter',
        ),
        const HorizontalSpacing(0, 0),
        const VerticalSpacing(0, 0),
        const VerticalSpacing(0, 0),
        null,
      ),
      h1: DefaultTextBlockStyle(
        TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w600,
          color: bodyColor,
          fontFamily: 'Inter',
          letterSpacing: -0.3,
        ),
        const HorizontalSpacing(0, 0),
        const VerticalSpacing(8, 4),
        const VerticalSpacing(0, 0),
        null,
      ),
      h2: DefaultTextBlockStyle(
        TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w500,
          color: bodyColor,
          fontFamily: 'Inter',
        ),
        const HorizontalSpacing(0, 0),
        const VerticalSpacing(6, 2),
        const VerticalSpacing(0, 0),
        null,
      ),
      h3: DefaultTextBlockStyle(
        TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: bodyColor,
          fontFamily: 'Inter',
        ),
        const HorizontalSpacing(0, 0),
        const VerticalSpacing(4, 2),
        const VerticalSpacing(0, 0),
        null,
      ),
      bold: TextStyle(fontWeight: FontWeight.w600, color: bodyColor),
      italic: TextStyle(fontStyle: FontStyle.italic, color: bodyColor),
      underline: const TextStyle(decoration: TextDecoration.underline),
      strikeThrough: const TextStyle(decoration: TextDecoration.lineThrough),
      inlineCode: InlineCodeStyle(
        backgroundColor: isDark
            ? const Color(0xFF2A2A2A)
            : const Color(0xFFF1F1F1),
        style: TextStyle(
          fontFamily: 'monospace',
          fontSize: 13,
          color: isDark ? const Color(0xFF80CBC4) : const Color(0xFFE53935),
        ),
      ),
      code: DefaultTextBlockStyle(
        TextStyle(
          fontFamily: 'monospace',
          fontSize: 13,
          color: isDark ? const Color(0xFF80CBC4) : const Color(0xFF263238),
        ),
        const HorizontalSpacing(12, 12),
        const VerticalSpacing(8, 8),
        const VerticalSpacing(0, 0),
        BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      quote: DefaultTextBlockStyle(
        TextStyle(
          fontSize: 15,
          color: bodyColor.withValues(alpha: 0.7),
          fontStyle: FontStyle.italic,
        ),
        const HorizontalSpacing(16, 0),
        const VerticalSpacing(8, 8),
        const VerticalSpacing(0, 0),
        BoxDecoration(
          border: Border(
            left: BorderSide(
              color: cs.primary.withValues(alpha: 0.6),
              width: 3,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Yardımcı Widget ────────────────────────────────────────────────────────

class _LoadingScaffold extends StatelessWidget {
  const _LoadingScaffold();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

class _ColorOption extends StatelessWidget {
  final Color? color;
  final bool isSelected;
  final VoidCallback onTap;

  const _ColorOption({
    this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color ?? (isDark ? const Color(0xFF2C2C2C) : Colors.white),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: isSelected
            ? Icon(
                Icons.check,
                color: color == null
                    ? Theme.of(context).colorScheme.onSurface
                    : Colors.black54,
              )
            : (color == null
                  ? Icon(
                      Icons.format_color_reset_outlined,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.5),
                    )
                  : null),
      ),
    );
  }
}
