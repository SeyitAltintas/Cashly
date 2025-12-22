import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'database_helper.dart';
import 'haptic_service.dart';
import '../features/streak/data/services/streak_service.dart';
import '../features/streak/data/models/streak_model.dart';

/// Veri Yedekleme ve Geri Yükleme Servisi
/// Hive verilerini JSON olarak dışa/içe aktarır
/// Versiyon 1.2: Seri verileri ve Haptic Kutlama ayarı eklendi
class BackupService {
  BackupService._();

  /// Tüm verileri JSON formatında dışa aktar
  static Future<String?> exportData(String userId) async {
    try {
      // Ayarları topla
      final settingsBox = await Hive.openBox('settings');
      final hapticBox = await Hive.openBox('haptic_settings');

      // Seri verilerini al
      final streakData = StreakService.getStreakData(userId);

      // Tüm verileri topla
      final data = {
        'version': '1.2',
        'exportDate': DateTime.now().toIso8601String(),
        'userId': userId,
        'data': {
          'harcamalar': DatabaseHelper.harcamalariGetir(userId),
          'gelirler': DatabaseHelper.gelirleriGetir(userId),
          'varliklar': DatabaseHelper.varliklariGetir(userId),
          'odemeYontemleri': DatabaseHelper.odemeYontemleriGetir(userId),
          'transferler': DatabaseHelper.transferleriGetir(userId),
          'butce': DatabaseHelper.butceGetir(userId),
          'varsayilanOdemeYontemi': DatabaseHelper.varsayilanOdemeYontemiGetir(
            userId,
          ),
          'kategoriler': DatabaseHelper.kategorileriGetir(userId),
          'gelirKategorileri': DatabaseHelper.gelirKategorileriGetir(userId),
          // Yeni: Seri verileri
          'streak': streakData.toMap(),
        },
        'settings': {
          // Tema ayarları
          'themeIndex': settingsBox.get('themeIndex', defaultValue: 0),
          'moneyAnimation': settingsBox.get(
            'moneyAnimation',
            defaultValue: true,
          ),
          // Haptic ayarları
          'hapticMasterEnabled': hapticBox.get(
            HapticService.keyMasterEnabled,
            defaultValue: true,
          ),
          'hapticButtonTaps': hapticBox.get(
            HapticService.keyButtonTaps,
            defaultValue: true,
          ),
          'hapticNavigation': hapticBox.get(
            HapticService.keyNavigation,
            defaultValue: true,
          ),
          'hapticDelete': hapticBox.get(
            HapticService.keyDelete,
            defaultValue: true,
          ),
          'hapticSuccess': hapticBox.get(
            HapticService.keySuccess,
            defaultValue: true,
          ),
          'hapticError': hapticBox.get(
            HapticService.keyError,
            defaultValue: true,
          ),
          // Yeni: Haptic kutlama ayarı
          'hapticCelebration': hapticBox.get(
            HapticService.keyCelebration,
            defaultValue: true,
          ),
        },
      };

      // JSON'a çevir
      final jsonString = const JsonEncoder.withIndent('  ').convert(data);

      // Dosyayı kaydet
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${directory.path}/cashly_backup_$timestamp.json');
      await file.writeAsString(jsonString);

      return file.path;
    } catch (e) {
      return null;
    }
  }

  /// Yedek dosyasını paylaş
  static Future<void> shareBackup(String filePath) async {
    // ignore: deprecated_member_use
    await Share.shareXFiles([XFile(filePath)], subject: 'Cashly Yedek');
  }

