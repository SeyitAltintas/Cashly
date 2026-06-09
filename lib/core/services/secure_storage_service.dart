import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage();
  static const _encryptionKeyName = 'hive_encryption_key';

  static Future<List<int>> getEncryptionKey() async {
    try {
      return await _getOrGenerateKey();
    } catch (e) {
      // GÜVENLİK/KARARLILIK YAMASI (Edge Case):
      // Android Keystore bozulmaları (OS güncellemesi vb.) nedeniyle FlutterSecureStorage 
      // PlatformException fırlatabilir. Bu durumda uygulama tamamen kullanılamaz hale gelir.
      try {
        await _storage.delete(key: _encryptionKeyName);
      } catch (_) {
        // Kırmızı Takım Yaması: Fail-Open Zafiyeti engellendi.
        // Hata durumunda deleteAll() çağırmak, biyometrik PIN'ler gibi diğer tüm 
        // güvenli verileri sileceği için iptal edildi.
      }
      return await _getOrGenerateKey();
    }
  }

  static Future<List<int>> _getOrGenerateKey() async {
    final containsEncryptionKey = await _storage.containsKey(
      key: _encryptionKeyName,
    );
    if (!containsEncryptionKey) {
      final key = Hive.generateSecureKey();
      await _storage.write(
        key: _encryptionKeyName,
        value: base64UrlEncode(key),
      );
    }

    final keyString = await _storage.read(key: _encryptionKeyName);
    return base64Url.decode(keyString!);
  }

  static Future<Box<E>> openSecureBox<E>(String name) async {
    final key = await getEncryptionKey();

    try {
      return await Hive.openBox<E>(name, encryptionCipher: HiveAesCipher(key));
    } catch (e) {
      // Mevcut şifresiz kutuyu şifreli açmaya çalışınca Hive hata fırlatır.
      // Development verilerini veya eski şifresiz verileri silip, güvenli kutuyu baştan açıyoruz.
      await Hive.deleteBoxFromDisk(name);
      return await Hive.openBox<E>(name, encryptionCipher: HiveAesCipher(key));
    }
  }

  static Future<void> saveBiometricPin(String userId, String pin) async {
    await _storage.write(key: 'bio_pin_$userId', value: pin);
  }

  static Future<String?> getBiometricPin(String userId) async {
    return await _storage.read(key: 'bio_pin_$userId');
  }

  static Future<void> deleteBiometricPin(String userId) async {
    await _storage.delete(key: 'bio_pin_$userId');
  }
}
