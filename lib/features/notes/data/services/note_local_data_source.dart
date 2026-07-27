import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cashly/core/di/injection_container.dart';
import 'package:cashly/features/auth/domain/repositories/auth_repository.dart';
import '../models/note_model.dart';
import 'note_text_utils.dart';
import 'note_media_service.dart';

/// Public not verilerinin Hive tabanlı depolama katmanı.
///
/// Box yapısı:
/// - `notes_index_$userId` — Hafif meta veriler (NoteModel'ın deltaJson'sız hali).
/// - `notes_data_$userId`  — Ağır delta JSON verileri (LazyBox ile tembel yükleme).
///
/// Güvenli kasa ve şifreleme işlemleri [SecureVaultService]'e aittir.
class NoteLocalDataSource {
  String _currentUserId = 'default';
  String get indexBoxName => 'notes_index_$_currentUserId';
  String get lazyDataBoxName => 'notes_data_$_currentUserId';

  Box? _indexBox;
  LazyBox? _lazyDataBox;
  Future<void>? _initFuture;

  /// GÜVENLİK (EDGE CASE): Kamera/Galeri açıkken sistemin uygulamayı
  /// paused'a alması otomatik kilidi tetiklememelidir.
  bool isMediaPicking = false;

  /// Public index box'ı dışa açar; SecureVaultService'in PIN hash'leri
  /// buraya yazması için Facade üzerinden erişilir.
  Box get requireIndexBox {
    assert(
      _indexBox != null && _indexBox!.isOpen,
      'NoteLocalDataSource.init() must be called first',
    );
    return _indexBox!;
  }

  /// Güvenli kasa tarafından kullanıcı kimliğine ihtiyaç duyulduğunda erişilir.
  String get currentUserId => _currentUserId;

  /// Media migrasyon işlemlerinde SecureVaultService'in erişmesi için.
  /// init() çağrılmadan erişilirse AssertionError fırlatır.
  LazyBox get lazyBox {
    assert(
      _lazyDataBox != null && _lazyDataBox!.isOpen,
      'NoteLocalDataSource.init() must be called before accessing lazyBox',
    );
    return _lazyDataBox!;
  }

  // ─── Başlatma ─────────────────────────────────────────────────────────────

  Future<void> init() async {
    // Hızlı yol: kutular zaten doğru isimle açıksa tekrar getCurrentUser() çağırma.
    if (_indexBox != null &&
        _indexBox!.isOpen &&
        _indexBox!.name == indexBoxName &&
        _lazyDataBox != null &&
        _lazyDataBox!.isOpen &&
        _lazyDataBox!.name == lazyDataBoxName) {
      return;
    }

    // Kutu adı değişebilir — userId'yi güncelle.
    try {
      final authRepo = getIt<AuthRepository>();
      final user = await authRepo.getCurrentUser();
      _currentUserId = user?.id ?? 'default';
    } catch (_) {
      // getIt henüz başlatılmamışsa veya test ortamındaysa geç.
    }

    // Farklı kullanıcının kutusu açıksa kapat
    await closeAll();

    if (_initFuture == null) {
      _initFuture = _openBox();
      await _initFuture;
      _initFuture = null;
    } else {
      await _initFuture;
    }
  }

  Future<void> closeAll() async {
    if (_indexBox != null && _indexBox!.isOpen) await _indexBox!.close();
    if (_lazyDataBox != null && _lazyDataBox!.isOpen) await _lazyDataBox!.close();
    _indexBox = null;
    _lazyDataBox = null;
    _initFuture = null;
  }

