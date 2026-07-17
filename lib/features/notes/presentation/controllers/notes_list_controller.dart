import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:cashly/features/notes/data/models/note_model.dart';
import 'package:cashly/features/notes/data/models/note_category_model.dart';
import 'package:cashly/features/notes/data/repositories/note_repository.dart';
import 'package:cashly/features/notes/data/repositories/note_category_repository.dart';

class NotesListController extends ChangeNotifier {
  final NoteRepository _repository;
  final NoteCategoryRepository _categoryRepository;

  NotesListController({
    required NoteRepository repository,
    required NoteCategoryRepository categoryRepository,
  })  : _repository = repository,
        _categoryRepository = categoryRepository;

  String _searchQuery = '';
  final Set<String> _selectedNoteIds = {};
  bool _isReady = false;
  String? _selectedFilterId;
  List<NoteCategoryModel> _allCategories = [];
  List<NoteModel> _allNotes = [];
  List<NoteModel> _visibleNotes = [];

  Timer? _debounceTimer;

  late final VoidCallback _boxListener;
  ValueListenable<Box>? _boxListenable;

  // Performans optimizasyonu için in-memory arama önbelleği
  final Map<String, String> _plainTextCache = {};

  // Getters
  String get searchQuery => _searchQuery;
  Set<String> get selectedNoteIds => _selectedNoteIds;
  bool get isReady => _isReady;
  String? get selectedFilterId => _selectedFilterId;
  List<NoteCategoryModel> get allCategories => _allCategories;
  List<NoteModel> get visibleNotes => _visibleNotes;
  bool get isSelectionMode => _selectedNoteIds.isNotEmpty;
  bool get isGridView => _repository.isGridView;
  NoteRepository get repository => _repository;
  NoteCategoryRepository get categoryRepository => _categoryRepository;

  Future<void> init() async {
    if (_isReady) return; // Çift tetiklenme koruması (Double-init prevention)
    
    try {
      await _repository.init();
      await _categoryRepository.init();

      _allCategories = _categoryRepository.getAllCategories();
      _isReady = true;
      _fetchAndCacheAllNotes();
      notifyListeners();

      _boxListener = () {
        _fetchAndCacheAllNotes();
        notifyListeners();
      };
      _boxListenable = _repository.listenable();
      _boxListenable!.addListener(_boxListener);
    } catch (e) {
      // DB yüklenirken hata çıkarsa ekranda sonsuz loading dönmesini engelle
      debugPrint('NotesListController init error: $e');
      _isReady = true;
      notifyListeners();
    }
  }

  void refreshCategories() {
    _allCategories = _categoryRepository.getAllCategories();
    _updateVisibleNotes();
    notifyListeners();
  }

