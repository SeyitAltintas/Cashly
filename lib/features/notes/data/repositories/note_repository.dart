import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import '../models/note_model.dart';

/// Hive tabanlı not deposu.
///
/// Box yapısı: `'notes'` adlı tek box, her kayıt `noteId` key'i ile tutulur.
/// Çoklu kullanıcı senaryosu için key'e `userId_` prefix'i eklenebilir.
///
/// Projedeki [NotificationSettingsRepository] ile aynı lazy-init pattern'i kullanır.
class NoteRepository {
  static const String _boxName = 'notes';

  // EC-8: Singleton — NotesListPage ve NoteEditorPage aynı instance'ı paylaşır.
  // Hive box'u iki kez açma riski ortadan kalkar.
  static final NoteRepository _instance = NoteRepository._internal();
  factory NoteRepository() => _instance;
  NoteRepository._internal();

  Box? _box;

  /// Eş zamanlı init() çağrılarında race condition önleyici.
  Future<void>? _initFuture;

  /// Box'ı açar (henüz açık değilse).
  ///
  /// Eş zamanlı çağrılara karşı güvenli: ikinci çağrı ilk Future'ı paylaşır.
  Future<void> init() {
    if (_box != null && _box!.isOpen) return Future.value();
    return _initFuture ??= _openBox_().whenComplete(() => _initFuture = null);
  }

  Future<void> _openBox_() async {
    _box = await Hive.openBox(_boxName);
    // Arka planda orphan resimleri temizle (EC-25)
    cleanOrphanImages();
  }

  /// [ValueListenableBuilder] ile kullanım için Hive Listenable döndürür.
  /// [init] çağrıldıktan sonra kullanılabilir.
  ValueListenable<Box> listenable() => _requireBox.listenable();

  Box get _requireBox {
    assert(
      _box != null && _box!.isOpen,
      'NoteRepository.init() must be called first',
    );
    return _box!;
  }

  // ─── Kullanıcı Tercihleri ────────────────────────────────────────────────

  bool get isGridView {
    if (_box == null || !_box!.isOpen) return false;
    return _box!.get('prefs_is_grid_view', defaultValue: false) as bool;
  }

  Future<void> setGridView(bool value) async {
    await init();
    await _requireBox.put('prefs_is_grid_view', value);
  }

  // ─── Okuma ───────────────────────────────────────────────────────────────

  /// Tüm notları güncelleme tarihine göre sıralı döndürür.
  ///
  /// Bozuk girdiler sessizce atlanır — tek bir hata tüm listeyi patlatmaz.
  List<NoteModel> getAllNotes() {
    if (_box == null || !_box!.isOpen) return [];

    final result = <NoteModel>[];
    for (final raw in _box!.values) {
      try {
        if (raw is! Map) continue;
        final note = NoteModel.fromMap(Map<String, dynamic>.from(raw));
        if (note.id.isEmpty) continue; // EC-16: bozuk id, atla
        // Özel key'leri filtrele
        if (note.id == 'prefs_is_grid_view') continue;

        result.add(note);
      } catch (_) {
        // Bozuk Hive girdisi — atla, listeyi bozmaya bırakma.
      }
    }
    result.sort((a, b) {
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      return b.updatedAt.compareTo(a.updatedAt);
    });
    return result;
  }

  /// ID'ye göre tek not getirir. Bulunamazsa veya bozuksa null döner.
  NoteModel? getNoteById(String id) {
    if (_box == null || !_box!.isOpen) return null;

    try {
      final raw = _box!.get(id); // EC-11: _requireBox yerine tutarlı _box!
      if (raw == null || raw is! Map) return null;
      return NoteModel.fromMap(Map<String, dynamic>.from(raw));
    } catch (_) {
      return null;
    }
  }

  // ─── Yazma ───────────────────────────────────────────────────────────────

  /// Notu kaydeder. Yoksa oluşturur, varsa günceller (upsert).
  Future<void> saveNote(NoteModel note) async {
    await init();
    await _requireBox.put(note.id, note.toMap());
  }

  /// Notun sabitlenme durumunu değiştirir.
  Future<void> togglePin(String id) async {
    final note = getNoteById(id);
    if (note != null) {
      await saveNote(note.copyWith(isPinned: !note.isPinned));
    }
  }

  /// Çoklu not sabitleme/kaldırma.
  Future<void> setPinStateForNotes(List<String> ids, bool isPinned) async {
    await init();
    for (final id in ids) {
      final note = getNoteById(id);
      if (note != null) {
        await saveNote(note.copyWith(isPinned: isPinned));
      }
    }
  }

  /// Removes a specific category from all notes that have it.
  Future<void> removeCategoryFromNotes(String categoryId) async {
    await init();
    final updates = <String, Map<String, dynamic>>{};
    
    for (final key in _requireBox.keys) {
      if (key == 'prefs_is_grid_view') continue;
      final raw = _requireBox.get(key);
      if (raw is Map) {
        final noteMap = Map<String, dynamic>.from(raw);
        if (noteMap['categoryId'] == categoryId) {
          noteMap['categoryId'] = null;
          updates[key as String] = noteMap;
        }
      }
    }
    
    if (updates.isNotEmpty) {
      await _requireBox.putAll(updates);
    }
  }

  /// Sadece delta ve başlık günceller; createdAt değişmez.
  ///
  /// [originalCreatedAt]: Editor'den iletilir. Not dışardan silinmişse
  /// yeniden oluşturulurken orijinal tarih korunur (EC-16).
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

