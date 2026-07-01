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
    return result..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
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
    DateTime? originalCreatedAt,
  }) async {
    await init();

    // NoteModel.empty() yeni bir ID üretir — bunun yerine sabit ID ile fallback.
    final existing = getNoteById(id);
    final fallback = NoteModel(
      id: id,
      deltaJson: '[]',
      // EC-16: Editorden geçilen gerçek tarih; yoksa şimdi.
      createdAt: originalCreatedAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final updated = (existing ?? fallback).copyWith(
      deltaJson: deltaJson,
      title: title ?? (existing?.title ?? ''),
      color: color,
      clearColor: clearColor,
      updatedAt: DateTime.now(),
    );

    await _requireBox.put(id, updated.toMap());
    return updated;
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

  /// Delta JSON içinden yerel resim path'lerini bulup siler.
  static Future<void> _deleteLocalImages(String deltaJson) async {
    try {
      final ops = jsonDecode(deltaJson) as List<dynamic>;
      for (final op in ops) {
        if (op is! Map) continue;
        final insert = op['insert'];
        if (insert is! Map) continue;
        final imgPath = insert['image'];
        if (imgPath is! String) continue;
        if (imgPath.startsWith('http')) continue; // uzak URL, atla
        final file = File(imgPath);
        if (await file.exists()) {
          await file.delete();
          debugPrint('EC-18: Orphan resim silindi → $imgPath');
        }
      }
    } catch (e) {
      debugPrint('EC-18: Resim temizleme hatası: $e');
      // Sessizce geç — resim silme başarısız olsa bile not silindi.
    }
  }

  /// Tüm notları siler.
  /// EC-24: Ayrıca tüm not resimlerini (note_images dizini) de siler.
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
    } catch (e) {
      debugPrint('EC-24: Resim klasörü silinemedi: $e');
    }
  }

  // ─── İstatistik ──────────────────────────────────────────────────────────

  int get noteCount => (_box == null || !_box!.isOpen) ? 0 : _requireBox.length;
}
