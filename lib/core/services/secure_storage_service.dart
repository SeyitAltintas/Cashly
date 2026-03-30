import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage();
  static const _encryptionKeyName = 'hive_encryption_key';

  static Future<List<int>> getEncryptionKey() async {
    final containsEncryptionKey = await _storage.containsKey(key: _encryptionKeyName);
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
}

