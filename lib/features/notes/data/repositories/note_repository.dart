import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import '../models/note_model.dart';

// ─── Plain text extraction ────────────────────────────────────────────────────

/// Delta JSON'dan Türkçe küçük harfli düz metin çıkarır.
/// Not kaydedilirken bir kez çalışır; arama sırasında JSON parse gerekmez.
String _extractSearchableText(String deltaJson) {
  if (deltaJson.isEmpty || deltaJson == '[]') return '';
  try {
    final List<dynamic> ops = jsonDecode(deltaJson);
    final buffer = StringBuffer();
    for (final op in ops) {
      if (op is Map<String, dynamic> && op.containsKey('insert')) {
        final insert = op['insert'];
        if (insert is String) buffer.write(insert);
      }
    }
    // Controller._toTurkishLowerCase ile aynı sıra: önce replaceAll, sonra toLowerCase
    return buffer.toString().trim()
        .replaceAll('I', 'ı')
        .replaceAll('İ', 'i')
        .toLowerCase();
  } catch (_) {
    return '';
  }
}

/// Delta JSON'dan liste ekranında gösterilecek kısa özet (snippet) çıkarır.
String _extractSnippet(String deltaJson) {
  if (deltaJson.isEmpty || deltaJson == '[]') return '';
  try {
    final List<dynamic> ops = jsonDecode(deltaJson);
    final buffer = StringBuffer();
    for (final op in ops) {
      if (op is Map<String, dynamic> && op.containsKey('insert')) {
        final insert = op['insert'];
        if (insert is String) buffer.write(insert);
      }
    }
    final text = buffer.toString().trim();
    if (text.length > 200) return '${text.substring(0, 200)}...';
    return text;
  } catch (_) {
    return '';
  }
}


/// Hive tabanlı not deposu.
///
/// Box yapısı: `'notes_index'` adlı normal box, her kayıt `noteId` key'i ile tutulur.
/// Ağır deltaJson verisi ise `'notes_data'` adlı LazyBox içinde tutulur.
class NoteRepository {
  static const String _indexBoxName = 'notes_index';
  static const String _lazyDataBoxName = 'notes_data';

  static final NoteRepository _instance = NoteRepository._internal();
  factory NoteRepository() => _instance;
  NoteRepository._internal();

  Box? _indexBox;
  LazyBox? _lazyDataBox;

  Future<void>? _initFuture;

  Future<void> init() {
    if (_indexBox != null && _indexBox!.isOpen && _lazyDataBox != null && _lazyDataBox!.isOpen) return Future.value();
    return _initFuture ??= _openBox_().whenComplete(() => _initFuture = null);
  }

  Future<void> _openBox_() async {
    _indexBox = await Hive.openBox(_indexBoxName);
    _lazyDataBox = await Hive.openLazyBox(_lazyDataBoxName);
    
    if (await Hive.boxExists('notes')) {
      await _migrateOldBox();
    }
    
    // iOS Sandbox Path Değişikliği Taraması (Hot Migration)
    await _fixSandboxPaths();

    // Arka planda orphan resimleri temizle (EC-25)
    cleanOrphanImages();
  }
  
  /// Eski tek kutulu mimariden yeni Index/LazyBox mimarisine geçiş yapar.
  Future<void> _migrateOldBox() async {
    final oldBox = await Hive.openBox('notes');
    if (oldBox.isEmpty) {
        await oldBox.deleteFromDisk();
        return;
    }
    
    final updatesIndex = <String, dynamic>{};
    for (final key in oldBox.keys) {
      if (key == 'prefs_is_grid_view') {
        _indexBox!.put(key, oldBox.get(key));
        continue;
      }
      final raw = oldBox.get(key);
      if (raw is Map) {
        final noteMap = Map<String, dynamic>.from(raw);
        final deltaStr = (noteMap['deltaJson'] as String?) ?? '[]';
        
        // Asıl veriyi LazyBox'a yaz
        await _lazyDataBox!.put(key, deltaStr);
        
        // Index için veriyi kırp
        noteMap['deltaJson'] = ''; 
        noteMap['snippet'] = _extractSnippet(deltaStr); // Yeni snippet
        
        updatesIndex[key.toString()] = noteMap;
      }
    }
    await _indexBox!.putAll(updatesIndex);
    await oldBox.deleteFromDisk();
    debugPrint('Migration completed: moved old notes to index/lazyBox.');
  }

