import 'package:hive_flutter/hive_flutter.dart';

/// Hive veritabanını test ortamında mocklama için yardımcı sınıf
class MockHive {
  static bool _initialized = false;

  /// Test ortamı için Hive'ı başlatır
  static Future<void> init() async {
    if (_initialized) return;

    await Hive.initFlutter();
    _initialized = true;
  }

  /// Test sonrası temizlik
  static Future<void> cleanup() async {
    await Hive.deleteFromDisk();
    _initialized = false;
  }

  /// Belirli bir kutuyu temizler
  static Future<void> clearBox(String boxName) async {
    if (Hive.isBoxOpen(boxName)) {
      final box = Hive.box(boxName);
      await box.clear();
    }
  }
}