  /// JSON dosyasından verileri geri yükle
  static Future<BackupResult> importData(String userId) async {
    try {
      // Dosya seç
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.isEmpty) {
        return BackupResult(success: false, message: 'Dosya seçilmedi');
      }

      final file = File(result.files.single.path!);
      final jsonString = await file.readAsString();
      final data = jsonDecode(jsonString) as Map<String, dynamic>;

      // Versiyon kontrolü (1.0, 1.1 ve 1.2 desteklenir)
      final version = data['version'] as String?;
      if (version != '1.0' && version != '1.1' && version != '1.2') {
        return BackupResult(
          success: false,
          message: 'Desteklenmeyen yedek versiyonu',
        );
      }

      final backupData = data['data'] as Map<String, dynamic>;

      // Verileri geri yükle
      if (backupData['harcamalar'] != null) {
        DatabaseHelper.harcamalariKaydet(
          userId,
          List<Map<String, dynamic>>.from(backupData['harcamalar']),
        );
      }

      if (backupData['gelirler'] != null) {
        DatabaseHelper.gelirleriKaydet(
          userId,
          List<Map<String, dynamic>>.from(backupData['gelirler']),
        );
      }

      if (backupData['varliklar'] != null) {
        DatabaseHelper.varliklariKaydet(
          userId,
          List<Map<String, dynamic>>.from(backupData['varliklar']),
        );
      }

      if (backupData['odemeYontemleri'] != null) {
        DatabaseHelper.odemeYontemleriKaydet(
          userId,
          List<Map<String, dynamic>>.from(backupData['odemeYontemleri']),
        );
      }

      if (backupData['transferler'] != null) {
        DatabaseHelper.transferleriKaydet(
          userId,
          List<Map<String, dynamic>>.from(backupData['transferler']),
        );
      }

      if (backupData['butce'] != null) {
        DatabaseHelper.butceKaydet(
          userId,
          (backupData['butce'] as num).toDouble(),
        );
      }

      if (backupData['varsayilanOdemeYontemi'] != null) {
        DatabaseHelper.varsayilanOdemeYontemiKaydet(
          userId,
          backupData['varsayilanOdemeYontemi'] as String,
        );
      }

      if (backupData['kategoriler'] != null) {
        DatabaseHelper.kategorileriKaydet(
          userId,
          List<Map<String, dynamic>>.from(
            (backupData['kategoriler'] as List).map(
              (e) => Map<String, dynamic>.from(e),
            ),
          ),
        );
      }

      if (backupData['gelirKategorileri'] != null) {
        DatabaseHelper.gelirKategorileriKaydet(
          userId,
          List<Map<String, dynamic>>.from(
            (backupData['gelirKategorileri'] as List).map(
              (e) => Map<String, dynamic>.from(e),
            ),
          ),
        );
      }

      // Seri verilerini geri yükle (v1.2)
      if (backupData['streak'] != null) {
        final streakMap = Map<String, dynamic>.from(backupData['streak']);
        final streakData = StreakData.fromMap(streakMap);
        await StreakService.saveStreakData(userId, streakData);
      }

      // Ayarları geri yükle (v1.1+)
      if (data['settings'] != null) {
        final settings = data['settings'] as Map<String, dynamic>;

        // Tema ayarları
        final settingsBox = await Hive.openBox('settings');
        if (settings['themeIndex'] != null) {
          await settingsBox.put('themeIndex', settings['themeIndex']);
        }
        if (settings['moneyAnimation'] != null) {
          await settingsBox.put('moneyAnimation', settings['moneyAnimation']);
        }

        // Haptic ayarları
        if (settings['hapticMasterEnabled'] != null) {
          await HapticService.setSetting(
            HapticService.keyMasterEnabled,
            settings['hapticMasterEnabled'],
          );
        }
        if (settings['hapticButtonTaps'] != null) {
          await HapticService.setSetting(
            HapticService.keyButtonTaps,
            settings['hapticButtonTaps'],
          );
        }
        if (settings['hapticNavigation'] != null) {
          await HapticService.setSetting(
            HapticService.keyNavigation,
            settings['hapticNavigation'],
          );
        }
        if (settings['hapticDelete'] != null) {
          await HapticService.setSetting(
            HapticService.keyDelete,
            settings['hapticDelete'],
          );
        }
        if (settings['hapticSuccess'] != null) {
          await HapticService.setSetting(
            HapticService.keySuccess,
            settings['hapticSuccess'],
          );
        }
        if (settings['hapticError'] != null) {
          await HapticService.setSetting(
            HapticService.keyError,
            settings['hapticError'],
          );
        }
        // Haptic kutlama ayarı (v1.2)
        if (settings['hapticCelebration'] != null) {
          await HapticService.setSetting(
            HapticService.keyCelebration,
            settings['hapticCelebration'],
          );
        }
      }

      return BackupResult(
        success: true,
        message: 'Veriler ve ayarlar başarıyla geri yüklendi',
      );
    } catch (e) {
      return BackupResult(success: false, message: 'Geri yükleme hatası: $e');
    }
  }
}

/// Yedekleme işlemi sonucu
class BackupResult {
  final bool success;
  final String message;

  BackupResult({required this.success, required this.message});
}
