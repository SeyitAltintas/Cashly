import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cashly/features/notes/utils/note_media_helper.dart';

import 'package:cashly/features/notes/presentation/widgets/note_editor_styles.dart';
import 'package:cashly/features/notes/presentation/widgets/note_editor_embed_builders.dart';

import 'package:flutter_quill/flutter_quill.dart';

import 'package:cashly/core/extensions/l10n_extensions.dart';
import 'package:cashly/core/widgets/app_snackbar.dart';
import 'package:cashly/features/notes/data/models/note_model.dart';
import 'package:cashly/features/notes/data/models/note_category_model.dart';
import 'package:cashly/features/notes/data/repositories/note_repository.dart';
import 'package:cashly/features/notes/data/repositories/note_category_repository.dart';
import 'package:cashly/features/notes/presentation/widgets/note_color_picker_sheet.dart';
import 'package:cashly/features/notes/presentation/widgets/voice_dictation_overlay.dart';
import 'package:cashly/core/di/injection_container.dart';
import 'package:cashly/features/notes/presentation/widgets/note_editor_toolbar.dart';
import 'package:cashly/features/notes/presentation/widgets/note_category_selector.dart';
import 'package:cashly/features/notes/utils/voice_dictation_manager.dart';

// ─── Sabitler ───────────────────────────────────────────────────────────────

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
  VoiceDictationManager? _voiceDictationManager;
  NoteModel? _note;
  int? _selectedColor;

  Timer? _autoSaveTimer;
  final TextEditingController _titleController = TextEditingController();

  StreamSubscription? _docSubscription;

  final FocusNode _editorFocusNode = FocusNode();
  final FocusNode _titleFocusNode = FocusNode();
  final ScrollController _editorScrollController = ScrollController();

  bool _isEditing = false;
  final NoteRepository _repository = getIt<NoteRepository>();
  final NoteCategoryRepository _categoryRepository = getIt<NoteCategoryRepository>();
  List<NoteCategoryModel> _allCategories = [];

  // Speech-to-text

  bool _isSaving = false;
  bool _saveQueued = false;
  bool _isLoading = true;

  /// Kullanıcı yükleme sonrası değişiklik yaptı mı?
  /// PopScope buna bakarak otomatik kayıt ve çıkış sürecini tetikler.
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

    if ((_voiceDictationManager?.isListening ?? false)) {
      // Dikte sırasında metin eklendiğinde editör otomatik focus alıp klavyeyi açabilir.
      // Ancak unfocus() çağırmak QuillEditor ile sonsuz bir focus savaşına girip ANR'a sebep oluyor!
      // Bu yüzden sadece işlemi yoksayıyoruz.
      return;
    }

    if (_isEditing != hasFocus && mounted) {
      setState(() => _isEditing = hasFocus);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _autoSaveTimer?.cancel();

    _docSubscription?.cancel();
    _titleController.dispose();
    _controller?.dispose();
    _editorFocusNode.removeListener(_onFocusChange);
    _titleFocusNode.removeListener(_onFocusChange);
    _editorFocusNode.dispose();
    _titleFocusNode.dispose();
    _editorScrollController.dispose();
    _voiceDictationManager?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // EC-22: Uygulama arka plana atıldığında (veya inaktif olduğunda) otomatik kaydet.
    // Bu, işletim sisteminin bellek açmak için uygulamayı öldürdüğü durumlarda veri kaybını önler.
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      if ((_voiceDictationManager?.isListening ?? false)) {
        _voiceDictationManager?.stopVoiceDictation();
      }
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

      _voiceDictationManager = VoiceDictationManager(
        context: context,
        controller: _controller!,
        onStateChanged: () {
          if (mounted) setState(() {});
        },
        onUnsavedChanges: _markUnsaved,
      );
      _isLoading = false;
      _titleController.text = note.title;
    });

    // 6. Akıllı Klavye ve Odak: Yeni not oluşturuluyorsa klavyeyi otomatik aç
    if (widget.noteId == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _editorFocusNode.requestFocus();
        }
      });
    }
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

  void _markUnsaved() {
    if (!_hasUnsavedChanges && mounted) {
      setState(() => _hasUnsavedChanges = true);
    }
  }

  void _scheduleAutoSave() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer(const Duration(seconds: 1), () {
      if (mounted) {
        _saveNote();
      }
    });
  }

  Future<void> _saveNote() async {
    final note = _note;
    final controller = _controller;
    if (note == null || controller == null) return;

    if (_isSaving) {
      _saveQueued = true;
      return;
    }

    // EC-19: Sadece \n içeren ve medya barındırmayan belgeyi kaydetme
    final plainText = controller.document.toPlainText().trim();
    final title = _titleController.text.trim();

    // Medya içerip içermediğini kontrol et
    final delta = controller.document.toDelta();
    final hasEmbed = delta.toList().any((op) => op.isInsert && op.data is Map);

    if (plainText.isEmpty && title.isEmpty && !hasEmbed) {
      if (mounted) {
        setState(() => _hasUnsavedChanges = false);
      }
      
      // UX Edge Case: Yeni not (widget.noteId == null) olsa dahi auto-save 
      // çalışmış ve veritabanına yazılmış olabilir! Bu yüzden şartı kaldırdık.
      if (note.id.isNotEmpty) {
        await _repository.deleteNotes([note.id]);
      }

      // Rebuild'i beklemek için bir frame atla, böylece PopScope canPop: true olur
      await Future.delayed(Duration.zero);
      return;
    }

    if (mounted) {
      setState(() => _isSaving = true);
    } else {
      _isSaving = true;
    }

    try {
      final deltaJson = jsonEncode(controller.document.toDelta().toJson());
      final updatedTitle = _titleController.text.trim();
      final updatedNote = await _repository.updateNote(
        id: note.id,
        deltaJson: deltaJson,
        title: updatedTitle,
        color: _selectedColor,
        clearColor: _selectedColor == null,
        categoryId: _note?.categoryId,
        clearCategory: _note?.categoryId == null,
        originalCreatedAt: note.createdAt, // EC-16: orijinal tarihi koru
      );
      if (mounted) {
        setState(() {
          _note = updatedNote;
          _hasUnsavedChanges = false;
        });
        // Sessiz otomatik kayıt (seamless save)
      }
    } catch (_) {
      // EC-SAVE-ERR: Kayıt başarısız. Hata gösterilir ve canPop=true yapılır
      // böylece kullanıcı editorde sıkışmaz.
      if (mounted) {
        AppSnackBar.error(context, context.l10n.saveFailed);
        setState(() => _hasUnsavedChanges = false);
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      } else {
        _isSaving = false;
      }
      
      if (_saveQueued) {
        _saveQueued = false;
        // EC-DATA-LOSS: mounted olmasa bile sıradaki kaydı yap!
        // Aksi takdirde PopScope çıkışında son tuş vuruşu kaybolur.
        await _saveNote();
      }
    }
  }

  // ─── Renk Seçimi ────────────────────────────────────────────────────────

  Color? _getAdaptiveColor(BuildContext context, int? colorValue) {
    if (colorValue == null) return null;
    return Color(colorValue);
  }

  // ─── Resim İşlemi ───────────────────────────────────────────────────────

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
      canPop:
          !_hasUnsavedChanges &&
          !_isSaving &&
          !_saveQueued &&
          !(_voiceDictationManager?.isDictationBoxOpen ?? false),
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;

        if ((_voiceDictationManager?.isDictationBoxOpen ?? false)) {
          setState(() {
            _voiceDictationManager?.stopVoiceDictation();
            _controller?.readOnly = false;
          });
          if ((_voiceDictationManager?.isListening ?? false)) {
            _voiceDictationManager?.stopVoiceDictation();
          }
          return;
        }

        if (_hasUnsavedChanges || _isSaving || _saveQueued) {
          // Klavyeyi kapat
          FocusScope.of(context).unfocus();
          
          if (_hasUnsavedChanges) {
            await _saveNote();
          }
          
          // EĞER OTOMATİK KAYIT ÇALIŞIYORSA BİTMESİNİ BEKLE (Back Button Ignoring Bug Fix)
          // Aksi takdirde await _saveNote() anında döner, hasUnsavedChanges true kalır
          // ve Navigator.pop asla çağrılmaz (Kullanıcı ekranda hapsolur)!
          while (_isSaving || _saveQueued) {
            await Future.delayed(const Duration(milliseconds: 50));
          }

          if (mounted) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                Navigator.of(context).pop();
              }
            });
          }
        }
      },
      // Hero kaldırıldı: Scaffold içinde SnackBar'ın kendi Hero'su ile çakışıyordu.
      // ("A Hero widget cannot be the descendant of another Hero widget" assertion)
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        color: bgColor,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          resizeToAvoidBottomInset: true,
          appBar: _buildAppBar(colorScheme),
          body: GestureDetector(
            onTap: () {
              // Sesli dikte aktifken dokunma ile klavye açılmasını engelle
              if (!(_voiceDictationManager?.isListening ?? false)) {
                FocusScope.of(context).unfocus();
              }
            },
            child: Stack(
              children: [
                Column(
                  children: [
                    _buildTitleField(colorScheme),
                    _buildDateInfo(colorScheme),
                    NoteCategorySelector(
                      selectedCategoryId: _note?.categoryId,
                      categories: _allCategories,
                      colorScheme: colorScheme,
                      fgColor: _getTextColor(colorScheme),
                      onCategorySelected: (categoryId) {
                        setState(() {
                          _note = _note?.copyWith(
                            categoryId: categoryId,
                            clearCategory: categoryId == null,
                          );
                          _hasUnsavedChanges = true;
                        });
                        _scheduleAutoSave();
                      },
                      onCategoryCreated: (newCat) async {
                        await _categoryRepository.saveCategory(newCat);
                        await _loadCategories();
                        if (mounted) {
                          setState(() {
                            _note = _note?.copyWith(categoryId: newCat.id);
                            _markUnsaved();
                          });
                        }
                      },
                    ),
                    Expanded(
                      child: Theme(
                        data: Theme.of(context).copyWith(
                          textSelectionTheme: TextSelectionThemeData(
                            cursorColor: cursorColor,
                            selectionColor: cursorColor.withValues(alpha: 0.3),
                            selectionHandleColor: cursorColor,
                          ),
                        ),
                        child: _buildEditor(colorScheme, controller),
                      ),
                    ),
                  ],
                ),
                // Toolbar: dinleme aktifken gizle
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
                      child:
                          _isEditing &&
                              !(_voiceDictationManager?.isDictationBoxOpen ??
                                  false)
                          ? NoteEditorToolbar(
                              controller: controller,
                              onMarkUnsaved: _markUnsaved,
                              onStartVoiceDictation: () =>
                                  _voiceDictationManager?.startVoiceDictation(),
                              onPickImageFromGallery: (ctx) =>
                                  NoteMediaHelper.pickImage(
                                    ctx,
                                    fromCamera: false,
                                  ),
                              onPickVideoFromGallery: (ctx) =>
                                  NoteMediaHelper.pickVideo(
                                    ctx,
                                    fromCamera: false,
                                  ),
                              onTakePhoto: () async {
                                final path = await NoteMediaHelper.pickImage(
                                  context,
                                  fromCamera: true,
                                );
                                // EC-UNMOUNTED: Kopyalama bitene kadar kullanıcı çıkmış olabilir!
                                if (path != null && mounted) {
                                  NoteMediaHelper.insertMedia(
                                    controller: _controller!,
                                    path: path,
                                    isVideo: false,
                                    onMediaInserted: _markUnsaved,
                                  );
                                }
                              },
                              onRecordVideo: () async {
                                final path = await NoteMediaHelper.pickVideo(
                                  context,
                                  fromCamera: true,
                                );
                                if (path != null) {
                                  NoteMediaHelper.insertMedia(
                                    controller: _controller!,
                                    path: path,
                                    isVideo: true,
                                    onMediaInserted: _markUnsaved,
                                  );
                                }
                              },
                            )
                          : const SizedBox.shrink(),
                    ),
                  ),
                ),
                // Sesli dikte aktifken gösterilen floating overlay
                if ((_voiceDictationManager?.isDictationBoxOpen ?? false))
                  VoiceDictationOverlay(
                    isListening: (_voiceDictationManager?.isListening ?? false),
                    onToggleListening: () =>
                        _voiceDictationManager?.toggleListening(),
                  ),
              ],
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
    return Listener(
      onPointerDown: (_) {
        if ((_voiceDictationManager?.isDictationBoxOpen ?? false)) {
          setState(() {
            _voiceDictationManager?.stopVoiceDictation();
            _controller?.readOnly = false;
          });
          if ((_voiceDictationManager?.isListening ?? false)) {
            _voiceDictationManager?.stopVoiceDictation();
          }
        }
      },
      child: Padding(
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
            hintText: context.l10n.noteUntitled,
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
      ),
    );
  }

  Widget _buildDateInfo(ColorScheme colorScheme) {
    final fgColor = _getTextColor(colorScheme);
    // EC-TIMEZONE: toLocal() ile UTC → yerel saat dönüşümü garantilenir.
    final date = (_note?.updatedAt ?? DateTime.now()).toLocal();
    final timeString =
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          context.l10n.lastEditedAt(timeString),
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
                      color:
                          (_controller!.hasUndo &&
                              !(_voiceDictationManager?.isDictationBoxOpen ??
                                  false))
                          ? fgColor
                          : fgColor.withValues(alpha: 0.3),
                    ),
                    onPressed:
                        (_controller!.hasUndo &&
                            !(_voiceDictationManager?.isDictationBoxOpen ??
                                false))
                        ? () => _controller!.undo()
                        : null,
                    tooltip: context.l10n.undoAction,
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.redo_rounded,
                      color:
                          (_controller!.hasRedo &&
                              !(_voiceDictationManager?.isDictationBoxOpen ??
                                  false))
                          ? fgColor
                          : fgColor.withValues(alpha: 0.3),
                    ),
                    onPressed:
                        (_controller!.hasRedo &&
                            !(_voiceDictationManager?.isDictationBoxOpen ??
                                false))
                        ? () => _controller!.redo()
                        : null,
                    tooltip: context.l10n.redoAction,
                  ),
                ],
              );
            },
          ),
        IconButton(
          icon: Icon(Icons.color_lens_outlined, color: fgColor),
          onPressed: () {
            FocusScope.of(context).unfocus();
            NoteColorPickerSheet.show(context, _selectedColor, (color) {
              setState(() => _selectedColor = color);
              _markUnsaved();
            });
          },
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
          // EC-CHECK-BTN: check butonu kaydetmeden çıkmayı önler;
          // _saveNote() çalıştırılır ve sonra sayfa kapatılır.
          IconButton(
            icon: Icon(Icons.check_rounded, color: fgColor),
            onPressed: () async {
              FocusScope.of(context).unfocus();
              if (_hasUnsavedChanges) {
                await _saveNote();
              }
              if (mounted) {
                Navigator.of(context).pop();
              }
            },
          ),
      ],
    );
  }

  Widget _buildEditor(ColorScheme colorScheme, QuillController controller) {
    return Listener(
      onPointerDown: (_) {
        if ((_voiceDictationManager?.isDictationBoxOpen ?? false)) {
          setState(() {
            _voiceDictationManager?.stopVoiceDictation();
            _controller?.readOnly = false;
          });
          if ((_voiceDictationManager?.isListening ?? false)) {
            _voiceDictationManager?.stopVoiceDictation();
          }
          // Rebuild sonrası editörün focus alabilmesi için post frame callback kullanıyoruz
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _editorFocusNode.requestFocus();
            }
          });
        }
      },
      child: QuillEditor(
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
                          title: Text(
                            context.l10n.openLink,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          onTap: () =>
                              Navigator.pop(context, LinkMenuAction.launch),
                        ),
                        ListTile(
                          leading: const Icon(Icons.copy_rounded),
                          title: Text(
                            context.l10n.copyLink,
                            style: const TextStyle(
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
                          title: Text(
                            context.l10n.removeLink,
                            style: const TextStyle(
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
          embedBuilders: NoteEditorEmbedBuilders.build(context),
          customStyles: NoteEditorStyles.buildStyles(
            colorScheme,
            _getTextColor(colorScheme),
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
