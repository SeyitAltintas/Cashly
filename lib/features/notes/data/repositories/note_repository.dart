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

  /// Box'ı açar (henüz açık değilse).
  Future<void> init() async {
    if (_box == null || !_box!.isOpen) {
      _box = await Hive.openBox(_boxName);
    }
  }

  /// [ValueListenableBuilder] ile kullanım için Hive Listenable döndürür.
  /// [init] çağrıldıktan sonra kullanılabilir.
  ValueListenable<Box> listenable() => _openBox.listenable();

  Box get _openBox {
    assert(_box != null && _box!.isOpen, 'NoteRepository.init() must be called first');
    return _box!;
  }

  // ─── Okuma ───────────────────────────────────────────────────────────────

  /// Tüm notları güncelleme tarihine göre sıralı döndürür.
  List<NoteModel> getAllNotes() {
    if (_box == null || !_box!.isOpen) return [];

    return _openBox.values
        .whereType<Map>()
        .map((raw) => NoteModel.fromMap(Map<String, dynamic>.from(raw)))
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  /// ID'ye göre tek not getirir. Bulunamazsa null döner.
  NoteModel? getNoteById(String id) {
    if (_box == null || !_box!.isOpen) return null;

    final raw = _openBox.get(id);
    if (raw == null) return null;
    return NoteModel.fromMap(Map<String, dynamic>.from(raw as Map));
  }

  // ─── Yazma ───────────────────────────────────────────────────────────────

  /// Notu kaydeder. Yoksa oluşturur, varsa günceller (upsert).
  Future<void> saveNote(NoteModel note) async {
    await init();
    await _openBox.put(note.id, note.toMap());
  }

  /// Sadece delta ve başlık günceller; createdAt değişmez.
  Future<NoteModel> updateNote({
    required String id,
    required String deltaJson,
    String? title,
  }) async {
    await init();

    // NoteModel.empty() yeni bir ID üretir — bunun yerine sabit ID ile fallback.
    final existing = getNoteById(id) ?? NoteModel(
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

    await _openBox.put(id, updated.toMap());
    return updated;
  }

  // ─── Silme ───────────────────────────────────────────────────────────────

  /// Notu siler. Bulunamazsa sessizce geçer.
  Future<void> deleteNote(String id) async {
    await init();
    await _openBox.delete(id);
  }

  /// Tüm notları siler.
  Future<void> clearAll() async {
    await init();
    await _openBox.clear();
  }

  // ─── İstatistik ──────────────────────────────────────────────────────────

  int get noteCount => (_box == null || !_box!.isOpen) ? 0 : _openBox.length;
}
