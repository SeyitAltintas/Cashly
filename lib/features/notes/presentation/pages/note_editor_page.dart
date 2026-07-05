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
import 'package:cashly/features/notes/data/models/note_category_model.dart';
import 'package:cashly/features/notes/data/repositories/note_repository.dart';
import 'package:cashly/features/notes/data/repositories/note_category_repository.dart';

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

  StreamSubscription? _docSubscription;

  final FocusNode _editorFocusNode = FocusNode();
  final FocusNode _titleFocusNode = FocusNode();
  final ScrollController _editorScrollController = ScrollController();

  bool _isEditing = false;
  bool _isFormatMode = false;
  bool _isMediaMode = false;
  final ImagePicker _imagePicker = ImagePicker();
  final NoteRepository _repository = NoteRepository();
  final NoteCategoryRepository _categoryRepository = NoteCategoryRepository();
  List<NoteCategoryModel> _allCategories = [];

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
    _editorFocusNode.addListener(_onFocusChange);
    _titleFocusNode.addListener(_onFocusChange);
    _loadNote();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    await _categoryRepository.init();
    if (mounted) {
      setState(() {
        _allCategories = _categoryRepository.getAllCategories();
      });
    }
  }

  void _onFocusChange() {
    final hasFocus = _editorFocusNode.hasFocus || _titleFocusNode.hasFocus;
    if (_isEditing != hasFocus && mounted) {
      setState(() => _isEditing = hasFocus);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.removeListener(_onDocumentChanged);
    _autoSaveTimer?.cancel();
    _docSubscription?.cancel();
    _titleController.dispose();
    _controller?.dispose();
    _editorFocusNode.removeListener(_onFocusChange);
    _titleFocusNode.removeListener(_onFocusChange);
    _editorFocusNode.dispose();
    _titleFocusNode.dispose();
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
    _docSubscription = controller.document.changes.listen((_) {
      if (_isLoading) return;
      _markUnsaved();
      _scheduleAutoSave();
    });

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
  /// Artık kullanılmıyor (StreamSubscription kullanılıyor).
  void _onDocumentChanged() {}

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

  static const List<Color> _lightNoteColors = [
    Color(0xFFFDFBF7), // Pamuk
    Color(0xFFF0F7F4), // Nane
    Color(0xFFF0F4F8), // Buz
    Color(0xFFFFF0F0), // Gül
    Color(0xFFF4F0F7), // Lavanta
  ];

  static const List<Color> _darkNoteColors = [
    Color(0xFF242424), // Koyu Gri
    Color(0xFF142C23), // Koyu Nane
    Color(0xFF122236), // Koyu Mavi
    Color(0xFF33161A), // Koyu Gül
    Color(0xFF261933), // Koyu Lavanta
  ];

  Color? _getAdaptiveColor(BuildContext context, int? colorValue) {
    if (colorValue == null) return null;
    return Color(colorValue);
  }

  void _showColorPicker() {
    final outerContext = context;
    showModalBottomSheet(
      context: outerContext,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        final cs = Theme.of(sheetContext).colorScheme;

        final allColors = [..._lightNoteColors, ..._darkNoteColors];
        final allLabels = [
          ..._colorLabels,
          'Koyu Pamuk',
          'Koyu Nane',
          'Koyu Mavi',
          'Koyu Gül',
          'Koyu Lavanta',
        ];

        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.6,
              minChildSize: 0.4,
              maxChildSize: 0.9,
              expand: false,
              builder: (_, scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    color: cs.surface,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(32),
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Drag handle
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: cs.onSurface.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            'Tema Rengi',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: cs.onSurface,
                              fontFamily: 'Inter',
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // "Varsayılan" küçük chip butonu
                          GestureDetector(
                            onTap: () {
                              setState(() => _selectedColor = null);
                              _markUnsaved();
                              Navigator.pop(sheetContext);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _selectedColor == null
                                    ? cs.primary.withValues(alpha: 0.15)
                                    : cs.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: _selectedColor == null
                                      ? cs.primary
                                      : Colors.transparent,
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                'Varsayılan',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: _selectedColor == null
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                  color: _selectedColor == null
                                      ? cs.primary
                                      : cs.onSurface.withValues(alpha: 0.6),
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: SingleChildScrollView(
                          controller: scrollController,
                          physics: const BouncingScrollPhysics(),
                          child: SafeArea(
                            top: false,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Wrap(
                                spacing: 16,
                                runSpacing: 20,
                                children: [
                                  for (int i = 0; i < allColors.length; i++)
                                    _ColorOption(
                                      color: allColors[i],
                                      isSelected:
                                          _selectedColor != null &&
                                          allColors[i].toARGB32() ==
                                              _selectedColor,
                                      label: allLabels[i],
                                      onTap: () {
                                        setState(
                                          () => _selectedColor = allColors[i]
                                              .toARGB32(),
                                        );
                                        _markUnsaved();
                                        Navigator.pop(sheetContext);
                                      },
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  static const List<String> _colorLabels = [
    'Pamuk',
    'Nane',
    'Buz',
    'Gül',
    'Lavanta',
  ];

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

  void _insertMedia(String path, bool isVideo) {
    if (_controller == null) return;

    final index = _controller!.selection.baseOffset;
    final length = _controller!.selection.extentOffset - index;

    if (length > 0) {
      _controller!.document.delete(index, length);
    }

    _controller!.document.insert(
      index,
      isVideo ? BlockEmbed.video(path) : BlockEmbed.image(path),
    );

    _controller!.document.insert(index + 1, '\n');
    _controller!.updateSelection(
      TextSelection.collapsed(offset: index + 2),
      ChangeSource.local,
    );

    _markUnsaved();
  }

  void _showCustomTextLinkDialog() {
    final selection = _controller!.selection;
    String selectedText = '';
    if (selection.isValid && !selection.isCollapsed) {
      selectedText = _controller!.document.getPlainText(
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
      builder: (context) {
        final cs = Theme.of(context).colorScheme;
        return AlertDialog(
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF1E1E1E)
              : Colors.white,
          title: const Text(
            'Bağlantı Ekle',
            style: TextStyle(
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
                    labelText: 'Görünecek Metin (İsteğe Bağlı)',
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
                    labelText: 'Web Bağlantısı (URL)',
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
              onPressed: () => Navigator.pop(context),
              child: Text(
                'İptal',
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
                      _controller!.replaceText(
                        selection.start,
                        selection.end - selection.start,
                        text,
                        TextSelection.collapsed(
                          offset: selection.start + text.length,
                        ),
                      );
                      _controller!.formatText(
                        selection.start,
                        text.length,
                        LinkAttribute(url),
                      );
                    } else {
                      _controller!.formatSelection(LinkAttribute(url));
                    }
                  } else {
                    final insertText = text.isNotEmpty ? text : url;
                    final index = selection.isValid
                        ? selection.baseOffset
                        : _controller!.document.length;
                    _controller!.document.insert(index, insertText);
                    _controller!.formatText(
                      index,
                      insertText.length,
                      LinkAttribute(url),
                    );
                    _controller!.updateSelection(
                      TextSelection.collapsed(
                        offset: index + insertText.length,
                      ),
                      ChangeSource.local,
                    );
                  }
                  _markUnsaved();
                }
                Navigator.pop(context);
              },
              child: Text(
                'Ekle',
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

  Future<String?> _pickAndReturnImagePathFromCamera(
    BuildContext context,
  ) async {
    try {
      final XFile? picked = await _imagePicker.pickImage(
        source: ImageSource.camera,
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

  Future<String?> _pickAndReturnVideoPathFromCamera(
    BuildContext context,
  ) async {
    try {
      final XFile? picked = await _imagePicker.pickVideo(
        source: ImageSource.camera,
      );
      if (picked == null) return null;

      final docsDir = await getApplicationDocumentsDirectory();
      final notesVidDir = Directory('${docsDir.path}/note_videos');
      if (!notesVidDir.existsSync()) notesVidDir.createSync(recursive: true);

      final parts = picked.path.split('.');
      final ext = parts.length > 1 ? parts.last : 'mp4';
      final fileName =
          '${DateTime.now().microsecondsSinceEpoch}_${Random().nextInt(9000) + 1000}.$ext';
      final dest = File('${notesVidDir.path}/$fileName');
      await File(picked.path).copy(dest.path);

      return dest.path;
    } catch (_) {
      if (context.mounted) {
        AppSnackBar.error(context, 'Video yüklenirken hata oluştu');
      }
      return null;
    }
  }

  void _showCameraOptionsDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        final cs = Theme.of(context).colorScheme;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt_outlined, color: cs.primary),
                title: const Text(
                  'Fotoğraf Çek',
                  style: TextStyle(fontFamily: 'Inter'),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  final path = await _pickAndReturnImagePathFromCamera(context);
                  if (path != null) _insertMedia(path, false);
                },
              ),
              ListTile(
                leading: Icon(Icons.videocam_outlined, color: cs.primary),
                title: const Text(
                  'Video Çek',
                  style: TextStyle(fontFamily: 'Inter'),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  final path = await _pickAndReturnVideoPathFromCamera(context);
                  if (path != null) _insertMedia(path, true);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // ─── Build ──────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (_isLoading || controller == null) return const _LoadingScaffold();

    final colorScheme = Theme.of(context).colorScheme;
    final bgColor =
        _getAdaptiveColor(context, _selectedColor) ?? colorScheme.surface;

    // Cursor rengi: arka plana göre uyarlanır
    final Color cursorColor;
    if (_selectedColor != null) {
      final bg = _getAdaptiveColor(context, _selectedColor)!;
      cursorColor = bg.computeLuminance() < 0.5 ? Colors.white : Colors.black87;
    } else {
      cursorColor = colorScheme.primary;
    }

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
            resizeToAvoidBottomInset: true,
            appBar: _buildAppBar(colorScheme),
            body: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: Stack(
                children: [
                  Column(
                    children: [
                      _buildTitleField(colorScheme),
                      _buildDateInfo(colorScheme),
                      _buildCategoryTags(
                        colorScheme,
                        _getTextColor(colorScheme),
                      ),
                      Expanded(
                        child: Theme(
                          data: Theme.of(context).copyWith(
                            textSelectionTheme: TextSelectionThemeData(
                              cursorColor: cursorColor,
                              selectionColor: cursorColor.withValues(
                                alpha: 0.3,
                              ),
                              selectionHandleColor: cursorColor,
                            ),
                          ),
                          child: _buildEditor(colorScheme, controller),
                        ),
                      ),
                    ],
                  ),
                  // Toolbar: klavyenin hemen üstünde konumlandır
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Center(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        transitionBuilder: (child, animation) => FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position:
                                Tween<Offset>(
                                  begin: const Offset(0, 0.5),
                                  end: Offset.zero,
                                ).animate(
                                  CurvedAnimation(
                                    parent: animation,
                                    curve: Curves.easeOutCubic,
                                  ),
                                ),
                            child: child,
                          ),
                        ),
                        child: _isEditing
                            ? _buildFloatingToolbar(colorScheme, controller)
                            : const SizedBox.shrink(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getTextColor(ColorScheme colorScheme) {
    final bgColor = _getAdaptiveColor(context, _selectedColor);
    if (bgColor != null) {
      return bgColor.computeLuminance() < 0.5
          ? Colors.white.withValues(alpha: 0.95)
          : Colors.black87;
    }
    return colorScheme.onSurface;
  }

  Widget _buildTitleField(ColorScheme colorScheme) {
    final fgColor = _getTextColor(colorScheme);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: TextField(
        controller: _titleController,
        focusNode: _titleFocusNode,
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
          filled: false,
        ),
        onChanged: (_) {
          _markUnsaved();
          _scheduleAutoSave();
        },
        maxLines: null,
        textInputAction: TextInputAction.next,
      ),
    );
  }

  Widget _buildDateInfo(ColorScheme colorScheme) {
    final fgColor = _getTextColor(colorScheme);
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
            fontSize: 13,
            color: fgColor.withValues(alpha: 0.5),
            fontFamily: 'Inter',
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryTags(ColorScheme colorScheme, Color fgColor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Align(
        alignment: Alignment.centerLeft,
        child: GestureDetector(
          onTap: () => _showCategoryPicker(context, colorScheme, fgColor),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Icon(
                Icons.label_outline,
                size: 18,
                color: fgColor.withValues(alpha: 0.6),
              ),
              if (_note?.categoryId == null)
                Text(
                  context.l10n.addNoteTag,
                  style: TextStyle(
                    fontSize: 14,
                    color: fgColor.withValues(alpha: 0.6),
                    fontFamily: 'Inter',
                  ),
                )
              else if (_allCategories.any((c) => c.id == _note!.categoryId))
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: fgColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _allCategories
                        .firstWhere((c) => c.id == _note!.categoryId)
                        .name,
                    style: TextStyle(
                      fontSize: 13,
                      color: fgColor,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCategoryPicker(
    BuildContext context,
    ColorScheme colorScheme,
    Color fgColor,
  ) {
    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF1E1E1E)
                  : Colors.white,
              title: Text(
                context.l10n.noteTags,
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
                    if (_allCategories.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          context.l10n.noTagsYet,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                          ),
                        ),
                      )
                    else
                      Flexible(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: _allCategories.length,
                          itemBuilder: (context, index) {
                            final cat = _allCategories[index];
                            return ListTile(
                              title: Row(
                                children: [
                                  Text(
                                    cat.name,
                                    style: const TextStyle(fontFamily: 'Inter'),
                                  ),
                                ],
                              ),
                              trailing: Icon(
                                _note?.categoryId == cat.id
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_unchecked,
                                color: _note?.categoryId == cat.id
                                    ? colorScheme.primary
                                    : null,
                              ),
                              onTap: () {
                                setDialogState(() {
                                  setState(() {
                                    final newVal = _note?.categoryId == cat.id
                                        ? null
                                        : cat.id;
                                    _note = _note?.copyWith(
                                      categoryId: newVal,
                                      clearCategory: newVal == null,
                                    );
                                    _markUnsaved();
                                  });
                                });
                              },
                            );
                          },
                        ),
                      ),
                    const Divider(),
                    if (_note?.categoryId != null) ...[
                      ListTile(
                        leading: Icon(
                          Icons.layers_clear,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        title: Text(
                          context.l10n.removeCategory,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                        onTap: () {
                          setDialogState(() {
                            setState(() {
                              _note = _note?.copyWith(
                                categoryId: null,
                                clearCategory: true,
                              );
                              _markUnsaved();
                            });
                          });
                          Navigator.pop(ctx);
                        },
                      ),
                      const Divider(),
                    ],
                    ListTile(
                      leading: const Icon(Icons.add),
                      title: Text(
                        context.l10n.createNoteTag,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(ctx);
                        _showCreateCategoryDialog();
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(
                    context.l10n.ok,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showCreateCategoryDialog() {
    final TextEditingController nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF1E1E1E)
                  : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
              contentPadding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
              actionsPadding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              title: Text(
                context.l10n.newNoteTag,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              content: SizedBox(
                width: 360,
                child: TextField(
                  controller: nameController,
                  autofocus: true,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    hintText: context.l10n.tagName,
                    hintStyle: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                    filled: true,
                    fillColor: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest
                        .withValues(alpha: 0.3),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    context.l10n.cancel,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ),
                FilledButton(
                  onPressed: () async {
                    if (nameController.text.trim().isNotEmpty) {
                      final newCat = NoteCategoryModel.create(
                        name: nameController.text.trim(),
                      );
                      await _categoryRepository.saveCategory(newCat);
                      await _loadCategories();
                      if (mounted) {
                        setState(() {
                          _note = _note?.copyWith(categoryId: newCat.id);
                          _markUnsaved();
                        });
                      }
                      if (!ctx.mounted) return;
                      Navigator.pop(ctx);
                    }
                  },
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    context.l10n.createNoteTag,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(ColorScheme colorScheme) {
    final fgColor = _getTextColor(colorScheme);

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
        if (_controller != null)
          ListenableBuilder(
            listenable: _controller!,
            builder: (context, _) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.undo_rounded,
                      color: _controller!.hasUndo
                          ? fgColor
                          : fgColor.withValues(alpha: 0.3),
                    ),
                    onPressed: _controller!.hasUndo
                        ? () => _controller!.undo()
                        : null,
                    tooltip: 'Geri Al',
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.redo_rounded,
                      color: _controller!.hasRedo
                          ? fgColor
                          : fgColor.withValues(alpha: 0.3),
                    ),
                    onPressed: _controller!.hasRedo
                        ? () => _controller!.redo()
                        : null,
                    tooltip: 'İleri Al',
                  ),
                ],
              );
            },
          ),
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

  void _increaseFontSize() {
    final style = _controller?.getSelectionStyle();
    final currentSize = style?.attributes['size']?.value;
    if (currentSize == 'small') {
      _controller?.formatSelection(Attribute.size); // normal
    } else if (currentSize == null || currentSize == '0') {
      final attr = Attribute.fromKeyValue('size', 'large');
      if (attr != null) _controller?.formatSelection(attr);
    } else if (currentSize == 'large') {
      final attr = Attribute.fromKeyValue('size', 'huge');
      if (attr != null) _controller?.formatSelection(attr);
    }
  }

  void _decreaseFontSize() {
    final style = _controller?.getSelectionStyle();
    final currentSize = style?.attributes['size']?.value;
    if (currentSize == 'huge') {
      final attr = Attribute.fromKeyValue('size', 'large');
      if (attr != null) _controller?.formatSelection(attr);
    } else if (currentSize == 'large') {
      _controller?.formatSelection(Attribute.size); // normal
    } else if (currentSize == null || currentSize == '0') {
      final attr = Attribute.fromKeyValue('size', 'small');
      if (attr != null) _controller?.formatSelection(attr);
    }
  }

  Widget _buildFloatingToolbar(
    ColorScheme colorScheme,
    QuillController controller,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

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
                  controller: controller,
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
                        tooltip: 'Yazı Boyutunu Küçült',
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
                        tooltip: 'Yazı Boyutunu Büyüt',
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
            tooltip: 'Kapat',
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
              tooltip: 'Metin Stili',
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
              tooltip: 'Medya Ekle',
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
              tooltip: 'Bağlantı Ekle',
              onPressed: _showCustomTextLinkDialog,
            ),
          ),
          QuillSimpleToolbar(
            controller: controller,
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
                  tooltip: 'Kamera',
                  onPressed: _showCameraOptionsDialog,
                ),
                QuillSimpleToolbar(
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
                          onRequestPickImage: _pickAndReturnImagePath,
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
            tooltip: 'Kapat',
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
        linkActionPickerDelegate: (context, link, node) async {
          final result = await showModalBottomSheet<LinkMenuAction>(
            context: context,
            backgroundColor: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF1E1E1E)
                : Colors.white,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            builder: (context) {
              return SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),
                      ListTile(
                        leading: const Icon(Icons.open_in_new_rounded),
                        title: const Text(
                          'Bağlantıyı aç',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        onTap: () =>
                            Navigator.pop(context, LinkMenuAction.launch),
                      ),
                      ListTile(
                        leading: const Icon(Icons.copy_rounded),
                        title: const Text(
                          'Bağlantıyı kopyala',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        onTap: () =>
                            Navigator.pop(context, LinkMenuAction.copy),
                      ),
                      ListTile(
                        leading: const Icon(
                          Icons.link_off_rounded,
                          color: Colors.redAccent,
                        ),
                        title: const Text(
                          'Bağlantıyı kaldır',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                            color: Colors.redAccent,
                          ),
                        ),
                        onTap: () =>
                            Navigator.pop(context, LinkMenuAction.remove),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
          return result ?? LinkMenuAction.none;
        },
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
    final bodyColor = _getTextColor(cs);

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
        backgroundColor: bodyColor.withValues(alpha: 0.08),
        style: TextStyle(
          fontFamily: 'monospace',
          fontSize: 13,
          color: bodyColor,
          fontWeight: FontWeight.w600,
        ),
      ),
      code: DefaultTextBlockStyle(
        TextStyle(
          fontFamily: 'monospace',
          fontSize: 13,
          color: bodyColor.withValues(alpha: 0.9),
          height: 1.5,
        ),
        const HorizontalSpacing(12, 12),
        const VerticalSpacing(8, 8),
        const VerticalSpacing(0, 0),
        BoxDecoration(
          color: bodyColor.withValues(alpha: 0.06),
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
      link: TextStyle(
        color: bodyColor,
        decoration: TextDecoration.underline,
        decorationColor: bodyColor,
        fontWeight: FontWeight.w600,
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
  final String? label;

  const _ColorOption({
    this.color,
    required this.isSelected,
    required this.onTap,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    color ?? (isDark ? const Color(0xFF2C2C2C) : Colors.white),
                border: Border.all(
                  color: isSelected
                      ? primaryColor
                      : cs.outlineVariant.withValues(alpha: 0.5),
                  width: isSelected ? 2.5 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: primaryColor.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
              ),
              child: isSelected
                  ? Icon(
                      Icons.check_rounded,
                      size: 28,
                      color: color == null
                          ? cs.onSurface
                          : (color!.computeLuminance() < 0.5
                                ? Colors.white
                                : Colors.black87),
                    )
                  : (color == null
                        ? Icon(
                            Icons.format_color_reset_outlined,
                            color: cs.onSurface.withValues(alpha: 0.4),
                          )
                        : null),
            ),
            if (label != null) ...[
              const SizedBox(height: 6),
              Text(
                label!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  color: isSelected
                      ? primaryColor
                      : cs.onSurface.withValues(alpha: 0.6),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
