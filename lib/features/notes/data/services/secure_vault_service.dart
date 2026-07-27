import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/painting.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:crypto/crypto.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/note_model.dart';
import 'note_text_utils.dart';
import 'note_media_service.dart';

// ─── Arka Plan (Isolate) Şifreleme Metotları ──────────────────────────────
// compute() ile isolate'te çalıştırılabilmek için top-level olmalıdır.

String _generateSaltSync(dynamic _) => BCrypt.gensalt();

List<int> _deriveKeySync(Map<String, String> args) {
  final hashedPin = BCrypt.hashpw(args['pin']!, args['salt']!);
  return sha256.convert(utf8.encode(hashedPin)).bytes;
}

/// PIN, AES şifreleme ve biyometrik kimlik doğrulama işlemlerini yönetir.
///
/// Public index kutusuna (PIN hash depolama) erişmek için constructor üzerinden
/// bir getter alır. Bu tasarım, NoteLocalDataSource'a import bağımlılığı
/// olmaksızın Facade tarafından iki servisin bağlanmasını sağlar.
class SecureVaultService {
  /// Public index box'a erişim getter'ı.
  /// Facade'ın `NoteLocalDataSource.requireIndexBox`'ını buraya bağlar.
  final Box Function() _indexBoxGetter;

  /// Kullanıcı kimliğine erişim getter'ı.
  final String Function() _userIdGetter;

  SecureVaultService({
    required Box Function() indexBoxGetter,
    required String Function() userIdGetter,
  })  : _indexBoxGetter = indexBoxGetter,
        _userIdGetter = userIdGetter;

  Box? _secureIndexBox;
  LazyBox? _secureLazyDataBox;
  LazyBox? _secureMediaBox;

  // 🎭 SAHTE KASA (DECOY VAULT) FLAG
  bool _isDecoyVaultActive = false;
  bool _isMigratingPin = false;

  bool hasUnsavedSecureNote = false;

  final LocalAuthentication _auth = LocalAuthentication();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  String get _secureIndexBoxName =>
      'secure_notes_index_${_userIdGetter()}';
  String get _secureDataBoxName => 'secure_notes_data_${_userIdGetter()}';
  String get _secureMediaBoxName => 'secure_media_box_${_userIdGetter()}';

  bool get isDecoyVaultActive => _isDecoyVaultActive;
  bool get isMigratingPin => _isMigratingPin;
  bool get isUnlocked => _secureIndexBox != null && _secureIndexBox!.isOpen;

  /// Medya migrasyon işlemleri için Facade tarafından erişilir.
  LazyBox get secureMediaBox {
    assert(isUnlocked, 'Secure vault must be unlocked to access secureMediaBox');
    return _secureMediaBox!;
  }

  Box get _requireIndex => _indexBoxGetter();

  // ─── PIN Durumu ───────────────────────────────────────────────────────────

  bool get hasSecurePin =>
      _requireIndex.get('has_secure_pin', defaultValue: false) as bool;

  bool get hasDecoyPin =>
      _requireIndex.get('has_decoy_pin', defaultValue: false) as bool;

  // ─── PIN Doğrulama (UI Katmanı İçin) ─────────────────────────────────────

  Future<bool> verifyMainPin(String pin) async {
    final salt = _requireIndex.get('secure_pin_salt') as String?;
    if (salt == null) return false;
    final key = await compute(_deriveKeySync, {'pin': pin, 'salt': salt});
    final computedHash = sha256.convert(key).toString();
    final storedHash = _requireIndex.get('secure_pin_hash') as String?;
    return computedHash == storedHash;
  }

  Future<bool> verifyDecoyPin(String pin) async {
    final salt = _requireIndex.get('decoy_pin_salt') as String?;
    if (salt == null) return false;
    final key = await compute(_deriveKeySync, {'pin': pin, 'salt': salt});
    final computedHash = sha256.convert(key).toString();
    final storedHash = _requireIndex.get('decoy_pin_hash') as String?;
    return computedHash == storedHash;
  }