  void setSearchQuery(String query) {
    final lowerQuery = _toTurkishLowerCase(query);
    if (_searchQuery == lowerQuery) return;
    
    _searchQuery = lowerQuery;

    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();

    // Arama tamamen temizlendiyse listeyi anında getir (bekleme)
    if (lowerQuery.isEmpty) {
      _updateVisibleNotes();
      notifyListeners();
      return;
    }

    // 300ms Debounce: UI hemen tepki versin diye notifyListeners çağrılır ama filtreleme gecikir
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _updateVisibleNotes();
      notifyListeners();
    });

    notifyListeners();
  }

  void setFilter(String? filterId) {
    _selectedFilterId = filterId;
    _updateVisibleNotes();
    notifyListeners();
  }

  void toggleSelection(String id) {
    if (_selectedNoteIds.contains(id)) {
      _selectedNoteIds.remove(id);
    } else {
      _selectedNoteIds.add(id);
    }
    notifyListeners();
  }

  void clearSelection() {
    _selectedNoteIds.clear();
    notifyListeners();
  }

  void selectAll() {
    final notes = visibleNotes;
    if (notes.isEmpty) return;

    final allSelected = notes.every((n) => _selectedNoteIds.contains(n.id));
    if (allSelected) {
      for (final n in notes) {
        _selectedNoteIds.remove(n.id);
      }
    } else {
      _selectedNoteIds.addAll(notes.map((n) => n.id));
    }
    notifyListeners();
  }

  Future<void> togglePinSelected() async {
    final ids = _selectedNoteIds.toList();
    final allPinned = selectedNotesAreAllPinned;
    await _repository.setPinStateForNotes(ids, !allPinned);
  }

  Future<void> deleteSelected() async {
    final ids = _selectedNoteIds.toList();
    clearSelection();
    await _repository.deleteNotes(ids);
  }

  void toggleGridView() {
    _repository.setGridView(!_repository.isGridView);
  }

  bool get selectedNotesAreAllPinned {
    if (!isSelectionMode) return false;
    final selectedNotes = visibleNotes.where(
      (n) => _selectedNoteIds.contains(n.id),
    );
    return selectedNotes.isNotEmpty && selectedNotes.every((n) => n.isPinned);
  }

  void _fetchAndCacheAllNotes() {
    if (!_isReady) return;
    _allNotes = _repository.getAllNotes();

    // Uç Durum (Edge Case): Eğer seçili bir not silinirse, seçili ID'ler listesinden otomatik olarak düşsün (Ghost Selection Koruması)
    if (_selectedNoteIds.isNotEmpty) {
      final allNoteIds = _allNotes.map((n) => n.id).toSet();
      _selectedNoteIds.removeWhere((id) => !allNoteIds.contains(id));
    }

    // Önbellek Çöp Toplayıcı (Cache Garbage Collector): 
    // Yalnızca güncel notların cache anahtarlarını tut, silinmiş veya düzenlenmiş (tarihi değişmiş) olanların çöpünü bellekten temizle.
    final validCacheKeys = _allNotes.map((n) => '${n.id}_${n.updatedAt.millisecondsSinceEpoch}').toSet();
    _plainTextCache.removeWhere((key, _) => !validCacheKeys.contains(key));

    _updateVisibleNotes();
  }

  void _updateVisibleNotes() {
    if (!_isReady) {
      _visibleNotes = [];
      return;
    }
    Iterable<NoteModel> notes = _allNotes;

    // Bellek Sızıntısı Koruması: Önbellekteki ölü (eski) kayıtları temizle
    if (_plainTextCache.length > notes.length + 200) {
      final activeKeys = notes.map((n) => '${n.id}_${n.updatedAt.millisecondsSinceEpoch}').toSet();
      _plainTextCache.removeWhere((key, _) => !activeKeys.contains(key));
    }

    if (_searchQuery.isNotEmpty) {
      notes = notes.where((note) {
        final titleMatch = _toTurkishLowerCase(note.title).contains(_searchQuery);
        final contentMatch = _getCachedPlainText(note).contains(_searchQuery);
        return titleMatch || contentMatch;
      });
    }
    if (_selectedFilterId == 'pinned') {
      notes = notes.where((note) => note.isPinned);
    } else if (_selectedFilterId != null) {
      notes = notes.where((note) => note.categoryId == _selectedFilterId);
    }
    _visibleNotes = notes.toList();
  }

  String _toTurkishLowerCase(String text) {
    return text.replaceAll('I', 'ı').replaceAll('İ', 'i').toLowerCase();
  }

  String _getCachedPlainText(NoteModel note) {
    final cacheKey = '${note.id}_${note.updatedAt.millisecondsSinceEpoch}';
    if (_plainTextCache.containsKey(cacheKey)) {
      return _plainTextCache[cacheKey]!;
    }

    final plainText = _extractPlainText(note.deltaJson);
    _plainTextCache[cacheKey] = plainText;

    return plainText;
  }

  String _extractPlainText(String deltaJson) {
    if (deltaJson.isEmpty || deltaJson == '[]') return '';
    try {
      final List<dynamic> ops = jsonDecode(deltaJson);
      final buffer = StringBuffer();
      for (final op in ops) {
        if (op is Map<String, dynamic> && op.containsKey('insert')) {
          final insert = op['insert'];
          if (insert is String) {
            buffer.write(insert);
          }
        }
      }
      return _toTurkishLowerCase(buffer.toString().trim());
    } catch (_) {
      return _toTurkishLowerCase(deltaJson);
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _boxListenable?.removeListener(_boxListener);
    super.dispose();
  }
}
