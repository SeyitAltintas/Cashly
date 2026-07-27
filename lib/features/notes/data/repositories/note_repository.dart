import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/note_model.dart';
import '../services/note_local_data_source.dart';
import '../services/note_media_service.dart';
import '../services/note_text_utils.dart';
import '../services/secure_vault_service.dart';

/// Not sisteminin dış API'si (Facade).
///
/// Tüm iş mantığı şu servislere dağıtılmıştır:
/// - [NoteLocalDataSource] — Public Hive CRUD
/// - [SecureVaultService]  — PIN, AES, Sahte Kasa, Biyometrik
/// - [NoteMediaService]    — Medya migrasyon ve orphan temizleme
///
/// Dış dünya (UI, DI container) yalnızca bu sınıfı bilir; servislere
/// doğrudan erişilmez.
class NoteRepository {
  static final NoteRepository _instance = NoteRepository._internal();
  factory NoteRepository() => _instance;

  NoteRepository._internal() {
    _vault = SecureVaultService(
      indexBoxGetter: () => _dataSource.requireIndexBox,
      userIdGetter: () => _dataSource.currentUserId,
    );
  }

  final NoteLocalDataSource _dataSource = NoteLocalDataSource();
  late final SecureVaultService _vault;

  // ─── Genel ───────────────────────────────────────────────────────────────

  /// GÜVENLİK (EDGE CASE): Kamera/Galeri açıkken otomatik kilidi engeller.
  bool get isMediaPicking => _dataSource.isMediaPicking;
  set isMediaPicking(bool value) => _dataSource.isMediaPicking = value;

  Future<void> init() => _dataSource.init();

  Future<void> closeAll() async {
    await _vault.closeSecureNotes(force: true);
    await _dataSource.closeAll();
  }

  ValueListenable<Box> listenable() => _dataSource.listenable();
  Stream<BoxEvent> watch() => _dataSource.watch();

  // ─── Kullanıcı Tercihleri ─────────────────────────────────────────────────

  bool get isGridView => _dataSource.isGridView;
  Future<void> setGridView(bool value) => _dataSource.setGridView(value);

  // ─── Okuma ────────────────────────────────────────────────────────────────

  List<NoteModel> getAllNotes() => _dataSource.getAllNotes();
  List<NoteModel> getTrashNotes() => _dataSource.getTrashNotes();
  NoteModel? getNoteById(String id) => _dataSource.getNoteById(id);
  Future<String> getNoteDeltaJson(String id) =>
      _dataSource.getNoteDeltaJson(id);
  int get noteCount => _dataSource.noteCount;

  // ─── Yazma ────────────────────────────────────────────────────────────────

  Future<void> saveNote(NoteModel note) => _dataSource.saveNote(note);

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

    // Snippet ve arama metni her zaman yeni delta'dan hesaplanır (orijinal davranış).
    final computedSnippet = extractSnippet(deltaJson);
    final computedSearch = extractSearchableText(deltaJson);

    // Güvenli not mu?
    if (isSecure || (_vault.isUnlocked && _vault.containsKey(id))) {
      var note = _vault.getSecureNoteById(id) ??
          NoteModel(
            id: id,
            title: '',
            deltaJson: '',
            isSecure: true,
            createdAt: originalCreatedAt ?? DateTime.now(),
            updatedAt: DateTime.now(),
            categoryId: null,
          );

      note = note.copyWith(
        deltaJson: deltaJson,
        title: title,
        snippet: computedSnippet,
        searchableText: computedSearch,
        updatedAt: DateTime.now(),
        color: color,
        clearColor: clearColor,
        categoryId: categoryId,
        clearCategory: clearCategory,
      );

      await _vault.saveSecureNote(note);
      return note;
    }

    // Public not
    var note = getNoteById(id) ??
        NoteModel(
          id: id,
          title: '',
          deltaJson: '',
          createdAt: originalCreatedAt ?? DateTime.now(),
          updatedAt: DateTime.now(),
          categoryId: null,
        );

    note = note.copyWith(
      deltaJson: deltaJson,
      title: title,
      snippet: computedSnippet,
      searchableText: computedSearch,
      updatedAt: DateTime.now(),
      color: color,
      clearColor: clearColor,
      categoryId: categoryId,
      clearCategory: clearCategory,
    );