  Future<void> _fixSandboxPaths() async {
    try {
      final docsDir = await getApplicationDocumentsDirectory();
      final imgDir = Directory('${docsDir.path}/note_images');
      final vidDir = Directory('${docsDir.path}/note_videos');
      
      final updates = <String, String>{};

      for (final key in _lazyDataBox!.keys) {
        if (key == 'prefs_is_grid_view') continue;
        final deltaStr = await _lazyDataBox!.get(key) as String?;
        if (deltaStr == null) continue;

        bool changed = false;
        List<dynamic> ops;
        try {
          ops = jsonDecode(deltaStr) as List<dynamic>;
        } catch (_) {
          continue;
        }

        for (final op in ops) {
          if (op is! Map) continue;
          final insert = op['insert'];
          if (insert is! Map) continue;
          
          if (insert.containsKey('image')) {
            final mediaPath = insert['image'];
            if (mediaPath is String && !mediaPath.startsWith('http')) {
              final fileName = mediaPath.split('/').last.split('\\').last;
              final correctPath = '${imgDir.path}/$fileName';
              if (mediaPath != correctPath) {
                insert['image'] = correctPath;
                changed = true;
              }
            }
          }
          
          if (insert.containsKey('video')) {
            final mediaPath = insert['video'];
            if (mediaPath is String && !mediaPath.startsWith('http')) {
              final fileName = mediaPath.split('/').last.split('\\').last;
              final correctPath = '${vidDir.path}/$fileName';
              if (mediaPath != correctPath) {
                insert['video'] = correctPath;
                changed = true;
              }
            }
          }
        }

        if (changed) {
          await _lazyDataBox!.put(key, jsonEncode(ops));
          updates[key as String] = 'updated'; 
        }
      }

      if (updates.isNotEmpty) {
        debugPrint('EC-26: ${updates.length} notun kırık medya yolları onarıldı.');
      }
    } catch (e) {
      debugPrint('Path migration error: $e');
    }
  }

  ValueListenable<Box> listenable() => _requireIndexBox.listenable();

  Box get _requireIndexBox {
    assert(
      _indexBox != null && _indexBox!.isOpen,
      'NoteRepository.init() must be called first',
    );
    return _indexBox!;
  }

  // ─── Kullanıcı Tercihleri ────────────────────────────────────────────────

  bool get isGridView {
    if (_indexBox == null || !_indexBox!.isOpen) return false;
    return _indexBox!.get('prefs_is_grid_view', defaultValue: false) as bool;
  }

  Future<void> setGridView(bool value) async {
    await init();
    await _requireIndexBox.put('prefs_is_grid_view', value);
  }

  // ─── Okuma ───────────────────────────────────────────────────────────────

  List<NoteModel> getAllNotes() {
    if (_indexBox == null || !_indexBox!.isOpen) return [];

    final result = <NoteModel>[];
    for (final raw in _indexBox!.values) {
      try {
        if (raw is! Map) continue;
        final note = NoteModel.fromMap(Map<String, dynamic>.from(raw));
        if (note.id.isEmpty) continue; 
        if (note.id == 'prefs_is_grid_view') continue;

        result.add(note);
      } catch (_) {}
    }
    result.sort((a, b) {
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      return b.updatedAt.compareTo(a.updatedAt);
    });
    return result;
  }

  NoteModel? getNoteById(String id) {
    if (_indexBox == null || !_indexBox!.isOpen) return null;

    try {
      final raw = _indexBox!.get(id);
      if (raw == null || raw is! Map) return null;
      return NoteModel.fromMap(Map<String, dynamic>.from(raw));
    } catch (_) {
      return null;
    }
  }

