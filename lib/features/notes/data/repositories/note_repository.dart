import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/services.dart';
import 'package:flutter/painting.dart';
import '../models/note_model.dart';
import '../../../../core/di/injection_container.dart';
import '../../../auth/domain/repositories/auth_repository.dart';

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
    return buffer
        .toString()
        .trim()
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
  String get _indexBoxName => 'notes_index_$_currentUserId';
  String get _lazyDataBoxName => 'notes_data_$_currentUserId';

  static final NoteRepository _instance = NoteRepository._internal();
  factory NoteRepository() => _instance;
  NoteRepository._internal();

  Box? _indexBox;
  LazyBox? _lazyDataBox;

  Box? _secureIndexBox;
  LazyBox? _secureLazyDataBox;
  LazyBox? _secureMediaBox;

  // 🎭 SAHTE KASA (DECOY VAULT) FLAG
  bool _isDecoyVaultActive = false;
  bool get isDecoyVaultActive => _isDecoyVaultActive;

  final LocalAuthentication _auth = LocalAuthentication();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  String _currentUserId = 'default';

  String get _secureIndexBoxName => 'secure_notes_index_$_currentUserId';
  String get _secureDataBoxName => 'secure_notes_data_$_currentUserId';
  String get _secureMediaBoxName => 'secure_media_box_$_currentUserId';

  Future<void>? _initFuture;

  /// GÜVENLİK (EDGE CASE): Kamera veya Galeri açıldığında işletim sistemi
  /// uygulamayı arka plana (paused) atar. Bu durumda uygulamanın kendini
  /// otomatik kilitlemesini engellemek için bu flag kullanılır.
  bool isMediaPicking = false;

  Future<void> init() async {
    try {
      final authRepo = getIt<AuthRepository>();
      final user = await authRepo.getCurrentUser();
      _currentUserId = user?.id ?? 'default';
    } catch (_) {
      // getIt not initialized yet or AuthRepository not registered yet (e.g. tests)
    }

    if (_indexBox != null &&
        _indexBox!.isOpen &&
        _indexBox!.name == _indexBoxName &&
        _lazyDataBox != null &&
        _lazyDataBox!.isOpen &&
        _lazyDataBox!.name == _lazyDataBoxName) {
      return;
    }

    // Eğer farklı bir kullanıcının kutusu açıksa kapat
    await closeAll();

    if (_initFuture == null) {
      _initFuture = _openBox_();
      await _initFuture;
      _initFuture = null;
    } else {
      await _initFuture;
    }
  }

  Future<void> _openBox_() async {
    // Migration: Migrate common 'notes_index' to scoped 'notes_index_$_currentUserId'
    if (_currentUserId != 'default') {
      if (await Hive.boxExists('notes_index') &&
          !(await Hive.boxExists(_indexBoxName))) {
        debugPrint('Migration: Taşıma başlıyor. notes_index -> $_indexBoxName');
        final oldIndex = await Hive.openBox('notes_index');
        final newIndex = await Hive.openBox(_indexBoxName);
        await newIndex.putAll(Map.from(oldIndex.toMap()));
        await oldIndex.close();
        await Hive.deleteBoxFromDisk('notes_index');

        if (await Hive.boxExists('notes_data')) {
          final oldData = await Hive.openLazyBox('notes_data');
          final newData = await Hive.openLazyBox(_lazyDataBoxName);
          for (final key in oldData.keys) {
            final val = await oldData.get(key);
            await newData.put(key, val);
          }
          await oldData.close();
          await Hive.deleteBoxFromDisk('notes_data');
        }
      }
    }

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
        debugPrint(
          'EC-26: ${updates.length} notun kırık medya yolları onarıldı.',
        );
      }
    } catch (e) {
      debugPrint('Path migration error: $e');
    }
  }

  ValueListenable<Box> listenable() => _requireIndexBox.listenable();
  Stream<BoxEvent> watch() => _requireIndexBox.watch();

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
        if (note.deletedAt != null) continue; // Çöp kutusundakileri atla

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

  List<NoteModel> getTrashNotes() {
    if (_indexBox == null || !_indexBox!.isOpen) return [];

    final result = <NoteModel>[];
    for (final raw in _indexBox!.values) {
      try {
        if (raw is! Map) continue;
        final note = NoteModel.fromMap(Map<String, dynamic>.from(raw));
        if (note.id.isEmpty) continue;
        if (note.id == 'prefs_is_grid_view') continue;
        if (note.deletedAt == null) continue; // Sadece çöp kutusundakiler

        result.add(note);
      } catch (_) {}
    }
    // En son silinenler en üstte görünsün
    result.sort((a, b) => b.deletedAt!.compareTo(a.deletedAt!));
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
    await _lazyDataBox!.put(
      note.id,
      note.deltaJson.isNotEmpty ? note.deltaJson : '[]',
    );

    // Her ihtimale karşı snippet ve searchableText'i doğrula (Özellikle mock data için)
    final snippet = note.snippet.isEmpty && note.deltaJson.isNotEmpty
        ? _extractSnippet(note.deltaJson)
        : note.snippet;
    final searchableText =
        note.searchableText.isEmpty && note.deltaJson.isNotEmpty
        ? _extractSearchableText(note.deltaJson)
        : note.searchableText;

    final indexNote = note.copyWith(
      deltaJson: '',
      snippet: snippet,
      searchableText: searchableText,
    );
    await _requireIndexBox.put(note.id, indexNote.toMap());
  }

  Future<void> togglePin(String id) async {
    await init();
    // Sadece index güncellenir — setPinStateForNotes batch ile tutarlı
    final note = getNoteById(id);
    if (note != null) {
      await _requireIndexBox.put(
        id,
        note.copyWith(isPinned: !note.isPinned).toMap(),
      );
    }
  }

  Future<void> setPinStateForNotes(List<String> ids, bool isPinned) async {
    await init();
    final updates = <String, Map<String, dynamic>>{};

    for (final id in ids) {
      final note = getNoteById(id);
      if (note != null) {
        updates[id] = note
            .copyWith(isPinned: isPinned)
            .toMap(); // index update doesn't need delta
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
        updates[id] = note
            .copyWith(
              categoryId: categoryId,
              clearCategory: categoryId == null,
              updatedAt: DateTime.now(),
            )
            .toMap();
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
    bool isSecure = false,
  }) async {
    await init();

    if (isSecure || (isSecureNotesUnlocked && getSecureNoteById(id) != null)) {
      var note =
          getSecureNoteById(id) ??
          NoteModel(
            id: id,
            title: '',
            deltaJson: '',
            isSecure: true,
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

      await saveSecureNote(note);
      return note;
    }

    var note =
        getNoteById(id) ??
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
      // deletedAt korunur — çöp kutusundaki not editörden kaydedilse bile aktif listeye çıkmaz
    );

    await saveNote(note);
    return note;
  }

  // ─── Silme ───────────────────────────────────────────────────────────────

  Future<void> deleteNote(String id) async {
    await init();

    // Güvenli kasadaysa doğrudan kalıcı olarak sil (Çöp kutusuna sızmasını engelle)
    if (isSecureNotesUnlocked && (_secureIndexBox?.containsKey(id) ?? false)) {
      await permanentlyDeleteNote(id, isSecure: true);
      return;
    }

    // Aksi halde (Genel not ise) çöpe at (Soft delete)
    if (_requireIndexBox.containsKey(id)) {
      final raw = _requireIndexBox.get(id);
      if (raw != null) {
        final note = NoteModel.fromMap(Map<String, dynamic>.from(raw));
        await _requireIndexBox.put(
          id,
          note.copyWith(deletedAt: DateTime.now()).toMap(),
        );
      }
    }
  }

  Future<void> deleteNotes(List<String> ids) async {
    await init();
    final publicUpdates = <String, Map<String, dynamic>>{};
    final secureIdsToDelete = <String>[];
    final now = DateTime.now();

    for (final id in ids) {
      if (isSecureNotesUnlocked &&
          (_secureIndexBox?.containsKey(id) ?? false)) {
        secureIdsToDelete.add(id);
      } else if (_requireIndexBox.containsKey(id)) {
        final raw = _requireIndexBox.get(id);
        if (raw != null) {
          final note = NoteModel.fromMap(Map<String, dynamic>.from(raw));
          publicUpdates[id] = note.copyWith(deletedAt: now).toMap();
        }
      }
    }

    if (publicUpdates.isNotEmpty) {
      await _requireIndexBox.putAll(publicUpdates);
    }
    if (secureIdsToDelete.isNotEmpty) {
      await permanentlyDeleteNotes(secureIdsToDelete, isSecure: true);
    }
  }

  Future<void> restoreNote(String id) async {
    await init();
    if (_requireIndexBox.containsKey(id)) {
      final raw = _requireIndexBox.get(id);
      if (raw != null) {
        final note = NoteModel.fromMap(Map<String, dynamic>.from(raw));
        await _requireIndexBox.put(
          id,
          note.copyWith(clearDeletedAt: true).toMap(),
        );
      }
    }
  }

  Future<void> restoreNotes(List<String> ids) async {
    await init();
    final publicUpdates = <String, Map<String, dynamic>>{};

    for (final id in ids) {
      if (_requireIndexBox.containsKey(id)) {
        final raw = _requireIndexBox.get(id);
        if (raw != null) {
          final note = NoteModel.fromMap(Map<String, dynamic>.from(raw));
          publicUpdates[id] = note.copyWith(clearDeletedAt: true).toMap();
        }
      }
    }

    if (publicUpdates.isNotEmpty) {
      await _requireIndexBox.putAll(publicUpdates);
    }
  }

  Future<void> permanentlyDeleteNote(String id, {bool isSecure = false}) async {
    await init();

    if (isSecure) {
      if (!isSecureNotesUnlocked) return;
      await _secureIndexBox?.delete(id);
      await _secureLazyDataBox?.delete(id);
      await cleanOrphanSecureMedia();
    } else {
      await _requireIndexBox.delete(id);
      await _lazyDataBox!.delete(id);
      await cleanOrphanImages();
    }
  }

  Future<void> permanentlyDeleteNotes(
    List<String> ids, {
    bool isSecure = false,
  }) async {
    await init();
    if (ids.isEmpty) return;

    if (isSecure) {
      if (!isSecureNotesUnlocked) return;
      await _secureIndexBox?.deleteAll(ids);
      await _secureLazyDataBox?.deleteAll(ids);
      await cleanOrphanSecureMedia();
    } else {
      await _requireIndexBox.deleteAll(ids);
      await _lazyDataBox!.deleteAll(ids);
      await cleanOrphanImages();
    }
  }

  Future<void> emptyTrash() async {
    await init(); // Box'un açık olduğundan emin ol
    final trashNotes = getTrashNotes();
    if (trashNotes.isEmpty) return;

    final ids = trashNotes.map((n) => n.id).toList();
    await permanentlyDeleteNotes(ids);
  }

  Future<void> cleanOldTrashNotes([int days = 30]) async {
    await init();
    final trashNotes = getTrashNotes();
    if (trashNotes.isEmpty) return;

    final now = DateTime.now();
    final limitDate = now.subtract(Duration(days: days));
    final idsToDelete = <String>[];

    for (final note in trashNotes) {
      if (note.deletedAt != null && note.deletedAt!.isBefore(limitDate)) {
        idsToDelete.add(note.id);
      }
    }

    if (idsToDelete.isNotEmpty) {
      await permanentlyDeleteNotes(idsToDelete);
      debugPrint(
        'EC-TRASH: $days günden eski ${idsToDelete.length} not kalıcı olarak silindi.',
      );
    }
  }

  Future<void> clearAll() async {
    await init();
    await _requireIndexBox.clear();
    await _lazyDataBox!.clear();

    // Close and securely delete encrypted secure boxes from disk
    await closeSecureNotes();
    await Hive.deleteBoxFromDisk(_secureIndexBoxName);
    await Hive.deleteBoxFromDisk(_secureDataBoxName);
    await Hive.deleteBoxFromDisk(_secureMediaBoxName);

    // EC-27: Decoy (Sahte Kasa) orphan veri sızıntısını engelle
    await Hive.deleteBoxFromDisk('sys_cache_index_$_currentUserId');
    await Hive.deleteBoxFromDisk('sys_cache_data_$_currentUserId');
    await Hive.deleteBoxFromDisk('sys_cache_media_$_currentUserId');

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
      // Aktif notlar VE çöp kutusundaki notlar — her ikisinin medyaları da korunmalı.
      // Çöp kutusundaki notlar henüz kalıcı silinmediği için medyaları geçerlidir.
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

  /// GÜVENLİK (EDGE CASE): Gizli bir not düzenlenirken içindeki resim silinirse
  /// resim veritabanından silinmiyordu. Bu metot kasa her açıldığında
  /// kullanılmayan şifreli resimleri temizleyerek veritabanının şişmesini önler.
  Future<void> cleanOrphanSecureMedia() async {
    if (!isSecureNotesUnlocked) return;
    try {
      final activeMediaIds = <String>{};
      for (final key in _secureLazyDataBox!.keys) {
        final deltaStr = await _secureLazyDataBox!.get(key) as String?;
        if (deltaStr == null) continue;
        final ops = jsonDecode(deltaStr) as List<dynamic>;
        for (final op in ops) {
          if (op is! Map) continue;
          final insert = op['insert'];
          if (insert is! Map) continue;
          final mediaPath = insert['image'] ?? insert['video'];
          if (mediaPath is String && mediaPath.startsWith('secure-media://')) {
            final mediaId = mediaPath.replaceFirst('secure-media://', '');
            activeMediaIds.add(mediaId);
          }
        }
      }

      final allKeys = _secureMediaBox!.keys.toList();
      for (final key in allKeys) {
        if (!activeMediaIds.contains(key)) {
          // GÜVENLİK (EDGE CASE): Yeni oluşturulan şifreli medyaların not kaydedilmeden
          // silinmesini önlemek için 5 dakikalık (Grace Period) tolerans süresi tanınır.
          final timestampStr = key
              .toString()
              .replaceFirst('secure_media_', '')
              .split('.')
              .first;
          final timestamp = int.tryParse(timestampStr);
          if (timestamp != null) {
            final now = DateTime.now().microsecondsSinceEpoch;
            if (now - timestamp < 5 * 60 * 1000000) {
              continue; // 5 dakikadan yeniyse SİLME, atla.
            }
          }

          await _secureMediaBox!.delete(key);
          debugPrint('EC-26: Orphan şifreli medya temizlendi → $key');
        }
      }
    } catch (_) {}
  }

  // ─── İstatistik ──────────────────────────────────────────────────────────

  int get noteCount {
    return getAllNotes().length;
  }

  // ─── Güvenli Notlar (Secure Notes) ──────────────────────────────────────────

  bool get hasSecurePin =>
      _requireIndexBox.get('has_secure_pin', defaultValue: false) as bool;

  // 🎭 Sahte Kasa PIN var mı?
  bool get hasDecoyPin =>
      _requireIndexBox.get('has_decoy_pin', defaultValue: false) as bool;

  // Ana PIN'i test etme (UI katmanı için)
  Future<bool> verifyMainPin(String pin) async {
    final salt = _requireIndexBox.get('secure_pin_salt') as String?;
    if (salt == null) return false;
    final key = await compute(_deriveKeySync, {'pin': pin, 'salt': salt});
    final computedHash = sha256.convert(key).toString();
    final storedHash = _requireIndexBox.get('secure_pin_hash') as String?;
    return computedHash == storedHash;
  }

  // Sahte PIN'i test etme (UI katmanı için)
  Future<bool> verifyDecoyPin(String pin) async {
    final salt = _requireIndexBox.get('decoy_pin_salt') as String?;
    if (salt == null) return false;
    final key = await compute(_deriveKeySync, {'pin': pin, 'salt': salt});
    final computedHash = sha256.convert(key).toString();
    final storedHash = _requireIndexBox.get('decoy_pin_hash') as String?;
    return computedHash == storedHash;
  }

  Future<void> setSecurePin(String pin) async {
    // Generate salt asynchronously on a background isolate
    final salt = await compute(_generateSaltSync, null);
    await _requireIndexBox.put('secure_pin_salt', salt);

    final key = await compute(_deriveKeySync, {'pin': pin, 'salt': salt});
    final verifyHash = sha256.convert(key).toString();
    await _requireIndexBox.put('secure_pin_hash', verifyHash);

    final success = await unlockSecureNotes(pin);
    if (success) {
      await _requireIndexBox.put('has_secure_pin', true);
    }
  }

  // 🎭 Sahte Kasa PIN Ayarlama
  Future<void> setDecoyPin(String pin) async {
    // EC: Eski veya bozuk verileri temizle
    await Hive.deleteBoxFromDisk('sys_cache_index_$_currentUserId');
    await Hive.deleteBoxFromDisk('sys_cache_data_$_currentUserId');
    await Hive.deleteBoxFromDisk('sys_cache_media_$_currentUserId');

    final salt = await compute(_generateSaltSync, null);
    await _requireIndexBox.put('decoy_pin_salt', salt);

    final key = await compute(_deriveKeySync, {'pin': pin, 'salt': salt});
    final verifyHash = sha256.convert(key).toString();
    await _requireIndexBox.put('decoy_pin_hash', verifyHash);

    await _requireIndexBox.put('has_decoy_pin', true);
  }

  // 🎭 Sahte Kasa İptali
  Future<void> removeDecoyPin() async {
    await _requireIndexBox.delete('has_decoy_pin');
    await _requireIndexBox.delete('decoy_pin_salt');
    await _requireIndexBox.delete('decoy_pin_hash');
    // EC-27: Sahte kasa dosyalarının adında 'decoy' geçmemesi için sys_cache kullanıldı
    await Hive.deleteBoxFromDisk('sys_cache_index_$_currentUserId');
    await Hive.deleteBoxFromDisk('sys_cache_data_$_currentUserId');
    await Hive.deleteBoxFromDisk('sys_cache_media_$_currentUserId');
  }

  Future<bool> unlockSecureNotes(String pin) async {
    try {
      final salt = _requireIndexBox.get('secure_pin_salt') as String?;
      List<int>? key;

      bool isDecoyMatched = false;

      // 1. Önce Ana Kasa PIN'ini kontrol et
      if (salt != null) {
        key = await compute(_deriveKeySync, {'pin': pin, 'salt': salt});
      } else {
        key = sha256.convert(utf8.encode(pin)).bytes;
      }

      final storedHash = _requireIndexBox.get('secure_pin_hash') as String?;
      bool isMainMatched = false;
      if (storedHash != null && key != null) {
        final computedHash = sha256.convert(key).toString();
        if (computedHash == storedHash) {
          isMainMatched = true;
        }
      }

      // 2. Eğer Ana Kasa EŞLEŞMEDİYSE ve Sahte Kasa varsa, Sahte Kasa PIN'ini kontrol et
      if (!isMainMatched && hasDecoyPin) {
        final decoySalt = _requireIndexBox.get('decoy_pin_salt') as String?;
        if (decoySalt != null) {
          final decoyKey = await compute(_deriveKeySync, {
            'pin': pin,
            'salt': decoySalt,
          });
          final storedDecoyHash =
              _requireIndexBox.get('decoy_pin_hash') as String?;
          if (storedDecoyHash != null) {
            final computedDecoyHash = sha256.convert(decoyKey).toString();
            if (computedDecoyHash == storedDecoyHash) {
              isDecoyMatched = true;
              key =
                  decoyKey; // Şifreleme anahtarı olarak decoy anahtarını kullan!
            }
          }
        }
      }

      // 3. İkisi de eşleşmediyse reddet
      if (!isMainMatched && !isDecoyMatched) return false;

      // 4. Eşleşme durumuna göre Flag'i ayarla
      _isDecoyVaultActive = isDecoyMatched;

      // 5. Kutu isimlerini Flag'e göre belirle (EC-27: Kamufle edilmiş dosya isimleri)
      final indexName = isDecoyMatched
          ? 'sys_cache_index_$_currentUserId'
          : _secureIndexBoxName;
      final dataName = isDecoyMatched
          ? 'sys_cache_data_$_currentUserId'
          : _secureDataBoxName;
      final mediaName = isDecoyMatched
          ? 'sys_cache_media_$_currentUserId'
          : _secureMediaBoxName;

      if (_secureIndexBox?.isOpen == true) await _secureIndexBox!.close();
      if (_secureLazyDataBox?.isOpen == true) await _secureLazyDataBox!.close();
      if (_secureMediaBox?.isOpen == true) await _secureMediaBox!.close();

      _secureIndexBox = await Hive.openBox(
        indexName,
        encryptionCipher: HiveAesCipher(key!),
        crashRecovery: false,
      );
      _secureLazyDataBox = await Hive.openLazyBox(
        dataName,
        encryptionCipher: HiveAesCipher(key),
        crashRecovery: false,
      );
      _secureMediaBox = await Hive.openLazyBox(
        mediaName,
        encryptionCipher: HiveAesCipher(key),
        crashRecovery: false,
      );

      // --- ATOMIC MIGRATION RECOVERY --- (Sadece ana kasa için geçerli)
      if (!isDecoyMatched) {
        final isPendingMigration =
            _requireIndexBox.get('pending_migration', defaultValue: false)
                as bool;
        if (isPendingMigration) {
          final tempIndexBox = await Hive.openBox(
            'temp_new_index_$_currentUserId',
            encryptionCipher: HiveAesCipher(key),
          );
          final tempLazyBox = await Hive.openLazyBox(
            'temp_new_data_$_currentUserId',
            encryptionCipher: HiveAesCipher(key),
          );
          final tempMediaBox = await Hive.openLazyBox(
            'temp_new_media_$_currentUserId',
            encryptionCipher: HiveAesCipher(key),
          );

          await _secureIndexBox!.putAll(tempIndexBox.toMap());
          for (var k in tempLazyBox.keys) {
            final val = await tempLazyBox.get(k);
            if (val != null) await _secureLazyDataBox!.put(k, val);
          }
          for (var k in tempMediaBox.keys) {
            final val = await tempMediaBox.get(k);
            if (val != null) await _secureMediaBox!.put(k, val);
          }

          await tempIndexBox.close();
          await tempLazyBox.close();
          await tempMediaBox.close();

          await Hive.deleteBoxFromDisk('temp_new_index_$_currentUserId');
          await Hive.deleteBoxFromDisk('temp_new_data_$_currentUserId');
          await Hive.deleteBoxFromDisk('temp_new_media_$_currentUserId');

          await _requireIndexBox.put('pending_migration', false);
        }
      }
      // ----------------------------------

      if (!isDecoyMatched && storedHash == null) {
        await _requireIndexBox.put(
          'secure_pin_hash',
          sha256.convert(key).toString(),
        );
      }

      if (_secureIndexBox!.isEmpty) {
        await _secureIndexBox!.put('pin_verify', 'verified');
      } else {
        final verifyValue = _secureIndexBox!.get('pin_verify');
        if (verifyValue != 'verified') {
          await closeSecureNotes();
          return false;
        }
      }

      // EC-26: Kasa başarıyla açıldığında, arka planda (kullanıcıyı bekletmeden)
      // yetim/çöp şifreli medyaları temizle.
      cleanOrphanSecureMedia();

      return true;
    } catch (e) {
      debugPrint('Unlock secure notes error: $e');
      await closeSecureNotes();
      return false;
    }
  }

  bool hasUnsavedSecureNote = false;

  /// GÜVENLİK YAMASI: Çoklu kullanıcı durumunda tüm kutuları kapatır.
  Future<void> closeAll() async {
    await closeSecureNotes(force: true);
    if (_indexBox != null && _indexBox!.isOpen) await _indexBox!.close();
    if (_lazyDataBox != null && _lazyDataBox!.isOpen)
      await _lazyDataBox!.close();
    _indexBox = null;
    _lazyDataBox = null;
    _initFuture = null;
  }

  Future<void> closeSecureNotes({bool force = false}) async {
    if (_isMigratingPin && !force) return;

    // EC-RACE: Arka plana atıldığında eğer NoteEditorPage henüz kaydedemeden
    // SecureNotesPage kilitlerse veri kaybı olur. Bunu önlemek için kaydı bekle.
    int waitCount = 0;
    while (hasUnsavedSecureNote && waitCount < 40) {
      await Future.delayed(const Duration(milliseconds: 50));
      waitCount++;
    }

    if (_secureIndexBox?.isOpen == true) await _secureIndexBox!.close();
    _secureIndexBox = null;
    if (_secureLazyDataBox?.isOpen == true) await _secureLazyDataBox!.close();
    _secureLazyDataBox = null;
    if (_secureMediaBox?.isOpen == true) await _secureMediaBox!.close();
    _secureMediaBox = null;

    _isDecoyVaultActive = false; // Flag'i resetle

    // Pano Sızıntısını Önle: Gizli Kasa kapandığında telefonun panosunu tamamen imha et (Native Android Wipe)
    try {
      const platform = MethodChannel('com.seyitaltintas.cashly/security');
      await platform.invokeMethod('clearClipboard');
    } catch (_) {}

    // RAM Sızıntısını Önle: Flutter ImageCache içindeki önbelleğe alınmış şifresi çözülmüş resimleri sil
    try {
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();
    } catch (_) {}
  }

  /// GÜVENLİK (EDGE CASE): Kullanıcı PIN'ini unutursa, şifreli veriler
  /// asla geri getirilemez. Bu durumda sistemi tekrar kullanabilmesi için
  /// kilitli kutuların diskten fiziksel olarak silinmesi gerekir (Hard Wipe).
  Future<void> resetSecureKasa() async {
    await closeSecureNotes(force: true);

    await Hive.deleteBoxFromDisk(_secureIndexBoxName);
    await Hive.deleteBoxFromDisk(_secureDataBoxName);
    await Hive.deleteBoxFromDisk(_secureMediaBoxName);

    // Sahte kasa dosyalarını da sil
    await removeDecoyPin();

    await _requireIndexBox.delete('has_secure_pin');
    await _requireIndexBox.delete('secure_pin_salt');
    await _requireIndexBox.delete('secure_pin_hash');
    await disableBiometric(); // Biyometrik çipi temizle
    await disableAutoUnlock(); // Otomatik giriş çipini temizle
  }

  // ─── PIN Migration (Şifre Değiştirme) ─────────────────────────────────────

  bool _isMigratingPin = false;
  bool get isMigratingPin => _isMigratingPin;

  Future<bool> changeSecurePin(String currentPin, String newPin) async {
    if (!isSecureNotesUnlocked) return false;

    // GÜVENLİK (EDGE CASE): Sahte kasa içindeyken şifre değiştirilemez.
    // Aksi halde ana kasa verileri ezilir/silinir.
    if (_isDecoyVaultActive) {
      throw Exception('Sahte kasa modundayken şifre değiştirilemez.');
    }

    _isMigratingPin = true;
    try {
      // 1. Yeni şifrenin AES Key'ini manuel olarak oluştur
      final newSalt = await compute(_generateSaltSync, null);
      final newKey = await compute(_deriveKeySync, {
        'pin': newPin,
        'salt': newSalt,
      });

      // 2. Yeni şifreli geçici kutuları (Backup) aç
      final tempIndexBox = await Hive.openBox(
        'temp_new_index_$_currentUserId',
        encryptionCipher: HiveAesCipher(newKey),
      );
      final tempLazyBox = await Hive.openLazyBox(
        'temp_new_data_$_currentUserId',
        encryptionCipher: HiveAesCipher(newKey),
      );
      final tempMediaBox = await Hive.openLazyBox(
        'temp_new_media_$_currentUserId',
        encryptionCipher: HiveAesCipher(newKey),
      );

      // 3. Mevcut kasadaki tüm verileri bu geçici kutulara kopyala
      await tempIndexBox.putAll(_secureIndexBox!.toMap());

      for (var k in _secureLazyDataBox!.keys) {
        final val = await _secureLazyDataBox!.get(k);
        if (val != null) await tempLazyBox.put(k, val);
      }

      for (var k in _secureMediaBox!.keys) {
        final val = await _secureMediaBox!.get(k);
        if (val != null) await tempMediaBox.put(k, val);
      }

      // 4. Geçici kutuları güvenle kapat (Diske mühürlendi)
      await tempIndexBox.close();
      await tempLazyBox.close();
      await tempMediaBox.close();

      // --- BURAYA KADAR HİÇBİR VERİ SİLİNMEDİ, ÇÖKSE BİLE GÜVENDE ---

      // 5. MIGRATION STATE'İ KAYDET (Atomic Checkpoint)
      await _requireIndexBox.put('secure_pin_salt', newSalt);
      final newHash = sha256.convert(newKey).toString();
      await _requireIndexBox.put('secure_pin_hash', newHash);
      await _requireIndexBox.put('pending_migration', true);

      // 6. Eski ana kasayı Yok Et (Ancak sahte kasayı silme!)
      await closeSecureNotes(force: true);
      await Hive.deleteBoxFromDisk(_secureIndexBoxName);
      await Hive.deleteBoxFromDisk(_secureDataBoxName);
      await Hive.deleteBoxFromDisk(_secureMediaBoxName);
      await disableBiometric(); // Biyometrik eski PIN'i tuttuğu için sıfırlanmalı
      await disableAutoUnlock();

      // 7. Yeni PIN'i sisteme kaydet (Bu, yeni kutuları açar ve pending_migration'ı görüp verileri aktarır)
      final success = await unlockSecureNotes(newPin);
      if (!success) throw Exception('Yeni kasa açılamadı.');
      await _requireIndexBox.put('has_secure_pin', true);

      return true;
    } catch (e) {
      debugPrint('PIN Migration failed: $e');
      final isPending =
          _requireIndexBox.get('pending_migration', defaultValue: false)
              as bool;
      if (!isPending) {
        // Eski kasa hala duruyor, geçici çöpleri güvenle silebiliriz
        try {
          await Hive.deleteBoxFromDisk('temp_new_index_$_currentUserId');
          await Hive.deleteBoxFromDisk('temp_new_data_$_currentUserId');
          await Hive.deleteBoxFromDisk('temp_new_media_$_currentUserId');
        } catch (_) {}
      }
      return false;
    } finally {
      _isMigratingPin = false;
    }
  }

  // ─── Auto-Unlock (Şifre Sorma) ────────────────────────────────────────────

  Future<bool> get isAutoUnlockEnabled async {
    final pin = await _secureStorage.read(key: 'auto_unlock_pin');
    return pin != null && pin.isNotEmpty;
  }

  Future<void> enableAutoUnlock(String currentPin) async {
    if (!hasSecurePin) throw StateError('Secure PIN is not set.');
    await _secureStorage.write(key: 'auto_unlock_pin', value: currentPin);
  }

  Future<void> disableAutoUnlock() async {
    await _secureStorage.delete(key: 'auto_unlock_pin');
  }

  Future<bool> unlockWithAuto() async {
    final pin = await _secureStorage.read(key: 'auto_unlock_pin');
    if (pin != null) {
      return await unlockSecureNotes(pin);
    }
    return false;
  }

  // ─── Biometrics ───────────────────────────────────────────────────────────

  Future<bool> canUseBiometrics() async {
    final canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
    final canAuthenticate =
        canAuthenticateWithBiometrics || await _auth.isDeviceSupported();
    return canAuthenticate;
  }

  Future<bool> get isBiometricEnabled async {
    final pin = await _secureStorage.read(key: 'secure_vault_pin');
    return pin != null && pin.isNotEmpty;
  }

  Future<void> enableBiometric(String currentPin) async {
    if (!hasSecurePin) throw StateError('Secure PIN is not set.');
    await _secureStorage.write(key: 'secure_vault_pin', value: currentPin);
  }

  Future<void> disableBiometric() async {
    await _secureStorage.delete(key: 'secure_vault_pin');
  }

  Future<bool> unlockWithBiometric(String localizedReason) async {
    final canAuthenticate = await canUseBiometrics();
    if (!canAuthenticate) return false;

    try {
      final authenticated = await _auth.authenticate(
        localizedReason: localizedReason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly:
              true, // Sadece parmak izi/yüz tanıma (cihaz PIN'i değil)
        ),
      );

      if (authenticated) {
        final pin = await _secureStorage.read(key: 'secure_vault_pin');
        if (pin != null) {
          return await unlockSecureNotes(pin);
        }
      }
      return false;
    } catch (e) {
      debugPrint('Biometric unlock error: $e');
      return false;
    }
  }

  bool get isSecureNotesUnlocked =>
      _secureIndexBox != null && _secureIndexBox!.isOpen;

  Future<String> saveSecureMedia(Uint8List bytes, String extension) async {
    if (!isSecureNotesUnlocked) throw Exception('Secure notes locked');
    final id =
        'secure_media_${DateTime.now().microsecondsSinceEpoch}.$extension';
    await _secureMediaBox!.put(id, bytes);
    return 'secure-media://$id';
  }

  Future<Uint8List?> getSecureMedia(String id) async {
    if (!isSecureNotesUnlocked) return null;
    return await _secureMediaBox!.get(id) as Uint8List?;
  }

  Stream<BoxEvent>? watchSecure() => _secureIndexBox?.watch();

  List<NoteModel> getSecureNotes() {
    if (!isSecureNotesUnlocked) return [];
    final result = <NoteModel>[];
    for (final raw in _secureIndexBox!.values) {
      try {
        if (raw is! Map) continue;
        final note = NoteModel.fromMap(Map<String, dynamic>.from(raw));
        if (note.id.isEmpty) continue;
        if (note.id == 'pin_verify') continue;
        if (note.deletedAt != null) continue;
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

  NoteModel? getSecureNoteById(String id) {
    if (!isSecureNotesUnlocked) return null;
    try {
      final raw = _secureIndexBox!.get(id);
      if (raw == null || raw is! Map) return null;
      return NoteModel.fromMap(Map<String, dynamic>.from(raw));
    } catch (_) {
      return null;
    }
  }

  Future<String> getSecureNoteDeltaJson(String id) async {
    if (!isSecureNotesUnlocked) return '[]';
    final data = await _secureLazyDataBox!.get(id);
    return data as String? ?? '[]';
  }

  Future<void> saveSecureNote(NoteModel note) async {
    if (!isSecureNotesUnlocked) throw StateError('Secure notes are locked.');
    await _secureLazyDataBox!.put(
      note.id,
      note.deltaJson.isNotEmpty ? note.deltaJson : '[]',
    );

    // Her ihtimale karşı snippet ve searchableText'i doğrula
    final snippet = note.snippet.isEmpty && note.deltaJson.isNotEmpty
        ? _extractSnippet(note.deltaJson)
        : note.snippet;
    final searchableText =
        note.searchableText.isEmpty && note.deltaJson.isNotEmpty
        ? _extractSearchableText(note.deltaJson)
        : note.searchableText;

    final indexNote = note.copyWith(
      deltaJson: '',
      snippet: snippet,
      searchableText: searchableText,
    );
    await _secureIndexBox!.put(note.id, indexNote.toMap());
  }

  Future<void> secureNotes(List<String> ids) async {
    if (!isSecureNotesUnlocked) throw StateError('Secure notes are locked.');
    for (final id in ids) {
      final note = getNoteById(id);
      if (note != null) {
        var deltaJson = await getNoteDeltaJson(id);
        deltaJson = await _migrateMediaToSecure(deltaJson);

        final secureNote = note.copyWith(isSecure: true, deltaJson: deltaJson);
        // 1. Veritabanını güvenle güncelle
        await _secureLazyDataBox!.put(
          secureNote.id,
          secureNote.deltaJson.isNotEmpty ? secureNote.deltaJson : '[]',
        );
        await _secureIndexBox!.put(
          secureNote.id,
          secureNote.copyWith(deltaJson: '').toMap(),
        );
        await _requireIndexBox.delete(id);
        await _lazyDataBox!.delete(id);
      }
    }
    await cleanOrphanImages();
  }

  Future<void> unsecureNotes(List<String> ids) async {
    if (!isSecureNotesUnlocked) throw StateError('Secure notes are locked.');
    for (final id in ids) {
      final note = getSecureNoteById(id);
      if (note != null) {
        var deltaJson = await getSecureNoteDeltaJson(id);
        deltaJson = await _migrateMediaToPublic(deltaJson);

        final publicNote = note.copyWith(isSecure: false, deltaJson: deltaJson);
        // 1. Veritabanını güvenle güncelle
        await _lazyDataBox!.put(
          publicNote.id,
          publicNote.deltaJson.isNotEmpty ? publicNote.deltaJson : '[]',
        );
        await _requireIndexBox.put(
          publicNote.id,
          publicNote.copyWith(deltaJson: '').toMap(),
        );
        await _secureIndexBox!.delete(id);
        await _secureLazyDataBox!.delete(id);
      }
    }
    await cleanOrphanSecureMedia();
  }

  Future<void> deleteSecureNotes(List<String> ids) async {
    if (!isSecureNotesUnlocked) return;
    await permanentlyDeleteSecureNotes(ids);
  }

  Future<void> permanentlyDeleteSecureNotes(List<String> ids) async {
    if (!isSecureNotesUnlocked) return;
    await _secureIndexBox!.deleteAll(ids);
    await _secureLazyDataBox!.deleteAll(ids);
    await cleanOrphanSecureMedia();
  }

  Future<String> _migrateMediaToSecure(String deltaJson) async {
    if (deltaJson.isEmpty || deltaJson == '[]') return deltaJson;
    try {
      final ops = jsonDecode(deltaJson) as List<dynamic>;
      bool changed = false;
      for (final op in ops) {
        if (op is! Map) continue;
        final insert = op['insert'];
        if (insert is! Map) continue;

        final isImage = insert.containsKey('image');
        final isVideo = insert.containsKey('video');

        if (isImage || isVideo) {
          final mediaPath = isImage ? insert['image'] : insert['video'];
          if (mediaPath is String &&
              !mediaPath.startsWith('http') &&
              !mediaPath.startsWith('secure-media://')) {
            final file = File(mediaPath);
            if (await file.exists()) {
              final bytes = await file.readAsBytes();
              final ext = mediaPath.split('.').last;
              final secureUrl = await saveSecureMedia(bytes, ext);

              if (isImage) {
                insert['image'] = secureUrl;
              } else {
                insert['video'] = secureUrl;
              }
              changed = true;
            }
          }
        }
      }
      if (changed) {
        return jsonEncode(ops);
      }
    } catch (_) {}
    return deltaJson;
  }

  Future<String> _migrateMediaToPublic(String deltaJson) async {
    if (deltaJson.isEmpty || deltaJson == '[]') return deltaJson;
    try {
      final ops = jsonDecode(deltaJson) as List<dynamic>;
      bool changed = false;
      for (final op in ops) {
        if (op is! Map) continue;
        final insert = op['insert'];
        if (insert is! Map) continue;

        final isImage = insert.containsKey('image');
        final isVideo = insert.containsKey('video');

        if (isImage || isVideo) {
          final mediaPath = isImage ? insert['image'] : insert['video'];
          if (mediaPath is String && mediaPath.startsWith('secure-media://')) {
            final mediaId = mediaPath.replaceFirst('secure-media://', '');
            final bytes = await getSecureMedia(mediaId);
            if (bytes != null) {
              final docsDir = await getApplicationDocumentsDirectory();
              final ext = mediaId.split('.').last;
              final isVid = ext == 'mp4';
              final folderName = isVid ? 'note_videos' : 'note_images';
              final dir = Directory('${docsDir.path}/$folderName');
              if (!await dir.exists()) await dir.create(recursive: true);

              final publicPath =
                  '${dir.path}/${DateTime.now().microsecondsSinceEpoch}.$ext';
              await File(publicPath).writeAsBytes(bytes);

              if (isImage) {
                insert['image'] = publicPath;
              } else {
                insert['video'] = publicPath;
              }
              changed = true;
            }
          }
        }
      }
      if (changed) {
        return jsonEncode(ops);
      }
    } catch (_) {}
    return deltaJson;
  }
}

// ─── Arka Plan (Isolate) Şifreleme Metotları ───────────────────────────────

String _generateSaltSync(dynamic _) {
  return BCrypt.gensalt();
}

List<int> _deriveKeySync(Map<String, String> args) {
  final pin = args['pin']!;
  final salt = args['salt']!;
  final hashedPin = BCrypt.hashpw(pin, salt);
  return sha256.convert(utf8.encode(hashedPin)).bytes;
}