    // NoteModel.empty() yeni bir ID üretir — bunun yerine sabit ID ile fallback.
    var note = getNoteById(id) ??
        NoteModel(
          id: id,
          title: '',
          deltaJson: deltaJson,
          createdAt: originalCreatedAt ?? DateTime.now(),
          updatedAt: DateTime.now(),
          categoryId: null,
        );

    note = note.copyWith(
      deltaJson: deltaJson,
      title: title,
      updatedAt: DateTime.now(),
      color: clearColor ? null : color,
      categoryId: clearCategory ? null : categoryId,
    );
    if (clearCategory) {
      note = note.copyWith(clearCategory: true);
    }
    if (clearColor) {
      note = note.copyWith(clearColor: true);
    }

    await saveNote(note);
    return note;
  }

  // ─── Silme ───────────────────────────────────────────────────────────────

  /// Notu siler. Bulunamazsa sessizce geçer.
  /// EC-18: Not içindeki yerel resim dosyalarını da temizler (orphan önleme).
  Future<void> deleteNote(String id) async {
    await init();
    // Silmeden önce delta'yı oku, yerel path'leri topla.
    final note = getNoteById(id);
    await _requireBox.delete(id);
    if (note != null) {
      _deleteLocalImages(note.deltaJson); // fire-and-forget, hata fırlatsın
    }
  }

  /// Çoklu not silme.
  Future<void> deleteNotes(List<String> ids) async {
    for (final id in ids) {
      await deleteNote(id);
    }
  }

  /// Delta JSON içinden yerel resim ve video path'lerini bulup siler.
  static Future<void> _deleteLocalImages(String deltaJson) async {
    try {
      final ops = jsonDecode(deltaJson) as List<dynamic>;
      for (final op in ops) {
        if (op is! Map) continue;
        final insert = op['insert'];
        if (insert is! Map) continue;
        final mediaPath = insert['image'] ?? insert['video'];
        if (mediaPath is! String) continue;
        if (mediaPath.startsWith('http')) continue; // uzak URL, atla
        final file = File(mediaPath);
        if (await file.exists()) {
          await file.delete();
          debugPrint('EC-18: Orphan medya silindi → $mediaPath');
        }
      }
    } catch (e) {
      debugPrint('EC-18: Medya temizleme hatası: $e');
      // Sessizce geç — silme başarısız olsa bile not silindi.
    }
  }

  /// Tüm notları siler.
  /// EC-24: Ayrıca tüm not resimlerini ve videolarını da siler.
  Future<void> clearAll() async {
    await init();
    await _requireBox.clear();

    try {
      final docsDir = await getApplicationDocumentsDirectory();
      final noteImgDir = Directory('${docsDir.path}/note_images');
      if (await noteImgDir.exists()) {
        await noteImgDir.delete(recursive: true);
        debugPrint('EC-24: Tüm not resimleri silindi.');
      }
      
      final noteVidDir = Directory('${docsDir.path}/notes_videos');
      if (await noteVidDir.exists()) {
        await noteVidDir.delete(recursive: true);
        debugPrint('EC-24: Tüm not videoları silindi.');
      }
    } catch (e) {
      debugPrint('EC-24: Medya klasörü silinemedi: $e');
    }
  }

  /// Sistemdeki ancak Hive'daki hiçbir notta kullanılmayan
  /// yetim (orphan) medyaları bulup siler. (EC-25)
  Future<void> cleanOrphanImages() async {
    try {
      final docsDir = await getApplicationDocumentsDirectory();
      final imgDir = Directory('${docsDir.path}/note_images');
      final vidDir = Directory('${docsDir.path}/notes_videos');

      // 1. Hive'daki tüm notların deltaJson'larından aktif medya yollarını topla
      final activePaths = <String>{};
      final notes = getAllNotes();
      for (final note in notes) {
        try {
          final ops = jsonDecode(note.deltaJson) as List<dynamic>;
          for (final op in ops) {
            if (op is! Map) continue;
            final insert = op['insert'];
            if (insert is! Map) continue;
            final mediaPath = insert['image'] ?? insert['video'];
            if (mediaPath is String && !mediaPath.startsWith('http')) {
              // Path ayırıcı farklılıklarını (Windows \ vs Unix /) eşitle
              activePaths.add(File(mediaPath).path);
            }
          }
        } catch (_) {}
      }

      // 2. Klasörlerdeki tüm dosyaları gez, aktif listede olmayanları sil
      if (await imgDir.exists()) {
        final files = imgDir.listSync();
        for (final entity in files) {
          if (entity is File && !activePaths.contains(entity.path)) {
            await entity.delete();
            debugPrint('EC-25: Orphan resim silindi → ${entity.path}');
          }
        }
      }
      
      if (await vidDir.exists()) {
        final files = vidDir.listSync();
        for (final entity in files) {
          if (entity is File && !activePaths.contains(entity.path)) {
            await entity.delete();
            debugPrint('EC-25: Orphan video silindi → ${entity.path}');
          }
        }
      }
    } catch (e) {
      debugPrint('EC-25: Orphan temizleme hatası: $e');
    }
  }

  // ─── İstatistik ──────────────────────────────────────────────────────────

  int get noteCount {
    if (_box == null || !_box!.isOpen) return 0;
    int count = _requireBox.length;
    if (_requireBox.containsKey('prefs_is_grid_view')) {
      count -= 1;
    }
    return count;
  }
}
