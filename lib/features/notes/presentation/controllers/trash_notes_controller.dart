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

  void init() {
    if (_isInitialized) return; // Çift init koruması
    _isInitialized = true;

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
  }

  Future<void> permanentlyDeleteSelected() async {
    final ids = _selectedNoteIds.toList();
    clearSelection();
    await _repository.permanentlyDeleteNotes(ids);
  }

  Future<void> emptyTrash() async {
    clearSelection();
    await _repository.emptyTrash();
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