  Future<void> _openBox() async {
    // Migration: Ortak 'notes_index' kutusunu kullanıcıya özel isime taşı
    if (_currentUserId != 'default') {
      if (await Hive.boxExists('notes_index') &&
          !(await Hive.boxExists(indexBoxName))) {
        debugPrint('Migration: Taşıma başlıyor. notes_index -> $indexBoxName');
        final oldIndex = await Hive.openBox('notes_index');
        final newIndex = await Hive.openBox(indexBoxName);
        await newIndex.putAll(Map.from(oldIndex.toMap()));
        await oldIndex.close();
        await Hive.deleteBoxFromDisk('notes_index');

        if (await Hive.boxExists('notes_data')) {
          final oldData = await Hive.openLazyBox('notes_data');
          final newData = await Hive.openLazyBox(lazyDataBoxName);
          for (final key in oldData.keys) {
            final val = await oldData.get(key);
            await newData.put(key, val);
          }
          await oldData.close();
          await Hive.deleteBoxFromDisk('notes_data');
        }
      }
    }

    _indexBox = await Hive.openBox(indexBoxName);
    _lazyDataBox = await Hive.openLazyBox(lazyDataBoxName);

    // Eski tek-kutulu migrasyonu uygula
    if (await Hive.boxExists('notes')) {
      await _migrateOldBox();
    }

    // iOS Sandbox Path Değişikliği Taraması
    await NoteMediaService.fixSandboxPaths(_lazyDataBox!);

    // Arka planda orphan resimleri temizle (EC-25) — fire-and-forget
    NoteMediaService.cleanOrphanImages(_lazyDataBox!);
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
        await _lazyDataBox!.put(key, deltaStr);
        noteMap['deltaJson'] = '';
        noteMap['snippet'] = extractSnippet(deltaStr);
        noteMap['searchableText'] = extractSearchableText(deltaStr);
        updatesIndex[key.toString()] = noteMap;
      }
    }
    await _indexBox!.putAll(updatesIndex);
    await oldBox.deleteFromDisk();
    debugPrint('Migration completed: moved old notes to index/lazyBox.');
  }

  // ─── Kullanıcı Tercihleri ──────────────────────────────────────────────────

  bool get isGridView {
    if (_indexBox == null || !_indexBox!.isOpen) return false;
    return _indexBox!.get('prefs_is_grid_view', defaultValue: false) as bool;
  }

  Future<void> setGridView(bool value) async {
    await init();
    await requireIndexBox.put('prefs_is_grid_view', value);
  }

  // ─── Listenable / Watch ───────────────────────────────────────────────────

  ValueListenable<Box> listenable() => requireIndexBox.listenable();
  Stream<BoxEvent> watch() => requireIndexBox.watch();

  // ─── Okuma ────────────────────────────────────────────────────────────────

  List<NoteModel> getAllNotes() {
    if (_indexBox == null || !_indexBox!.isOpen) return [];
    final result = <NoteModel>[];
    for (final raw in _indexBox!.values) {
      try {
        if (raw is! Map) continue;
        final note = NoteModel.fromMap(Map<String, dynamic>.from(raw));
        if (note.id.isEmpty) continue;
        if (note.id == 'prefs_is_grid_view') continue;
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

  List<NoteModel> getTrashNotes() {
    if (_indexBox == null || !_indexBox!.isOpen) return [];
    final result = <NoteModel>[];
    for (final raw in _indexBox!.values) {
      try {
        if (raw is! Map) continue;
        final note = NoteModel.fromMap(Map<String, dynamic>.from(raw));
        if (note.id.isEmpty) continue;
        if (note.id == 'prefs_is_grid_view') continue;
        if (note.deletedAt == null) continue;
        result.add(note);
      } catch (_) {}
    }
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

  int get noteCount => getAllNotes().length;

  bool containsKey(String id) => requireIndexBox.containsKey(id);

  // ─── Yazma ────────────────────────────────────────────────────────────────

  Future<void> saveNote(NoteModel note) async {
    await init();
    await _lazyDataBox!.put(
      note.id,
      note.deltaJson.isNotEmpty ? note.deltaJson : '[]',
    );

    final snippet = note.snippet.isEmpty && note.deltaJson.isNotEmpty
        ? extractSnippet(note.deltaJson)
        : note.snippet;
    final searchableText =
        note.searchableText.isEmpty && note.deltaJson.isNotEmpty
        ? extractSearchableText(note.deltaJson)
        : note.searchableText;

    final indexNote = note.copyWith(
      deltaJson: '',
      snippet: snippet,
      searchableText: searchableText,
    );
    await requireIndexBox.put(note.id, indexNote.toMap());
  }

  Future<void> togglePin(String id) async {
    await init();
    final note = getNoteById(id);
    if (note != null) {
      await requireIndexBox.put(
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
        updates[id] = note.copyWith(isPinned: isPinned).toMap();
      }
    }
    if (updates.isNotEmpty) await requireIndexBox.putAll(updates);
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
    if (updates.isNotEmpty) await requireIndexBox.putAll(updates);
  }

  Future<void> removeCategoryFromNotes(String categoryId) async {
    await init();
    final updates = <String, Map<String, dynamic>>{};
    for (final key in requireIndexBox.keys) {
      if (key == 'prefs_is_grid_view') continue;
      final raw = requireIndexBox.get(key);
      if (raw is Map) {
        final noteMap = Map<String, dynamic>.from(raw);
        if (noteMap['categoryId'] == categoryId) {
          noteMap['categoryId'] = null;
          updates[key as String] = noteMap;
        }
      }
    }
    if (updates.isNotEmpty) await requireIndexBox.putAll(updates);
  }

  // ─── Soft Delete / Restore ────────────────────────────────────────────────

  Future<void> softDeleteNote(String id) async {
    if (!requireIndexBox.containsKey(id)) return;
    final raw = requireIndexBox.get(id);
    if (raw != null) {
      final note = NoteModel.fromMap(Map<String, dynamic>.from(raw));
      await requireIndexBox.put(
        id,
        note.copyWith(deletedAt: DateTime.now()).toMap(),
      );
    }
  }

  Future<void> softDeleteNotes(List<String> ids) async {
    final now = DateTime.now();
    final updates = <String, Map<String, dynamic>>{};
    for (final id in ids) {
      if (!requireIndexBox.containsKey(id)) continue;
      final raw = requireIndexBox.get(id);
      if (raw != null) {
        final note = NoteModel.fromMap(Map<String, dynamic>.from(raw));
        updates[id] = note.copyWith(deletedAt: now).toMap();
      }
    }
    if (updates.isNotEmpty) await requireIndexBox.putAll(updates);
  }

  Future<void> restoreNote(String id) async {
    if (!requireIndexBox.containsKey(id)) return;
    final raw = requireIndexBox.get(id);
    if (raw != null) {
      final note = NoteModel.fromMap(Map<String, dynamic>.from(raw));
      await requireIndexBox.put(id, note.copyWith(clearDeletedAt: true).toMap());
    }
  }

  Future<void> restoreNotes(List<String> ids) async {
    final updates = <String, Map<String, dynamic>>{};
    for (final id in ids) {
      if (!requireIndexBox.containsKey(id)) continue;
      final raw = requireIndexBox.get(id);
      if (raw != null) {
        final note = NoteModel.fromMap(Map<String, dynamic>.from(raw));
        updates[id] = note.copyWith(clearDeletedAt: true).toMap();
      }
    }
    if (updates.isNotEmpty) await requireIndexBox.putAll(updates);
  }

  // ─── Kalıcı Silme ─────────────────────────────────────────────────────────

  /// Hem index hem data kutusundan siler ve orphan medyaları temizler.
  Future<void> permanentlyDeleteNote(String id) async {
    await requireIndexBox.delete(id);
    await _lazyDataBox!.delete(id);
    await NoteMediaService.cleanOrphanImages(_lazyDataBox!);
  }

  /// Batch kalıcı silme + orphan temizleme.
  Future<void> permanentlyDeleteNotes(List<String> ids) async {
    if (ids.isEmpty) return;
    await requireIndexBox.deleteAll(ids);
    await _lazyDataBox!.deleteAll(ids);
    await NoteMediaService.cleanOrphanImages(_lazyDataBox!);
  }

  /// Orphan temizleme olmadan ham Hive girişlerini siler.
  /// Güvenli kasadan taşıma işlemlerinde Facade tarafından kullanılır.
  Future<void> hardDeleteEntries(List<String> ids) async {
    for (final id in ids) {
      await requireIndexBox.delete(id);
      await _lazyDataBox!.delete(id);
    }
  }

  Future<void> emptyTrash() async {
    final trashNotes = getTrashNotes();
    if (trashNotes.isEmpty) return;
    await permanentlyDeleteNotes(trashNotes.map((n) => n.id).toList());
  }

  Future<void> cleanOldTrashNotes([int days = 30]) async {
    final trashNotes = getTrashNotes();
    if (trashNotes.isEmpty) return;
    final limitDate = DateTime.now().subtract(Duration(days: days));
    final idsToDelete = trashNotes
        .where(
          (n) => n.deletedAt != null && n.deletedAt!.isBefore(limitDate),
        )
        .map((n) => n.id)
        .toList();

    if (idsToDelete.isNotEmpty) {
      await permanentlyDeleteNotes(idsToDelete);
      debugPrint(
        'EC-TRASH: $days günden eski ${idsToDelete.length} not kalıcı olarak silindi.',
      );
    }
  }

  /// Public verilerin tamamını temizler (not kutular + medya dizinleri).
  /// Güvenli kasa verileri [SecureVaultService.deleteAllBoxesFromDisk] ile silinir.
  Future<void> clearPublicData() async {
    await requireIndexBox.clear();
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

}
