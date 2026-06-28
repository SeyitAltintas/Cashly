import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/note_model.dart';

/// Hive tabanlı not deposu.
///
/// Box yapısı: `'notes'` adlı tek box, her kayıt `noteId` key'i ile tutulur.
/// Çoklu kullanıcı senaryosu için key'e `userId_` prefix'i eklenebilir.
///
/// Projedeki [NotificationSettingsRepository] ile aynı lazy-init pattern'i kullanır.
class NoteRepository {
  static const String _boxName = 'notes';

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
        result.add(NoteModel.fromMap(Map<String, dynamic>.from(raw)));
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
      final raw = _requireBox.get(id);
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
  Future<NoteModel> updateNote({
    required String id,
    required String deltaJson,
    String? title,
  }) async {
    await init();

    // NoteModel.empty() yeni bir ID üretir — bunun yerine sabit ID ile fallback.
    final existing =
        getNoteById(id) ??
        NoteModel(
          id: id,
          deltaJson: '[]',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

    final updated = existing.copyWith(
      deltaJson: deltaJson,
      title: title ?? existing.title,
      updatedAt: DateTime.now(),
    );

    await _requireBox.put(id, updated.toMap());
    return updated;
  }

  // ─── Silme ───────────────────────────────────────────────────────────────

  /// Notu siler. Bulunamazsa sessizce geçer.
  Future<void> deleteNote(String id) async {
    await init();
    await _requireBox.delete(id);
  }

  /// Tüm notları siler.
  Future<void> clearAll() async {
    await init();
    await _requireBox.clear();
  }

  // ─── İstatistik ──────────────────────────────────────────────────────────

  int get noteCount => (_box == null || !_box!.isOpen) ? 0 : _requireBox.length;
}
