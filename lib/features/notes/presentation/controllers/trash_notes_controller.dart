import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:cashly/features/notes/data/models/note_model.dart';
import 'package:cashly/features/notes/data/repositories/note_repository.dart';

class TrashNotesController extends ChangeNotifier {
  final NoteRepository _repository;
  bool _isDisposed = false;

  TrashNotesController({required NoteRepository repository})
      : _repository = repository;

  List<NoteModel> _trashNotes = [];
  final Set<String> _selectedNoteIds = {};

  late final VoidCallback _boxListener;
  ValueListenable<Box>? _boxListenable;

  List<NoteModel> get trashNotes => _trashNotes;
  Set<String> get selectedNoteIds => Set.of(_selectedNoteIds);
  bool get isSelectionMode => _selectedNoteIds.isNotEmpty;

  bool _isInitialized = false;

  // BUG 10 FIX: init() senkrondu; repository initÔÇÖi bitmeden
  // getTrashNotes() ├ğa─ş─▒r─▒l─▒yordu ÔÇö _indexBox null iken bo┼ş liste d├Ân├╝yordu.
  // listenable() ├ğa─ş─▒r─▒s─▒ da requireIndexBox assert f─▒rlatabiliyordu.
  Future<void> init() async {
    if (_isInitialized) return; // ├çift init korumas─▒
    _isInitialized = true;

    // Repository kutular─▒ a├ğ─▒k de─şilse ├Ânce ba┼şlat.
    await _repository.init();

    _fetchTrashNotes();

    _boxListener = () {
      _fetchTrashNotes();
      notifyListeners();
    };
    _boxListenable = _repository.listenable();
    _boxListenable!.addListener(_boxListener);
  }

  void _fetchTrashNotes() {
    _trashNotes = _repository.getTrashNotes();

    if (_selectedNoteIds.isNotEmpty) {
      final allNoteIds = _trashNotes.map((n) => n.id).toSet();
      _selectedNoteIds.removeWhere((id) => !allNoteIds.contains(id));
    }
  }

  /// BUG 36 FIX: TrashNotesController singleton olduğu için
  /// sayfa tekrar açıldığında init() skip edilir ve eski veriler gösterilir.
  /// refresh() her sayfa açılışında çağrılır ve cache'i zorla günceller.
  void refresh() {
    if (!_isInitialized) return;
    _fetchTrashNotes();
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
    if (_trashNotes.isEmpty) return;

    final allSelected = _trashNotes.every((n) => _selectedNoteIds.contains(n.id));
    if (allSelected) {
      _selectedNoteIds.clear();
    } else {
      _selectedNoteIds.addAll(_trashNotes.map((n) => n.id));
    }
    notifyListeners();
  }

  Future<void> restoreSelected() async {
    final ids = _selectedNoteIds.toList();
    clearSelection();
    await _repository.restoreNotes(ids);
    _fetchTrashNotes();
    notifyListeners();
  }

  Future<void> permanentlyDeleteSelected() async {
    final ids = _selectedNoteIds.toList();
    clearSelection();
    await _repository.permanentlyDeleteNotes(ids);
    _fetchTrashNotes();
    notifyListeners();
  }

  Future<void> emptyTrash() async {
    clearSelection();
    await _repository.emptyTrash();
    _fetchTrashNotes();
    notifyListeners();
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
    _boxListenable?.removeListener(_boxListener);
    super.dispose();
  }
}
