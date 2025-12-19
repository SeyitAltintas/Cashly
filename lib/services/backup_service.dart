import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'database_helper.dart';

/// Veri Yedekleme ve Geri Yükleme Servisi
/// Hive verilerini JSON olarak dışa/içe aktarır
class BackupService {
  BackupService._();

  /// Tüm verileri JSON formatında dışa aktar
  static Future<String?> exportData(String userId) async {
    try {
      // Tüm verileri topla
      final data = {
        'version': '1.0',
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

      // Versiyon kontrolü
      if (data['version'] != '1.0') {
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

      return BackupResult(
        success: true,
        message: 'Veriler başarıyla geri yüklendi',
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