  // ─── PIN Yönetimi ─────────────────────────────────────────────────────────

  Future<void> setSecurePin(String pin) async {
    final salt = await compute(_generateSaltSync, null);
    await _requireIndex.put('secure_pin_salt', salt);
    final key = await compute(_deriveKeySync, {'pin': pin, 'salt': salt});
    await _requireIndex.put(
        'secure_pin_hash', sha256.convert(key).toString());
    final success = await unlockSecureNotes(pin);
    if (success) await _requireIndex.put('has_secure_pin', true);
  }

  // 🎭 Sahte Kasa PIN Ayarlama
  Future<void> setDecoyPin(String pin) async {
    // EC-27: Eski veya bozuk verileri temizle
    await Hive.deleteBoxFromDisk('sys_cache_index_${_userIdGetter()}');
    await Hive.deleteBoxFromDisk('sys_cache_data_${_userIdGetter()}');
    await Hive.deleteBoxFromDisk('sys_cache_media_${_userIdGetter()}');

    final salt = await compute(_generateSaltSync, null);
    await _requireIndex.put('decoy_pin_salt', salt);
    final key = await compute(_deriveKeySync, {'pin': pin, 'salt': salt});
    await _requireIndex.put(
        'decoy_pin_hash', sha256.convert(key).toString());
    await _requireIndex.put('has_decoy_pin', true);
  }

  // 🎭 Sahte Kasa İptali
  Future<void> removeDecoyPin() async {
    await _requireIndex.delete('has_decoy_pin');
    await _requireIndex.delete('decoy_pin_salt');
    await _requireIndex.delete('decoy_pin_hash');
    // EC-27: Sahte kasa dosyaları 'sys_cache' adıyla gizlendi
    await Hive.deleteBoxFromDisk('sys_cache_index_${_userIdGetter()}');
    await Hive.deleteBoxFromDisk('sys_cache_data_${_userIdGetter()}');
    await Hive.deleteBoxFromDisk('sys_cache_media_${_userIdGetter()}');
  }

  // ─── Kilit Açma ───────────────────────────────────────────────────────────