    await _dataSource.saveNote(note);
    return note;
  }

  Future<void> togglePin(String id) => _dataSource.togglePin(id);

  Future<void> setPinStateForNotes(List<String> ids, bool isPinned) =>
      _dataSource.setPinStateForNotes(ids, isPinned);

  Future<void> setCategoryForNotes(List<String> ids, String? categoryId) =>
      _dataSource.setCategoryForNotes(ids, categoryId);

  Future<void> removeCategoryFromNotes(String categoryId) =>
      _dataSource.removeCategoryFromNotes(categoryId);

  // ─── Silme ────────────────────────────────────────────────────────────────

  Future<void> deleteNote(String id) async {
    await init();
    // Güvenli kasadaysa doğrudan kalıcı sil (çöp kutusuna sızmasını engelle)
    if (_vault.isUnlocked && _vault.containsKey(id)) {
      await permanentlyDeleteNote(id, isSecure: true);
      return;
    }
    // Public not: soft delete
    await _dataSource.softDeleteNote(id);
  }

  Future<void> deleteNotes(List<String> ids) async {
    await init();
    final publicIds = <String>[];
    final secureIds = <String>[];

    for (final id in ids) {
      if (_vault.isUnlocked && _vault.containsKey(id)) {
        secureIds.add(id);
      } else {
        publicIds.add(id);
      }
    }

    if (publicIds.isNotEmpty) await _dataSource.softDeleteNotes(publicIds);
    if (secureIds.isNotEmpty) {
      await permanentlyDeleteNotes(secureIds, isSecure: true);
    }
  }

  Future<void> restoreNote(String id) async {
    await init();
    await _dataSource.restoreNote(id);
  }

  Future<void> restoreNotes(List<String> ids) async {
    await init();
    await _dataSource.restoreNotes(ids);
  }

  Future<void> permanentlyDeleteNote(String id, {bool isSecure = false}) async {
    await init();
    if (isSecure) {
      await _vault.permanentlyDeleteSecureNotes([id]);
    } else {
      await _dataSource.permanentlyDeleteNote(id);
    }
  }

  Future<void> permanentlyDeleteNotes(
    List<String> ids, {
    bool isSecure = false,
  }) async {
    await init();
    if (ids.isEmpty) return;
    if (isSecure) {
      await _vault.permanentlyDeleteSecureNotes(ids);
    } else {
      await _dataSource.permanentlyDeleteNotes(ids);
    }
  }

  Future<void> emptyTrash() async {
    await init();
    await _dataSource.emptyTrash();
  }

  Future<void> cleanOldTrashNotes([int days = 30]) async {
    await init();
    await _dataSource.cleanOldTrashNotes(days);
  }

  Future<void> clearAll() async {
    await init();
    await _dataSource.clearPublicData();
    await _vault.deleteAllBoxesFromDisk();
  }

  // ─── Medya Temizleme ──────────────────────────────────────────────────────

  Future<void> cleanOrphanImages() async {
    await init(); // lazyBox assert'ini geçmek için kutu açık olmalı
    await NoteMediaService.cleanOrphanImages(_dataSource.lazyBox);
  }

  // ─── Güvenli Notlar ───────────────────────────────────────────────────────

  bool get hasSecurePin => _vault.hasSecurePin;
  bool get hasDecoyPin => _vault.hasDecoyPin;
  bool get isDecoyVaultActive => _vault.isDecoyVaultActive;
  bool get isMigratingPin => _vault.isMigratingPin;
  bool get isSecureNotesUnlocked => _vault.isUnlocked;

  bool get hasUnsavedSecureNote => _vault.hasUnsavedSecureNote;
  set hasUnsavedSecureNote(bool value) =>
      _vault.hasUnsavedSecureNote = value;

  Future<bool> verifyMainPin(String pin) => _vault.verifyMainPin(pin);
  Future<bool> verifyDecoyPin(String pin) => _vault.verifyDecoyPin(pin);

  Future<void> setSecurePin(String pin) => _vault.setSecurePin(pin);
  Future<void> setDecoyPin(String pin) => _vault.setDecoyPin(pin);
  Future<void> removeDecoyPin() => _vault.removeDecoyPin();

  Future<bool> unlockSecureNotes(String pin) =>
      _vault.unlockSecureNotes(pin);

  Future<void> closeSecureNotes({bool force = false}) =>
      _vault.closeSecureNotes(force: force);

  Future<void> resetSecureKasa() => _vault.resetSecureKasa();

  Future<bool> changeSecurePin(String currentPin, String newPin) =>
      _vault.changeSecurePin(currentPin, newPin);

  // ─── Auto-Unlock ──────────────────────────────────────────────────────────

  Future<bool> get isAutoUnlockEnabled => _vault.isAutoUnlockEnabled;
  Future<void> enableAutoUnlock(String pin) => _vault.enableAutoUnlock(pin);
  Future<void> disableAutoUnlock() => _vault.disableAutoUnlock();
  Future<bool> unlockWithAuto() => _vault.unlockWithAuto();

  // ─── Biyometrik ──────────────────────────────────────────────────────────

  Future<bool> canUseBiometrics() => _vault.canUseBiometrics();
  Future<bool> get isBiometricEnabled => _vault.isBiometricEnabled;
  Future<void> enableBiometric(String pin) => _vault.enableBiometric(pin);
  Future<void> disableBiometric() => _vault.disableBiometric();
  Future<bool> unlockWithBiometric(String localizedReason) =>
      _vault.unlockWithBiometric(localizedReason);

  // ─── Güvenli Medya ───────────────────────────────────────────────────────

  Future<String> saveSecureMedia(Uint8List bytes, String extension) =>
      _vault.saveSecureMedia(bytes, extension);

  Future<Uint8List?> getSecureMedia(String id) => _vault.getSecureMedia(id);

  // ─── Güvenli Not CRUD ─────────────────────────────────────────────────────

  Stream<BoxEvent>? watchSecure() => _vault.watchSecure();

  List<NoteModel> getSecureNotes() => _vault.getSecureNotes();
  NoteModel? getSecureNoteById(String id) => _vault.getSecureNoteById(id);

  Future<String> getSecureNoteDeltaJson(String id) =>
      _vault.getSecureNoteDeltaJson(id);

  Future<void> saveSecureNote(NoteModel note) => _vault.saveSecureNote(note);

  Future<void> deleteSecureNotes(List<String> ids) =>
      _vault.deleteSecureNotes(ids);

  Future<void> permanentlyDeleteSecureNotes(List<String> ids) =>
      _vault.permanentlyDeleteSecureNotes(ids);

  // ─── Güvenli ↔ Public Taşıma ─────────────────────────────────────────────

  /// Seçili public notları şifreli kasaya taşır.
  Future<void> secureNotes(List<String> ids) async {
    await init(); // getNoteById ve lazyBox erişimi için kutu açık olmalı
    if (!_vault.isUnlocked) throw StateError('Secure notes are locked.');
    for (final id in ids) {
      final note = _dataSource.getNoteById(id);
      if (note != null) {
        var deltaJson = await _dataSource.getNoteDeltaJson(id);
        deltaJson = await NoteMediaService.migrateMediaToSecure(
          deltaJson: deltaJson,
          secureMediaBox: _vault.secureMediaBox,
        );
        final secureNote = note.copyWith(isSecure: true, deltaJson: deltaJson);
        await _vault.saveSecureNote(secureNote);
        // Public kutulardan temiz silme (orphan cleanup tetiklenmez)
        await _dataSource.hardDeleteEntries([id]);
      }
    }
    await NoteMediaService.cleanOrphanImages(_dataSource.lazyBox);
  }

  /// Seçili güvenli notları public alana taşır.
  Future<void> unsecureNotes(List<String> ids) async {
    await init(); // saveNote ve lazyBox erişimi için kutu açık olmalı
    if (!_vault.isUnlocked) throw StateError('Secure notes are locked.');
    for (final id in ids) {
      final note = _vault.getSecureNoteById(id);
      if (note != null) {
        var deltaJson = await _vault.getSecureNoteDeltaJson(id);
        deltaJson = await NoteMediaService.migrateMediaToPublic(
          deltaJson: deltaJson,
          secureMediaBox: _vault.secureMediaBox,
        );
        final publicNote = note.copyWith(isSecure: false, deltaJson: deltaJson);
        await _dataSource.saveNote(publicNote);
        // Doğrudan box'tan sil — orphan cleanup aşağıda tek seferlik yapılır
        await _vault.deleteSecureNoteEntries([id]);
      }
    }
    // Tüm notlar taşındıktan sonra tek seferlik orphan temizleme
    await _vault.cleanOrphanSecureMedia();
  }
}