  Future<String> getNoteDeltaJson(String id) async {
    await init();
    final data = await _lazyDataBox!.get(id);
    return data as String? ?? '[]';
  }

  // ─── Yazma ───────────────────────────────────────────────────────────────

  Future<void> saveNote(NoteModel note) async {
    await init();
    
    // Güvenlik: Eğer deltaJson boş gelirse (çok nadir de olsa), LazyBox içindeki 
    // eski veriyi silmek veya boş string atamak gerekir.
    await _lazyDataBox!.put(note.id, note.deltaJson.isNotEmpty ? note.deltaJson : '[]');
    
    final indexNote = note.copyWith(deltaJson: '');
    await _requireIndexBox.put(note.id, indexNote.toMap());
  }

  Future<void> togglePin(String id) async {
    final note = getNoteById(id);
    if (note != null) {
      final deltaStr = await getNoteDeltaJson(id);
      await saveNote(note.copyWith(isPinned: !note.isPinned, deltaJson: deltaStr));
    }
  }

  Future<void> setPinStateForNotes(List<String> ids, bool isPinned) async {
    await init();
    final updates = <String, Map<String, dynamic>>{};

    for (final id in ids) {
      final note = getNoteById(id);
      if (note != null) {
        updates[id] = note.copyWith(isPinned: isPinned).toMap(); // index update doesn't need delta
      }
    }

    if (updates.isNotEmpty) {
      await _requireIndexBox.putAll(updates);
    }
  }

  Future<void> setCategoryForNotes(List<String> ids, String? categoryId) async {
    await init();
    final updates = <String, Map<String, dynamic>>{};

    for (final id in ids) {
      final note = getNoteById(id);
      if (note != null && note.categoryId != categoryId) {
        updates[id] = note.copyWith(
          categoryId: categoryId,
          clearCategory: categoryId == null,
          updatedAt: DateTime.now(),
        ).toMap();
      }
    }

    if (updates.isNotEmpty) {
      await _requireIndexBox.putAll(updates);
    }
  }

  Future<void> removeCategoryFromNotes(String categoryId) async {
    await init();
    final updates = <String, Map<String, dynamic>>{};
    
    for (final key in _requireIndexBox.keys) {
      if (key == 'prefs_is_grid_view') continue;
      final raw = _requireIndexBox.get(key);
      if (raw is Map) {
        final noteMap = Map<String, dynamic>.from(raw);
        if (noteMap['categoryId'] == categoryId) {
          noteMap['categoryId'] = null;
          updates[key as String] = noteMap;
        }
      }
    }
    
    if (updates.isNotEmpty) {
      await _requireIndexBox.putAll(updates);
    }
  }

  Future<NoteModel> updateNote({
    required String id,
    required String deltaJson,
    String? title,
    int? color,
    bool clearColor = false,
    String? categoryId,
    bool clearCategory = false,
    DateTime? originalCreatedAt,
  }) async {
    await init();

    var note = getNoteById(id) ??
        NoteModel(
          id: id,
          title: '',
          deltaJson: '',
          createdAt: originalCreatedAt ?? DateTime.now(),
          updatedAt: DateTime.now(),
          categoryId: null,
        );

    final computed = _extractSearchableText(deltaJson);
    final snippet = _extractSnippet(deltaJson);

    note = note.copyWith(
      deltaJson: deltaJson,
      title: title,
      snippet: snippet,
      searchableText: computed,
      updatedAt: DateTime.now(),
      color: color,
      clearColor: clearColor,
      categoryId: categoryId,
      clearCategory: clearCategory,
    );

    await saveNote(note);
    return note;
  }

  // ─── Silme ───────────────────────────────────────────────────────────────

  Future<void> deleteNote(String id) async {
    await init();
    final deltaStr = await getNoteDeltaJson(id);
    await _requireIndexBox.delete(id);
    await _lazyDataBox!.delete(id);
    if (deltaStr.isNotEmpty && deltaStr != '[]') {
      _deleteLocalImages(deltaStr);
    }
  }

