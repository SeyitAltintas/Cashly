/// Migrasyon flag'leri
/// Hive → Firestore geçişinin durumunu takip eder
library;
import 'package:hive_flutter/hive_flutter.dart';

class MigrationFlags {
  static const String _boxName = 'migration_flags';

  static Future<bool> isMigrationComplete() async {
    final box = await Hive.openBox(_boxName);
    return box.get('firestore_migration_complete', defaultValue: false);
  }

  static Future<void> markMigrationComplete() async {
    final box = await Hive.openBox(_boxName);
    await box.put('firestore_migration_complete', true);
    await box.put('migration_date', DateTime.now().toIso8601String());
  }

  static Future<bool> get useFirestore async => await isMigrationComplete();
}
