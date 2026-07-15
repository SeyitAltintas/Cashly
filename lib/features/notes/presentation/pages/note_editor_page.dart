import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:path_provider/path_provider.dart';

import 'package:flutter/services.dart';
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
import 'package:cashly/core/services/speech/speech_service.dart';
import 'package:cashly/features/notes/presentation/widgets/note_color_picker_sheet.dart';
import 'package:cashly/features/notes/presentation/widgets/voice_dictation_overlay.dart';
import 'package:cashly/features/notes/presentation/widgets/note_editor_toolbar.dart';
import 'package:cashly/features/notes/presentation/widgets/note_category_selector.dart';

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
  Timer? _voicePauseTimer; // Konuşma duraksamalarını algılamak için
  Timer?
  _voiceSilenceTimer; // 3 saniyelik sessizlik durumunda mikrofonu kapatmak için
  final TextEditingController _titleController = TextEditingController();

  StreamSubscription? _docSubscription;

  final FocusNode _editorFocusNode = FocusNode();
  final FocusNode _titleFocusNode = FocusNode();
  final ScrollController _editorScrollController = ScrollController();

  bool _isEditing = false;
  final ImagePicker _imagePicker = ImagePicker();
  final NoteRepository _repository = NoteRepository();
  final NoteCategoryRepository _categoryRepository = NoteCategoryRepository();
  List<NoteCategoryModel> _allCategories = [];

  // Speech-to-text
  final SpeechService _speechService = SpeechService();
  bool _isDictationBoxOpen = false;
  bool _isListening = false;
  bool _isRestarting = false; // Eş zamanlı yeniden başlamayı engeller
  String _interimText = ''; // Son partial metin
  int _interimOffset = -1; // Interim metnin başladığı Quill offset'i

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

    if (_isListening) {
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
    _voicePauseTimer?.cancel();
    _voiceSilenceTimer?.cancel();
    _docSubscription?.cancel();
    _titleController.dispose();
    _controller?.dispose();
    _editorFocusNode.removeListener(_onFocusChange);
    _titleFocusNode.removeListener(_onFocusChange);
    _editorFocusNode.dispose();
    _titleFocusNode.dispose();
    _editorScrollController.dispose();
    _speechService.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // EC-22: Uygulama arka plana atıldığında (veya inaktif olduğunda) otomatik kaydet.
    // Bu, işletim sisteminin bellek açmak için uygulamayı öldürdüğü durumlarda veri kaybını önler.
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      if (_isListening) {
        _stopVoiceDictation();
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
      await _repository.updateNote(
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
        setState(() => _hasUnsavedChanges = false);
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
      }
      if (_saveQueued) {
        _saveQueued = false;
        if (mounted) {
          _saveNote();
        }
      }
    }
  }

  // ─── Renk Seçimi ────────────────────────────────────────────────────────

  Color? _getAdaptiveColor(BuildContext context, int? colorValue) {
    if (colorValue == null) return null;
    return Color(colorValue);
  }

  // ─── Resim İşlemi ───────────────────────────────────────────────────────

  Future<String?> _pickAndReturnVideoPath(BuildContext context) async {
    try {
      final picked = await _imagePicker.pickVideo(source: ImageSource.gallery);
      if (picked == null) return null;

      final appDir = await getApplicationDocumentsDirectory();
      final notesVidDir = Directory('${appDir.path}/notes_videos');
      if (!await notesVidDir.exists()) {
        await notesVidDir.create(recursive: true);
      }
      final parts = picked.path.split('.');
      final ext = parts.length > 1 ? parts.last : 'mp4';
      final fileName =
          '${DateTime.now().microsecondsSinceEpoch}_${Random().nextInt(9000) + 1000}.$ext';
      final dest = File('${notesVidDir.path}/$fileName');
      await File(picked.path).copy(dest.path);
      return dest.path;
    } catch (e) {
      debugPrint('Video pick error: $e');
      return null;
    }
  }

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
    final c = _controller;
    if (c == null) return;

    final index = c.selection.baseOffset;
    final length = c.selection.extentOffset - index;

    if (length > 0) {
      c.document.delete(index, length);
    }

    c.document.insert(
      index,
      isVideo ? BlockEmbed.video(path) : BlockEmbed.image(path),
    );

    c.document.insert(index + 1, '\n');
    c.updateSelection(
      TextSelection.collapsed(offset: index + 2),
      ChangeSource.local,
    );

    _markUnsaved();
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
        AppSnackBar.error(context, context.l10n.videoUploadError);
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
      canPop: !_hasUnsavedChanges && !_isDictationBoxOpen,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;

        if (_isDictationBoxOpen) {
          setState(() {
            _isDictationBoxOpen = false;
            _controller?.readOnly = false;
          });
          if (_isListening) _stopVoiceDictation();
          return;
        }

        if (_hasUnsavedChanges) {
          // Klavyeyi kapat — pop animasyonu sırasında klavyenin bir sonraki sayfaya
          // yapışmasını önler (geri tuşu ile çıkışta klavye ekranda asilı kalabilir)
          FocusScope.of(context).unfocus();
          await _saveNote();
          if (mounted && !_hasUnsavedChanges) {
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
              if (!_isListening) FocusScope.of(context).unfocus();
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
                      child: _isEditing && !_isDictationBoxOpen
                          ? NoteEditorToolbar(
                              controller: controller,
                              onMarkUnsaved: _markUnsaved,
                              onStartVoiceDictation: _startVoiceDictation,
                              onPickImageFromGallery: _pickAndReturnImagePath,
                              onPickVideoFromGallery: _pickAndReturnVideoPath,
                              onTakePhoto: () async {
                                final path =
                                    await _pickAndReturnImagePathFromCamera(
                                      context,
                                    );
                                if (path != null) _insertMedia(path, false);
                              },
                              onRecordVideo: () async {
                                final path =
                                    await _pickAndReturnVideoPathFromCamera(
                                      context,
                                    );
                                if (path != null) _insertMedia(path, true);
                              },
                            )
                          : const SizedBox.shrink(),
                    ),
                  ),
                ),
                // Sesli dikte aktifken gösterilen floating overlay
                if (_isDictationBoxOpen)
                  VoiceDictationOverlay(
                    isListening: _isListening,
                    onToggleListening: _toggleListening,
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
        if (_isDictationBoxOpen) {
          setState(() {
            _isDictationBoxOpen = false;
            _controller?.readOnly = false;
          });
          if (_isListening) _stopVoiceDictation();
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

  // ─── Sesli Dikte ────────────────────────────────────────────────────────

  /// Dinleme aktifken ekranın altında gösterilen yuvarlak overlay.
  Future<void> _startVoiceDictation() async {
    if (_controller == null || _isListening) return;

    // Önce focus'u kaldır ve klavyeyi kesin olarak gizle.
    // Bunu _isListening = true olmadan önce yapıyoruz ki _onFocusChange
    // tetiklendiğinde return ile çıkış yapmasın ve _isEditing state'i false olabilsin.
    FocusScope.of(context).unfocus();
    SystemChannels.textInput.invokeMethod('TextInput.hide');

    // Toolbar ve klavyeyi kapat (await öncesinde - context async gap önler)
    setState(() {
      _controller?.readOnly = true;
      _isDictationBoxOpen = true;
      _isListening = true; // Anında aktif et ki double-tap engellensin
    });

    final success = await _speechService.initialize();
    if (!success) {
      if (mounted) {
        setState(() {
          _isListening = false;
          _isDictationBoxOpen = false;
          _controller?.readOnly = false;
        });
        AppSnackBar.error(context, context.l10n.micAccessDenied);
      }
      return;
    }

    if (!mounted) return;
    _interimText = '';
    _interimOffset = -1;
    _isRestarting = false;
    _voicePauseTimer?.cancel();

    _resetVoiceSilenceTimer();
    await _resumeListeningSession();
  }

  /// Bir dinleme oturumu başlatır. Her cümle bittiğinde otomatik yeniden
  /// başlar — kullanıcı elle durdurana kadar kapanmaz.
  Future<void> _resumeListeningSession() async {
    if (!_isListening || !mounted || _isRestarting) return;

    _resetVoiceSilenceTimer();

    await _speechService.startListening(
      onResult: (text, {required bool isFinal}) {
        if (!mounted || !_isListening) return;

        if (text.trim().isNotEmpty) {
          _resetVoiceSilenceTimer();
        }

        if (isFinal) {
          if (text.isNotEmpty) _applyInterimText(text);
          _commitInterimText();
          _markUnsaved();
          _scheduleAutoSave();
        } else {
          _applyInterimText(text);
        }
      },
      onStatus: (status) {
        if (!mounted || !_isListening) return;

        if (status.startsWith('error')) {
          final errorMsg = status.split(':').length > 1
              ? status.split(':')[1]
              : '';

          if (errorMsg == 'error_no_match' ||
              errorMsg == 'error_speech_timeout' ||
              errorMsg == 'error_busy') {
            // Sessizlikten kaynaklı hata ise sadece return yap.
            // Motor zaten done statüsüne geçip yeniden başlatılacak.
            return;
          }

          // Kalici bir hata olusursa
          _stopVoiceDictation();
          if (mounted) {
            String userMsg = context.l10n.voiceRecognitionError;
            if (errorMsg == 'error_network') {
              userMsg = context.l10n.internetDisconnectedOrWeak;
            } else if (errorMsg == 'error_audio_error' ||
                errorMsg == 'error_client') {
              userMsg = context.l10n.micUnavailable;
            } else if (errorMsg == 'error_listen_failed') {
              userMsg = context.l10n.micInUseByOtherApp;
            }

            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(userMsg)));
          }
          return;
        }

        if (status == 'done' || status == 'notListening') {
          // Motor herhangi bir sebeple durursa (sessizlik, hata, final vs)
          _commitInterimText();
          _markUnsaved();
          _scheduleAutoSave();

          if (!_isRestarting) {
            _isRestarting = true;
            Future.delayed(const Duration(milliseconds: 250), () async {
              _isRestarting = false;
              if (mounted && _isListening) await _resumeListeningSession();
            });
          }
        }
      },
    );
  }

  /// Partial / final tanıma sonucunu Quill dokümanına yansıt.
  void _applyInterimText(String newText) {
    // Boş sonucu yok say: motor duraksama sırasında boş partial gönderebilir.
    if (newText.isEmpty) return;

    final controller = _controller;
    if (controller == null) return;

    // Önceki interim bloğunu kesin offsetinden sil
    if (_interimText.isNotEmpty && _interimOffset >= 0) {
      controller.replaceText(
        _interimOffset,
        _interimText.length,
        '',
        TextSelection.collapsed(offset: _interimOffset),
      );
    }

    _interimText = newText;
    final doc = controller.document;

    // Eğer yeni bir cümleye başlıyorsak, imlecin o anki konumunu baz al
    if (_interimOffset < 0) {
      final selection = controller.selection;
      if (selection.isValid) {
        if (!selection.isCollapsed) {
          // Secili metin varsa, once onu sil
          final start = selection.start;
          final length = selection.end - selection.start;
          controller.replaceText(
            start,
            length,
            '',
            TextSelection.collapsed(offset: start),
          );
          _interimOffset = start.clamp(0, controller.document.length - 1);
        } else {
          _interimOffset = selection.baseOffset.clamp(0, doc.length - 1);
        }
      } else {
        _interimOffset = (doc.length - 1).clamp(0, doc.length - 1);
      }
    }

    controller.replaceText(
      _interimOffset,
      0,
      newText,
      TextSelection.collapsed(offset: _interimOffset + newText.length),
    );

    // Duraksama (Pause) tespiti:
    // Android SpeechToText bazen isFinal fırlatmadan yeni bir cümleye başlayabilir.
    // Bu durumda eski cümlenin silinmesini önlemek için 1.2 saniyelik bir timer kuruyoruz.
    _voicePauseTimer?.cancel();
    _voicePauseTimer = Timer(const Duration(milliseconds: 1200), () {
      if (mounted && _isListening && _interimText.isNotEmpty) {
        _commitInterimText();
        _markUnsaved();
        _scheduleAutoSave();
      }
    });
  }

  /// Interim metni kalıcı yap ve iki cümle arasına boşluk ekle.
  void _resetVoiceSilenceTimer() {
    _voiceSilenceTimer?.cancel();
    if (!_isListening) return;

    _voiceSilenceTimer = Timer(const Duration(seconds: 6), () {
      if (mounted && _isListening) {
        _stopVoiceDictation();
      }
    });
  }

  void _commitInterimText({bool addSeparator = true}) {
    if (addSeparator && _interimText.isNotEmpty && _interimOffset >= 0) {
      // Noktalı virgul / cümle arası boşluk
      final controller = _controller;
      if (controller != null) {
        final spaceOffset = _interimOffset + _interimText.length;
        final maxOffset = (controller.document.length - 1).clamp(
          0,
          controller.document.length - 1,
        );
        if (spaceOffset <= maxOffset) {
          controller.replaceText(
            spaceOffset,
            0,
            ' ',
            TextSelection.collapsed(offset: spaceOffset + 1),
          );
        }
      }
    }
    _voicePauseTimer?.cancel();
    _interimText = '';
    _interimOffset = -1;
  }

  Future<void> _toggleListening() async {
    if (_isListening) {
      await _stopVoiceDictation();
    } else {
      setState(() => _isListening = true);
      await _resumeListeningSession();
    }
  }

  Future<void> _stopVoiceDictation() async {
    if (!_isListening) return;
    // Flag önce false — restart döngüsünü kır
    setState(() => _isListening = false);
    _isRestarting = false;

    // Bekleyen interim metni sil (cancel— yazilmamis partial)
    // veya kullanıcı konuyu yarıda bırakmışsa commit et (sessiz kalma)
    _voicePauseTimer?.cancel();
    _voiceSilenceTimer?.cancel();
    _commitInterimText(addSeparator: false);

    // Focus node'ları kutu kapandığında aktifleştirilecek (_closeDictationBox içinde)

    await _speechService.stopListening();

    if (mounted) {
      _markUnsaved();
      _scheduleAutoSave();
    }
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
                      color: (_controller!.hasUndo && !_isDictationBoxOpen)
                          ? fgColor
                          : fgColor.withValues(alpha: 0.3),
                    ),
                    onPressed: (_controller!.hasUndo && !_isDictationBoxOpen)
                        ? () => _controller!.undo()
                        : null,
                    tooltip: context.l10n.undoAction,
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.redo_rounded,
                      color: (_controller!.hasRedo && !_isDictationBoxOpen)
                          ? fgColor
                          : fgColor.withValues(alpha: 0.3),
                    ),
                    onPressed: (_controller!.hasRedo && !_isDictationBoxOpen)
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Listener(
      onPointerDown: (_) {
        if (_isDictationBoxOpen) {
          setState(() {
            _isDictationBoxOpen = false;
            _controller?.readOnly = false;
          });
          if (_isListening) _stopVoiceDictation();
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