  Future<void> deleteNotes(List<String> ids) async {
    await init();
    final keysToDelete = <String>[];

    for (final id in ids) {
      final deltaStr = await getNoteDeltaJson(id);
      if (deltaStr.isNotEmpty && deltaStr != '[]') {
        await _deleteLocalImages(deltaStr);
      }
      keysToDelete.add(id);
    }

    if (keysToDelete.isNotEmpty) {
      await _requireIndexBox.deleteAll(keysToDelete);
      await _lazyDataBox!.deleteAll(keysToDelete);
    }
  }

  static Future<void> _deleteLocalImages(String deltaJson) async {
    try {
      final ops = jsonDecode(deltaJson) as List<dynamic>;
      for (final op in ops) {
        if (op is! Map) continue;
        final insert = op['insert'];
        if (insert is! Map) continue;
        final mediaPath = insert['image'] ?? insert['video'];
        if (mediaPath is! String) continue;
        if (mediaPath.startsWith('http')) continue;
        final file = File(mediaPath);
        if (await file.exists()) {
          await file.delete();
          debugPrint('EC-18: Orphan medya silindi → $mediaPath');
        }
      }
    } catch (e) {
      debugPrint('EC-18: Medya temizleme hatası: $e');
    }
  }

  Future<void> clearAll() async {
    await init();
    await _requireIndexBox.clear();
    await _lazyDataBox!.clear();

    try {
      final docsDir = await getApplicationDocumentsDirectory();
      final noteImgDir = Directory('${docsDir.path}/note_images');
      if (await noteImgDir.exists()) {
        await noteImgDir.delete(recursive: true);
        debugPrint('EC-24: Tüm not resimleri silindi.');
      }
      
      final noteVidDir = Directory('${docsDir.path}/note_videos');
      if (await noteVidDir.exists()) {
        await noteVidDir.delete(recursive: true);
        debugPrint('EC-24: Tüm not videoları silindi.');
      }
    } catch (e) {
      debugPrint('EC-24: Medya klasörü silinemedi: $e');
    }
  }

  Future<void> cleanOrphanImages() async {
    try {
      final docsDir = await getApplicationDocumentsDirectory();
      final imgDir = Directory('${docsDir.path}/note_images');
      final vidDir = Directory('${docsDir.path}/note_videos');

      final activeFileNames = <String>{};
      for (final key in _lazyDataBox!.keys) {
        try {
          final deltaStr = await _lazyDataBox!.get(key) as String?;
          if (deltaStr == null) continue;
          final ops = jsonDecode(deltaStr) as List<dynamic>;
          for (final op in ops) {
            if (op is! Map) continue;
            final insert = op['insert'];
            if (insert is! Map) continue;
            final mediaPath = insert['image'] ?? insert['video'];
            if (mediaPath is String && !mediaPath.startsWith('http')) {
              final fileName = mediaPath.split('/').last.split('\\').last;
              activeFileNames.add(fileName);
            }
          }
        } catch (_) {}
      }

      if (await imgDir.exists()) {
        final files = imgDir.listSync();
        for (final entity in files) {
          if (entity is File) {
            final fileName = entity.path.split('/').last.split('\\').last;
            if (!activeFileNames.contains(fileName)) {
              await entity.delete();
              debugPrint('EC-25: Orphan resim silindi → ${entity.path}');
            }
          }
        }
      }
      
      if (await vidDir.exists()) {
        final files = vidDir.listSync();
        for (final entity in files) {
          if (entity is File) {
            final fileName = entity.path.split('/').last.split('\\').last;
            if (!activeFileNames.contains(fileName)) {
              await entity.delete();
              debugPrint('EC-25: Orphan video silindi → ${entity.path}');
            }
          }
        }
      }
    } catch (e) {
      debugPrint('EC-25: Orphan temizleme hatası: $e');
    }
  }

  // ─── İstatistik ──────────────────────────────────────────────────────────

  int get noteCount {
    if (_indexBox == null || !_indexBox!.isOpen) return 0;
    int count = _requireIndexBox.length;
    if (_requireIndexBox.containsKey('prefs_is_grid_view')) {
      count -= 1;
    }
    return count;
  }
}
