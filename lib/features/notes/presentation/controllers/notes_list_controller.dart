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
    NoteRepository? repository,
    NoteCategoryRepository? categoryRepository,
  }) : _repository = repository ?? NoteRepository(),
       _categoryRepository = categoryRepository ?? NoteCategoryRepository();

  String _searchQuery = '';
  final Set<String> _selectedNoteIds = {};
  bool _isReady = false;
  String? _selectedFilterId;
  List<NoteCategoryModel> _allCategories = [];

  late final VoidCallback _boxListener;
  ValueListenable<Box>? _boxListenable;

  // Getters
  String get searchQuery => _searchQuery;
  Set<String> get selectedNoteIds => _selectedNoteIds;
  bool get isReady => _isReady;
  String? get selectedFilterId => _selectedFilterId;
  List<NoteCategoryModel> get allCategories => _allCategories;
  bool get isSelectionMode => _selectedNoteIds.isNotEmpty;
  bool get isGridView => _repository.isGridView;
  NoteRepository get repository => _repository;
  NoteCategoryRepository get categoryRepository => _categoryRepository;

  Future<void> init() async {
    await _repository.init();
    await _categoryRepository.init();

    _allCategories = _categoryRepository.getAllCategories();
    _isReady = true;
    notifyListeners();

    _boxListener = () {
      notifyListeners();
    };
    _boxListenable = _repository.listenable();
    _boxListenable!.addListener(_boxListener);
  }

  void refreshCategories() {
    _allCategories = _categoryRepository.getAllCategories();
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = _toTurkishLowerCase(query);
    notifyListeners();
  }

  void setFilter(String? filterId) {
    _selectedFilterId = filterId;
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

  List<NoteModel> get visibleNotes {
    if (!_isReady) return [];
    List<NoteModel> notes = _repository.getAllNotes();
    if (_searchQuery.isNotEmpty) {
      notes = notes.where((note) {
        final titleMatch = _toTurkishLowerCase(
          note.title,
        ).contains(_searchQuery);
        final contentMatch = _extractPlainText(
          note.deltaJson,
        ).contains(_searchQuery);
        return titleMatch || contentMatch;
      }).toList();
    }
    if (_selectedFilterId == 'pinned') {
      notes = notes.where((note) => note.isPinned).toList();
    } else if (_selectedFilterId != null) {
      notes = notes
          .where((note) => note.categoryId == _selectedFilterId)
          .toList();
    }
    return notes;
  }

  String _toTurkishLowerCase(String text) {
    return text.replaceAll('I', 'ı').replaceAll('İ', 'i').toLowerCase();
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
    _boxListenable?.removeListener(_boxListener);
    super.dispose();
  }
}
