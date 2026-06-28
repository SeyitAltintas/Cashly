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

  const NoteEditorPage({super.key, this.noteId, this.title});

  @override
  State<NoteEditorPage> createState() => _NoteEditorPageState();
}

class _NoteEditorPageState extends State<NoteEditorPage> with WidgetsBindingObserver {
  // Nullable: async _loadNote bitmeden dispose gelirse LateInitializationError önlenir.
  QuillController? _controller;
  NoteModel? _note;

  final FocusNode _editorFocusNode = FocusNode();
  final ScrollController _editorScrollController = ScrollController();
  final ImagePicker _imagePicker = ImagePicker();
  final NoteRepository _repository = NoteRepository();

  bool _isSaving = false;
  bool _isLoading = true;

  /// Kullanıcı yükleme sonrası değişiklik yaptı mı?
  /// PopScope buna bakarak "kaydetmeden çık?" diyaloğunu tetikler.
  bool _hasUnsavedChanges = false;

  /// EC-13: Aynı anda iki diyalog açılmasını önler
  /// (AppBar geri + PopScope aynı anda tetiklenirse).
  bool _isConfirmingDiscard = false;

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
    _controller?.dispose();
    _editorFocusNode.dispose();
    _editorScrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // EC-22: Uygulama arka plana atıldığında (veya inaktif olduğunda) otomatik kaydet.
    // Bu, işletim sisteminin bellek açmak için uygulamayı öldürdüğü durumlarda veri kaybını önler.
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
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
      note = _repository.getNoteById(widget.noteId!) ??
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
      _isLoading = false;
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
    if (!_hasUnsavedChanges && mounted) {
      setState(() => _hasUnsavedChanges = true);
    }
  }

  /// Belgenin ilk satırını başlık olarak çıkarır (max 60 rune — emoji güvenli).
  String _extractTitle() {
    final controller = _controller;
    if (controller == null) return '';

    // EC-23: Quill resim/embed içerikleri \uFFFC (Object Replacement Character) ile temsil eder.
    // Başlıkta bu karakterin anlamsız (￼) görünmesini engellemek için temizliyoruz.
    final plainText = controller.document.toPlainText().replaceAll('\uFFFC', '');
    
    final firstLine = plainText
        .split('\n')
        .map((l) => l.trim())
        .firstWhere((l) => l.isNotEmpty, orElse: () => '');

    // EC-3: substring() surrogate pair'i ikiye bölebilir → runes kullan.
    if (firstLine.runes.length <= 60) return firstLine;
    return String.fromCharCodes(firstLine.runes.take(60));
  }

  Future<void> _saveNote() async {
    final note = _note;
    final controller = _controller;
    if (_isSaving || note == null || controller == null) return;

    // EC-19: Sadece \n içeren belgeyi kaydetme — içerik yok demektir.
    final plainText = controller.document.toPlainText().trim();
    if (plainText.isEmpty) {
      if (mounted) AppSnackBar.info(context, context.l10n.noteEditorHint);
      return;
    }

    setState(() => _isSaving = true);

    try {
      final deltaJson = jsonEncode(controller.document.toDelta().toJson());
      final title = _extractTitle();
      await _repository.updateNote(
        id: note.id,
        deltaJson: deltaJson,
        title: title,
        originalCreatedAt: note.createdAt, // EC-16: orijinal tarihi koru
      );
      if (mounted) {
        setState(() => _hasUnsavedChanges = false);
        AppSnackBar.success(context, context.l10n.noteSaved);
      }
    } catch (_) {
      if (mounted) AppSnackBar.error(context, context.l10n.saveFailed);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ─── Geri Dönme Uyarısı ─────────────────────────────────────────────────

  /// Kaydedilmemiş değişiklik varsa onay diyaloğu gösterir.
  /// EC-13: eş zamanlı çağrılarda ikinci çağrı erken çıkar.
  Future<bool> _confirmDiscard() async {
    if (!_hasUnsavedChanges) return true;
    if (_isConfirmingDiscard) return false; // zaten diyalog açık
    _isConfirmingDiscard = true;
    try {
      final result = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(context.l10n.unsavedChangesTitle),
          content: Text(context.l10n.unsavedChangesMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(context.l10n.cancel),
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(context.l10n.discardChanges),
            ),
          ],
        ),
      );
      return result ?? false;
    } finally {
      _isConfirmingDiscard = false;
    }
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

  // ─── Build ──────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (_isLoading || controller == null) return const _LoadingScaffold();

    final colorScheme = Theme.of(context).colorScheme;

    return PopScope(
      // Kaydedilmemiş değişiklik varsa sistem geri tuşunu engelle.
      canPop: !_hasUnsavedChanges,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final navigator = Navigator.of(context); // await öncesi yakala
        final shouldPop = await _confirmDiscard();
        if (shouldPop && mounted) navigator.pop();
      },
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: _buildAppBar(colorScheme),
        body: Column(
          children: [
            _buildToolbar(colorScheme, controller),
            const Divider(height: 1, thickness: 0.5),
            Expanded(child: _buildEditor(colorScheme, controller)),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(ColorScheme colorScheme) {
    // EC-6: Not başlığını AppBar'da dinamik göster.
    final appBarTitle = widget.title
        ?? (_note?.title.isNotEmpty == true ? _note!.title : null)
        ?? context.l10n.noteEditor;

    return AppBar(
      backgroundColor: colorScheme.surface,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        tooltip: context.l10n.back,
        onPressed: () async {
          final navigator = Navigator.of(context); // await öncesi yakala
          final shouldPop = await _confirmDiscard();
          if (shouldPop && mounted) navigator.pop();
        },
      ),
      title: Text(
        appBarTitle,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurface,
          fontFamily: 'Inter',
        ),
      ),
      centerTitle: false,
      actions: [
        if (_isSaving)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          )
        else
          TextButton.icon(
            onPressed: _saveNote,
            icon: const Icon(Icons.check_rounded, size: 18),
            label: Text(
              context.l10n.save,
              style: const TextStyle(fontFamily: 'Inter'),
            ),
            style: TextButton.styleFrom(foregroundColor: colorScheme.primary),
          ),
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _buildToolbar(ColorScheme colorScheme, QuillController controller) {
    return Container(
      color: colorScheme.surface,
      child: QuillSimpleToolbar(
        controller: controller,
        config: QuillSimpleToolbarConfig(
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
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.35),
                        size: 28,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        context.l10n.imageLoadError,
                        style: TextStyle(
                          fontSize: 10,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
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
        customStyles: _buildEditorStyles(colorScheme, isDark),
      ),
    );
  }

  DefaultStyles _buildEditorStyles(ColorScheme cs, bool isDark) {
    final bodyColor = cs.onSurface;

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
