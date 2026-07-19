import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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

  Box? _secureIndexBox;
  LazyBox? _secureLazyDataBox;
  LazyBox? _secureMediaBox;

  final LocalAuthentication _auth = LocalAuthentication();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<void>? _initFuture;
  
  /// GÜVENLİK (EDGE CASE): Kamera veya Galeri açıldığında işletim sistemi
  /// uygulamayı arka plana (paused) atar. Bu durumda uygulamanın kendini
  /// otomatik kilitlemesini engellemek için bu flag kullanılır.
  bool isMediaPicking = false;

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
    await _lazyDataBox!.put(note.id, note.deltaJson.isNotEmpty ? note.deltaJson : '[]');
    
    final indexNote = note.copyWith(deltaJson: '');
    await _requireIndexBox.put(note.id, indexNote.toMap());
  }

  Future<void> togglePin(String id) async {
    await init();
    // Sadece index güncellenir — setPinStateForNotes batch ile tutarlı
    final note = getNoteById(id);
    if (note != null) {
      await _requireIndexBox.put(id, note.copyWith(isPinned: !note.isPinned).toMap());
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
    bool isSecure = false,
  }) async {
    await init();

    if (isSecure || (isSecureNotesUnlocked && getSecureNoteById(id) != null)) {
      var note = getSecureNoteById(id) ??
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
      // deletedAt korunur — çöp kutusundaki not editörden kaydedilse bile aktif listeye çıkmaz
    );

    await saveNote(note);
    return note;
  }

  // ─── Silme ───────────────────────────────────────────────────────────────

  Future<void> deleteNote(String id) async {
    await init();
    // LazyBox okunmaz — sadece index güncellenir (deleteNotes batch ile tutarlı)
    final note = getNoteById(id);
    if (note != null) {
      await _requireIndexBox.put(id, note.copyWith(deletedAt: DateTime.now()).toMap());
    }
  }

  Future<void> deleteNotes(List<String> ids) async {
    await init();
    final updates = <String, Map<String, dynamic>>{};
    final now = DateTime.now();

    for (final id in ids) {
      final note = getNoteById(id);
      if (note != null) {
        updates[id] = note.copyWith(deletedAt: now).toMap();
      }
    }

    if (updates.isNotEmpty) {
      await _requireIndexBox.putAll(updates);
    }
  }

  Future<void> restoreNote(String id) async {
    await init();
    // Sadece index güncellenir — restoreNotes batch ile tutarlı
    final note = getNoteById(id);
    if (note != null) {
      await _requireIndexBox.put(id, note.copyWith(clearDeletedAt: true).toMap());
    }
  }

  Future<void> restoreNotes(List<String> ids) async {
    await init();
    final updates = <String, Map<String, dynamic>>{};

    for (final id in ids) {
      final note = getNoteById(id);
      if (note != null) {
        updates[id] = note.copyWith(clearDeletedAt: true).toMap();
      }
    }

    if (updates.isNotEmpty) {
      await _requireIndexBox.putAll(updates);
    }
  }

  Future<void> permanentlyDeleteNote(String id) async {
    await init();
    // 1. LazyBox'tan delta oku (silinmeden önce)
    final deltaStr = await getNoteDeltaJson(id);
    // 2. DB'den önce sil
    await _requireIndexBox.delete(id);
    await _lazyDataBox!.delete(id);
    // 3. Dosyaları sonra sil
    if (deltaStr.isNotEmpty && deltaStr != '[]') {
      await _deleteLocalImages(deltaStr);
    }
  }

  Future<void> permanentlyDeleteNotes(List<String> ids) async {
    await init();
    if (ids.isEmpty) return;

    // 1. Delta JSON'ları önceden topla (LazyBox silinmeden önce okunmalı)
    final deltaJsons = <String>[];
    for (final id in ids) {
      final deltaStr = await getNoteDeltaJson(id);
      deltaJsons.add(deltaStr);
    }

    // 2. Önce DB'den sil (kaynak gerçeği temizle)
    //    Crash olursa dosyalar orphan kalır → cleanOrphanImages() temizler.
    //    Ters sırada crash → DB'de kayıt var ama dosya yok (daha kötü).
    await _requireIndexBox.deleteAll(ids);
    await _lazyDataBox!.deleteAll(ids);

    // 3. Sonra yerel medya dosyalarını sil
    for (final deltaStr in deltaJsons) {
      if (deltaStr.isNotEmpty && deltaStr != '[]') {
        await _deleteLocalImages(deltaStr);
      }
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
      debugPrint('EC-TRASH: $days günden eski ${idsToDelete.length} not kalıcı olarak silindi.');
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

    // Close and securely delete encrypted secure boxes from disk
    await closeSecureNotes();
    await Hive.deleteBoxFromDisk('secure_notes_index');
    await Hive.deleteBoxFromDisk('secure_notes_data');
    await Hive.deleteBoxFromDisk('secure_media_box');

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

  bool get hasSecurePin => _requireIndexBox.get('has_secure_pin', defaultValue: false) as bool;

  Future<void> setSecurePin(String pin) async {
    // Generate salt asynchronously on a background isolate
    final salt = await compute(_generateSaltSync, null);
    await _requireIndexBox.put('secure_pin_salt', salt);

    final success = await unlockSecureNotes(pin);
    if (success) {
      await _requireIndexBox.put('has_secure_pin', true);
    }
  }

  Future<bool> unlockSecureNotes(String pin) async {
    try {
      final salt = _requireIndexBox.get('secure_pin_salt') as String?;
      List<int> key;

      if (salt != null) {
        // PBKDF2/Bcrypt key stretching
        key = await compute(_deriveKeySync, {'pin': pin, 'salt': salt});
      } else {
        // Fallback for existing PINs created before the security update
        key = sha256.convert(utf8.encode(pin)).bytes;
      }
      
      if (_secureIndexBox?.isOpen == true) await _secureIndexBox!.close();
      if (_secureLazyDataBox?.isOpen == true) await _secureLazyDataBox!.close();

      if (_secureMediaBox?.isOpen == true) await _secureMediaBox!.close();

      _secureIndexBox = await Hive.openBox(
        'secure_notes_index',
        encryptionCipher: HiveAesCipher(key),
      );
      _secureLazyDataBox = await Hive.openLazyBox(
        'secure_notes_data',
        encryptionCipher: HiveAesCipher(key),
      );
      _secureMediaBox = await Hive.openLazyBox(
        'secure_media_box',
        encryptionCipher: HiveAesCipher(key),
      );

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

  Future<void> closeSecureNotes() async {
    if (_secureIndexBox?.isOpen == true) await _secureIndexBox!.close();
    _secureIndexBox = null;
    if (_secureLazyDataBox?.isOpen == true) await _secureLazyDataBox!.close();
    _secureLazyDataBox = null;
    if (_secureMediaBox?.isOpen == true) await _secureMediaBox!.close();
    _secureMediaBox = null;
  }

  /// GÜVENLİK (EDGE CASE): Kullanıcı PIN'ini unutursa, şifreli veriler
  /// asla geri getirilemez. Bu durumda sistemi tekrar kullanabilmesi için
  /// kilitli kutuların diskten fiziksel olarak silinmesi gerekir (Hard Wipe).
  Future<void> resetSecureKasa() async {
    await closeSecureNotes();
    
    await Hive.deleteBoxFromDisk('secure_notes_index');
    await Hive.deleteBoxFromDisk('secure_notes_data');
    await Hive.deleteBoxFromDisk('secure_media_box');
    
    await _requireIndexBox.delete('has_secure_pin');
    await _requireIndexBox.delete('secure_pin_salt');
    await disableBiometric(); // Biyometrik çipi temizle
    await disableAutoUnlock(); // Otomatik giriş çipini temizle
  }

  // ─── PIN Migration (Şifre Değiştirme) ─────────────────────────────────────

  Future<bool> changeSecurePin(String currentPin, String newPin) async {
    if (!isSecureNotesUnlocked) return false;

    try {
      // 1. Yazılı metinleri ve indeksleri RAM'e al (Metinler az yer kaplar)
      final allIndex = _secureIndexBox!.toMap();
      final allDataKeys = _secureLazyDataBox!.keys.toList();
      final Map<dynamic, dynamic> allData = {};
      for (var k in allDataKeys) {
        allData[k] = await _secureLazyDataBox!.get(k);
      }

      // 2. Medyaları RAM'de tutmak OOM (Out Of Memory) yaratabilir.
      // Bu yüzden geçici bir AES kutusu açıp oraya kopyalıyoruz.
      final tempMediaKey = Hive.generateSecureKey();
      final tempMediaBox = await Hive.openLazyBox('temp_secure_media', encryptionCipher: HiveAesCipher(tempMediaKey));
      final allMediaKeys = _secureMediaBox!.keys.toList();
      for (var k in allMediaKeys) {
        final mediaData = await _secureMediaBox!.get(k);
        if (mediaData != null) await tempMediaBox.put(k, mediaData);
      }

      // 3. Mevcut kasayı tamamen Yok Et (Reset). Biyometrik vs. de sıfırlanır.
      await resetSecureKasa();

      // 4. Yeni PIN ile kasayı baştan yarat (Kutular otomatik yeni şifreyle açılır)
      await setSecurePin(newPin);

      // 5. Verileri eski sistemden / geçici sistemden yeni kasaya aktar
      await _secureIndexBox!.putAll(allIndex);
      for (var entry in allData.entries) {
        await _secureLazyDataBox!.put(entry.key, entry.value);
      }
      for (var k in allMediaKeys) {
        final mediaData = await tempMediaBox.get(k);
        if (mediaData != null) await _secureMediaBox!.put(k, mediaData);
      }

      // 6. Geçici kutuyu sil
      await tempMediaBox.close();
      await Hive.deleteBoxFromDisk('temp_secure_media');

      return true;
    } catch (e) {
      debugPrint('PIN Migration failed: $e');
      return false;
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
    final canAuthenticate = canAuthenticateWithBiometrics || await _auth.isDeviceSupported();
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
          biometricOnly: true, // Sadece parmak izi/yüz tanıma (cihaz PIN'i değil)
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

  bool get isSecureNotesUnlocked => _secureIndexBox != null && _secureIndexBox!.isOpen;

  Future<String> saveSecureMedia(Uint8List bytes, String extension) async {
    if (!isSecureNotesUnlocked) throw Exception('Secure notes locked');
    final id = 'secure_media_${DateTime.now().millisecondsSinceEpoch}.$extension';
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
    await _secureLazyDataBox!.put(note.id, note.deltaJson.isNotEmpty ? note.deltaJson : '[]');
    final indexNote = note.copyWith(deltaJson: '');
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
        await _secureLazyDataBox!.put(secureNote.id, secureNote.deltaJson.isNotEmpty ? secureNote.deltaJson : '[]');
        await _secureIndexBox!.put(secureNote.id, secureNote.copyWith(deltaJson: '').toMap());
        await _requireIndexBox.delete(id);
        await _lazyDataBox!.delete(id);
      }
    }
  }

  Future<void> unsecureNotes(List<String> ids) async {
    if (!isSecureNotesUnlocked) throw StateError('Secure notes are locked.');
    for (final id in ids) {
      final note = getSecureNoteById(id);
      if (note != null) {
        var deltaJson = await getSecureNoteDeltaJson(id);
        deltaJson = await _migrateMediaToPublic(deltaJson);
        final publicNote = note.copyWith(isSecure: false, deltaJson: deltaJson);
        await _lazyDataBox!.put(publicNote.id, publicNote.deltaJson.isNotEmpty ? publicNote.deltaJson : '[]');
        await _requireIndexBox.put(publicNote.id, publicNote.copyWith(deltaJson: '').toMap());
        await _secureIndexBox!.delete(id);
        await _secureLazyDataBox!.delete(id);
      }
    }
  }

  Future<void> deleteSecureNotes(List<String> ids) async {
    if (!isSecureNotesUnlocked) return;
    await permanentlyDeleteSecureNotes(ids);
  }

  Future<void> permanentlyDeleteSecureNotes(List<String> ids) async {
    if (!isSecureNotesUnlocked) return;
    final deltaJsons = <String>[];
    for (final id in ids) {
      final deltaStr = await getSecureNoteDeltaJson(id);
      deltaJsons.add(deltaStr);
    }
    await _secureIndexBox!.deleteAll(ids);
    await _secureLazyDataBox!.deleteAll(ids);
    for (final deltaStr in deltaJsons) {
      if (deltaStr.isNotEmpty && deltaStr != '[]') {
        await _deleteSecureMediaFromDelta(deltaStr);
        await _deleteLocalImages(deltaStr);
      }
    }
  }

  Future<void> _deleteSecureMediaFromDelta(String deltaJson) async {
    if (!isSecureNotesUnlocked) return;
    try {
      final ops = jsonDecode(deltaJson) as List<dynamic>;
      for (final op in ops) {
        if (op is! Map) continue;
        final insert = op['insert'];
        if (insert is! Map) continue;
        final mediaPath = insert['image'] ?? insert['video'];
        if (mediaPath is String && mediaPath.startsWith('secure-media://')) {
          final mediaId = mediaPath.replaceFirst('secure-media://', '');
          await _secureMediaBox!.delete(mediaId);
          debugPrint('EC-18: Secure medya silindi → $mediaId');
        }
      }
    } catch (e) {
      debugPrint('EC-18: Secure medya silinirken hata: $e');
    }
  }

  Future<String> _migrateMediaToSecure(String deltaJson) async {
    if (deltaJson.isEmpty || deltaJson == '[]') return deltaJson;
    String newJson = deltaJson;
    try {
      final ops = jsonDecode(deltaJson) as List<dynamic>;
      for (final op in ops) {
        if (op is! Map) continue;
        final insert = op['insert'];
        if (insert is! Map) continue;
        final mediaPath = insert['image'] ?? insert['video'];
        if (mediaPath is String && !mediaPath.startsWith('http') && !mediaPath.startsWith('secure-media://')) {
          final file = File(mediaPath);
          if (await file.exists()) {
            final bytes = await file.readAsBytes();
            final ext = mediaPath.split('.').last;
            final secureUrl = await saveSecureMedia(bytes, ext);
            newJson = newJson.replaceAll('"$mediaPath"', '"$secureUrl"');
            await file.delete(); 
          }
        }
      }
    } catch (_) {}
    return newJson;
  }

  Future<String> _migrateMediaToPublic(String deltaJson) async {
    if (deltaJson.isEmpty || deltaJson == '[]') return deltaJson;
    String newJson = deltaJson;
    try {
      final ops = jsonDecode(deltaJson) as List<dynamic>;
      for (final op in ops) {
        if (op is! Map) continue;
        final insert = op['insert'];
        if (insert is! Map) continue;
        final mediaPath = insert['image'] ?? insert['video'];
        if (mediaPath is String && mediaPath.startsWith('secure-media://')) {
          final mediaId = mediaPath.replaceFirst('secure-media://', '');
          final bytes = await getSecureMedia(mediaId);
          if (bytes != null) {
            final docsDir = await getApplicationDocumentsDirectory();
            final ext = mediaId.split('.').last;
            final isVideo = ext == 'mp4';
            final folderName = isVideo ? 'note_videos' : 'note_images';
            final dir = Directory('${docsDir.path}/$folderName');
            if (!await dir.exists()) await dir.create(recursive: true);
            
            final publicPath = '${dir.path}/${DateTime.now().microsecondsSinceEpoch}.$ext';
            await File(publicPath).writeAsBytes(bytes);
            newJson = newJson.replaceAll('"$mediaPath"', '"$publicPath"');
            await _secureMediaBox!.delete(mediaId); 
          }
        }
      }
    } catch (_) {}
    return newJson;
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
