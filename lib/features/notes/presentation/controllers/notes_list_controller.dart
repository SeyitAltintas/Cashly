import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:cashly/features/notes/data/models/note_model.dart';
import 'package:cashly/features/notes/data/models/note_category_model.dart';
import 'package:cashly/features/notes/data/repositories/note_repository.dart';
import 'package:cashly/features/notes/data/repositories/note_category_repository.dart';

class NotesListController extends ChangeNotifier {
  final NoteRepository _repository;
  final NoteCategoryRepository _categoryRepository;

  bool _isDisposed = false;

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

  StreamSubscription<BoxEvent>? _boxSubscription;

  // Getters
  String get searchQuery => _searchQuery;
  // Her çağrıda yeni kopya döndür: Selector referans eşitliğine baktığı için
  // aynı Set mutate edilirse değişimi yakalayamaz.
  Set<String> get selectedNoteIds => Set.of(_selectedNoteIds);
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
      
      // Çöp kutusundaki 30 günden eski notları arka planda temizle
      _repository.cleanOldTrashNotes(30).catchError((e) {
        debugPrint('cleanOldTrashNotes error: $e');
      });

      _boxSubscription = _repository.watch().listen(_onBoxEvent);
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
    
    // EC-GHOST: Arama değiştiğinde eski seçimleri temizle (Görünmez not silme koruması)
    _selectedNoteIds.clear();

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
    
    // EC-GHOST: Filtre (Kategori) değiştiğinde eski seçimleri temizle
    _selectedNoteIds.clear();
    
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

  bool get hasSecurePin => _repository.hasSecurePin;

  Future<bool> secureSelected(String pin) async {
    final ids = _selectedNoteIds.toList();
    final unlocked = await _repository.unlockSecureNotes(pin);
    if (!unlocked) return false;
    
    await _repository.secureNotes(ids);
    clearSelection();
    await _repository.closeSecureNotes();
    notifyListeners();
    return true;
  }

  Future<void> createSecurePinAndSecureSelected(String pin) async {
    await _repository.setSecurePin(pin);
    final ids = _selectedNoteIds.toList();
    await _repository.secureNotes(ids);
    clearSelection();
    await _repository.closeSecureNotes();
    notifyListeners();
  }

  void toggleGridView() {
    _repository.setGridView(!_repository.isGridView);
    notifyListeners();
  }

  bool get selectedNotesAreAllPinned {
    if (!isSelectionMode) return false;
    final selectedNotes = visibleNotes.where(
      (n) => _selectedNoteIds.contains(n.id),
    );
    return selectedNotes.isNotEmpty && selectedNotes.every((n) => n.isPinned);
  }

  void _onBoxEvent(BoxEvent event) {
    if (!_isReady) return;
    if (event.key == 'prefs_is_grid_view') return;
    
    final id = event.key as String;
    
    if (event.deleted) {
      _allNotes.removeWhere((n) => n.id == id);
      _selectedNoteIds.remove(id);
    } else {
      final raw = event.value;
      if (raw is Map) {
        try {
          final note = NoteModel.fromMap(Map<String, dynamic>.from(raw));
          if (note.deletedAt != null) {
            _allNotes.removeWhere((n) => n.id == id);
            _selectedNoteIds.remove(id);
          } else {
            final index = _allNotes.indexWhere((n) => n.id == id);
            if (index != -1) {
              _allNotes[index] = note;
            } else {
              _allNotes.add(note);
            }
          }
        } catch (_) {}
      }
    }
    
    _allNotes.sort((a, b) {
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      return b.updatedAt.compareTo(a.updatedAt);
    });

    _updateVisibleNotes();
    notifyListeners();
  }

  void _fetchAndCacheAllNotes() {
    if (!_isReady) return;
    _allNotes = _repository.getAllNotes();

    // Ghost Selection Koruması: Seçili not silinmişse seçimden düşür.
    if (_selectedNoteIds.isNotEmpty) {
      final allNoteIds = _allNotes.map((n) => n.id).toSet();
      _selectedNoteIds.removeWhere((id) => !allNoteIds.contains(id));
    }

    _updateVisibleNotes();
  }

  void _updateVisibleNotes() {
    if (!_isReady) {
      _visibleNotes = [];
      return;
    }
    Iterable<NoteModel> notes = _allNotes;

    if (_searchQuery.isNotEmpty) {
      notes = notes.where((note) {
        // searchableText kayıt sırasında repository tarafından hesaplanır;
        // runtime'da JSON parse gerekmez (O(1) string.contains).
        final titleMatch = _toTurkishLowerCase(note.title).contains(_searchQuery);
        final contentMatch = note.searchableText.contains(_searchQuery);
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

  @override
  void notifyListeners() {
    if (!_isDisposed) {
      super.notifyListeners();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _debounceTimer?.cancel();
    _boxSubscription?.cancel();
    super.dispose();
  }
}