  Future<bool> unlockSecureNotes(String pin) async {
    try {
      final salt = _requireIndex.get('secure_pin_salt') as String?;
      List<int>? key;
      bool isDecoyMatched = false;

      // 1. Ana Kasa PIN'ini kontrol et
      if (salt != null) {
        key = await compute(_deriveKeySync, {'pin': pin, 'salt': salt});
      } else {
        key = sha256.convert(utf8.encode(pin)).bytes;
      }

      final storedHash = _requireIndex.get('secure_pin_hash') as String?;
      bool isMainMatched = false;
      if (storedHash != null && key != null) {
        if (sha256.convert(key).toString() == storedHash) {
          isMainMatched = true;
        }
      }

      // 2. Ana Kasa eşleşmediyse ve Sahte Kasa varsa kontrol et
      if (!isMainMatched && hasDecoyPin) {
        final decoySalt = _requireIndex.get('decoy_pin_salt') as String?;
        if (decoySalt != null) {
          final decoyKey = await compute(_deriveKeySync, {
            'pin': pin,
            'salt': decoySalt,
          });
          final storedDecoyHash = _requireIndex.get('decoy_pin_hash') as String?;
          if (storedDecoyHash != null) {
            if (sha256.convert(decoyKey).toString() == storedDecoyHash) {
              isDecoyMatched = true;
              key = decoyKey;
            }
          }
        }
      }

      // 3. İkisi de eşleşmediyse reddet
      if (!isMainMatched && !isDecoyMatched) return false;

      // 4. Flag ayarla
      _isDecoyVaultActive = isDecoyMatched;

      // 5. EC-27: Kamufle edilmiş dosya isimleri
      final indexName = isDecoyMatched
          ? 'sys_cache_index_${_userIdGetter()}'
          : _secureIndexBoxName;
      final dataName = isDecoyMatched
          ? 'sys_cache_data_${_userIdGetter()}'
          : _secureDataBoxName;
      final mediaName = isDecoyMatched
          ? 'sys_cache_media_${_userIdGetter()}'
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

      // --- ATOMIC MIGRATION RECOVERY --- (Sadece ana kasa için)
      if (!isDecoyMatched) {
        final isPendingMigration =
            _requireIndex.get('pending_migration', defaultValue: false) as bool;
        if (isPendingMigration) {
          final tempIndexBox = await Hive.openBox(
            'temp_new_index_${_userIdGetter()}',
            encryptionCipher: HiveAesCipher(key),
          );
          final tempLazyBox = await Hive.openLazyBox(
            'temp_new_data_${_userIdGetter()}',
            encryptionCipher: HiveAesCipher(key),
          );
          final tempMediaBox = await Hive.openLazyBox(
            'temp_new_media_${_userIdGetter()}',
            encryptionCipher: HiveAesCipher(key),
          );

          await _secureIndexBox!.putAll(tempIndexBox.toMap());
          for (final k in tempLazyBox.keys) {
            final val = await tempLazyBox.get(k);
            if (val != null) await _secureLazyDataBox!.put(k, val);
          }
          for (final k in tempMediaBox.keys) {
            final val = await tempMediaBox.get(k);
            if (val != null) await _secureMediaBox!.put(k, val);
          }

          await tempIndexBox.close();
          await tempLazyBox.close();
          await tempMediaBox.close();

          await Hive.deleteBoxFromDisk('temp_new_index_${_userIdGetter()}');
          await Hive.deleteBoxFromDisk('temp_new_data_${_userIdGetter()}');
          await Hive.deleteBoxFromDisk('temp_new_media_${_userIdGetter()}');
          await _requireIndex.put('pending_migration', false);
        }
      }
      // ---------------------------------

      if (!isDecoyMatched && storedHash == null) {
        await _requireIndex.put(
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

      // EC-26: Arka planda yetim şifreli medyaları temizle
      cleanOrphanSecureMedia();

      return true;
    } catch (e) {
      debugPrint('Unlock secure notes error: $e');
      await closeSecureNotes();
      return false;
    }
  }

  Future<void> closeSecureNotes({bool force = false}) async {
    if (_isMigratingPin && !force) return;

    // EC-RACE: Kilitlenmeden önce kaydedilmemiş not varsa bekle
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

    _isDecoyVaultActive = false;

    // Pano Sızıntısını Önle (Native Android Wipe)
    try {
      const platform = MethodChannel('com.seyitaltintas.cashly/security');
      await platform.invokeMethod('clearClipboard');
    } catch (_) {}

    // RAM Sızıntısını Önle: Şifresi çözülmüş resimleri önbellekten temizle
    try {
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();
    } catch (_) {}
  }

  /// GÜVENLİK: PIN unutulursa sistemi sıfırlar (veriler geri getirilemez).
  Future<void> resetSecureKasa() async {
    await closeSecureNotes(force: true);
    await Hive.deleteBoxFromDisk(_secureIndexBoxName);
    await Hive.deleteBoxFromDisk(_secureDataBoxName);
    await Hive.deleteBoxFromDisk(_secureMediaBoxName);
    await removeDecoyPin();
    await _requireIndex.delete('has_secure_pin');
    await _requireIndex.delete('secure_pin_salt');
    await _requireIndex.delete('secure_pin_hash');
    await disableBiometric();
    await disableAutoUnlock();
  }

  /// clearAll() ile çağrılır; tüm şifreli Hive dosyalarını diskten siler.
  Future<void> deleteAllBoxesFromDisk() async {
    await closeSecureNotes(force: true);
    await Hive.deleteBoxFromDisk(_secureIndexBoxName);
    await Hive.deleteBoxFromDisk(_secureDataBoxName);
    await Hive.deleteBoxFromDisk(_secureMediaBoxName);
    // EC-27: Decoy orphan veri sızıntısını engelle
    await Hive.deleteBoxFromDisk('sys_cache_index_${_userIdGetter()}');
    await Hive.deleteBoxFromDisk('sys_cache_data_${_userIdGetter()}');
    await Hive.deleteBoxFromDisk('sys_cache_media_${_userIdGetter()}');
  }

  // ─── PIN Değiştirme (Atomic Migration) ───────────────────────────────────

  Future<bool> changeSecurePin(String currentPin, String newPin) async {
    if (!isUnlocked) return false;

    // GÜVENLİK: Sahte kasa modundayken şifre değiştirilemez.
    if (_isDecoyVaultActive) {
      throw Exception('Sahte kasa modundayken şifre değiştirilemez.');
    }

    _isMigratingPin = true;
    try {
      // 1. Yeni AES key oluştur
      final newSalt = await compute(_generateSaltSync, null);
      final newKey = await compute(_deriveKeySync, {
        'pin': newPin,
        'salt': newSalt,
      });

      // 2. Yeni şifreli geçici kutular aç (Backup)
      final tempIndexBox = await Hive.openBox(
        'temp_new_index_${_userIdGetter()}',
        encryptionCipher: HiveAesCipher(newKey),
      );
      final tempLazyBox = await Hive.openLazyBox(
        'temp_new_data_${_userIdGetter()}',
        encryptionCipher: HiveAesCipher(newKey),
      );
      final tempMediaBox = await Hive.openLazyBox(
        'temp_new_media_${_userIdGetter()}',
        encryptionCipher: HiveAesCipher(newKey),
      );

      // 3. Mevcut verileri geçici kutulara kopyala
      await tempIndexBox.putAll(_secureIndexBox!.toMap());
      for (final k in _secureLazyDataBox!.keys) {
        final val = await _secureLazyDataBox!.get(k);
        if (val != null) await tempLazyBox.put(k, val);
      }
      for (final k in _secureMediaBox!.keys) {
        final val = await _secureMediaBox!.get(k);
        if (val != null) await tempMediaBox.put(k, val);
      }

      // 4. Geçici kutular diske mühürlendi — buraya kadar veri kayıpsız
      await tempIndexBox.close();
      await tempLazyBox.close();
      await tempMediaBox.close();

      // 5. Atomic Checkpoint
      await _requireIndex.put('secure_pin_salt', newSalt);
      await _requireIndex.put(
          'secure_pin_hash', sha256.convert(newKey).toString());
      await _requireIndex.put('pending_migration', true);

      // 6. Eski kasayı yok et
      await closeSecureNotes(force: true);
      await Hive.deleteBoxFromDisk(_secureIndexBoxName);
      await Hive.deleteBoxFromDisk(_secureDataBoxName);
      await Hive.deleteBoxFromDisk(_secureMediaBoxName);
      await disableBiometric();
      await disableAutoUnlock();

      // 7. Yeni PIN ile kilidi aç (pending_migration'ı görüp verileri aktarır)
      final success = await unlockSecureNotes(newPin);
      if (!success) throw Exception('Yeni kasa açılamadı.');
      await _requireIndex.put('has_secure_pin', true);

      return true;
    } catch (e) {
      debugPrint('PIN Migration failed: $e');
      final isPending =
          _requireIndex.get('pending_migration', defaultValue: false) as bool;
      if (!isPending) {
        try {
          await Hive.deleteBoxFromDisk('temp_new_index_${_userIdGetter()}');
          await Hive.deleteBoxFromDisk('temp_new_data_${_userIdGetter()}');
          await Hive.deleteBoxFromDisk('temp_new_media_${_userIdGetter()}');
        } catch (_) {}
      }
      return false;
    } finally {
      _isMigratingPin = false;
    }
  }

  // ─── Auto-Unlock ──────────────────────────────────────────────────────────

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
    if (pin != null) return await unlockSecureNotes(pin);
    return false;
  }

  // ─── Biyometrik ──────────────────────────────────────────────────────────

  Future<bool> canUseBiometrics() async {
    final canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
    return canAuthenticateWithBiometrics || await _auth.isDeviceSupported();
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
    if (!await canUseBiometrics()) return false;
    try {
      final authenticated = await _auth.authenticate(
        localizedReason: localizedReason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
      if (authenticated) {
        final pin = await _secureStorage.read(key: 'secure_vault_pin');
        if (pin != null) return await unlockSecureNotes(pin);
      }
      return false;
    } catch (e) {
      debugPrint('Biometric unlock error: $e');
      return false;
    }
  }

  // ─── Güvenli Medya ───────────────────────────────────────────────────────

  Future<String> saveSecureMedia(Uint8List bytes, String extension) async {
    if (!isUnlocked) throw Exception('Secure notes locked');
    return NoteMediaService.saveSecureMedia(
      secureMediaBox: _secureMediaBox!,
      bytes: bytes,
      extension: extension,
    );
  }

  Future<Uint8List?> getSecureMedia(String id) async {
    if (!isUnlocked) return null;
    return NoteMediaService.getSecureMedia(
      secureMediaBox: _secureMediaBox!,
      id: id,
    );
  }

  /// GÜVENLİK: Kasa açıldığında arka planda yetim medyaları temizler (EC-26).
  Future<void> cleanOrphanSecureMedia() async {
    if (!isUnlocked) return;
    await NoteMediaService.cleanOrphanSecureMedia(
      secureLazyDataBox: _secureLazyDataBox!,
      secureMediaBox: _secureMediaBox!,
    );
  }

  // ─── Güvenli Not CRUD ─────────────────────────────────────────────────────

  Stream<BoxEvent>? watchSecure() => _secureIndexBox?.watch();

  List<NoteModel> getSecureNotes() {
    if (!isUnlocked) return [];
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
    if (!isUnlocked) return null;
    try {
      final raw = _secureIndexBox!.get(id);
      if (raw == null || raw is! Map) return null;
      return NoteModel.fromMap(Map<String, dynamic>.from(raw));
    } catch (_) {
      return null;
    }
  }

  Future<String> getSecureNoteDeltaJson(String id) async {
    if (!isUnlocked) return '[]';
    final data = await _secureLazyDataBox!.get(id);
    return data as String? ?? '[]';
  }

  Future<void> saveSecureNote(NoteModel note) async {
    if (!isUnlocked) throw StateError('Secure notes are locked.');
    await _secureLazyDataBox!.put(
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
    await _secureIndexBox!.put(note.id, indexNote.toMap());
  }

  Future<void> deleteSecureNotes(List<String> ids) async {
    if (!isUnlocked) return;
    await permanentlyDeleteSecureNotes(ids);
  }

  /// Orphan temizleme çalıştırmadan sadece index ve data kutusundan siler.
  /// Facade'daki `unsecureNotes` gibi batch taşımalarda kullanılır;
  /// doğrulama sonrasında tek seferlik cleanup yapılır.
  Future<void> deleteSecureNoteEntries(List<String> ids) async {
    if (!isUnlocked) return;
    await _secureIndexBox!.deleteAll(ids);
    await _secureLazyDataBox!.deleteAll(ids);
  }

  Future<void> permanentlyDeleteSecureNotes(List<String> ids) async {
    if (!isUnlocked) return;
    await _secureIndexBox!.deleteAll(ids);
    await _secureLazyDataBox!.deleteAll(ids);
    await cleanOrphanSecureMedia();
  }

  bool containsKey(String id) => _secureIndexBox?.containsKey(id) ?? false;
}
