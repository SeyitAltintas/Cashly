import 'dart:convert';
import 'dart:ui';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../di/injection_container.dart';
import '../../features/expenses/domain/repositories/expense_repository.dart';
import '../../features/income/domain/repositories/income_repository.dart';
import '../../features/assets/domain/repositories/asset_repository.dart';
import '../../features/payment_methods/domain/repositories/payment_method_repository.dart';
import '../../features/payment_methods/data/repositories/payment_method_repository_impl.dart';
import '../../features/streak/domain/repositories/streak_repository.dart';
import 'haptic_service.dart';
import '../../features/streak/data/services/streak_service.dart';
import '../../features/streak/data/models/streak_model.dart';

/// Veri Yedekleme ve Geri Yükleme Servisi
/// Hive verilerini JSON olarak dışa/içe aktarır
/// Versiyon 1.3: Transfer modelinde yeni alanlar (isScheduled, isExecuted, isFailed) eklendi
class BackupService {
  BackupService._();

  /// Tüm verileri JSON formatında dışa aktar
  static Future<String?> exportData(String userId) async {
    try {
      // Repository'leri al
      final expenseRepo = getIt<ExpenseRepository>();
      final incomeRepo = getIt<IncomeRepository>();
      final assetRepo = getIt<AssetRepository>();
      final paymentRepo = getIt<PaymentMethodRepository>();
      final streakRepo = getIt<StreakRepository>();

      // Ayarları topla
      final settingsBox = await Hive.openBox('settings');
      final hapticBox = await Hive.openBox('haptic_settings');

      // Seri verilerini al
      final streakData = streakRepo.getStreakData(userId);

      // Tüm verileri topla
      final data = {
        'version': '1.3',
        'exportDate': DateTime.now().toIso8601String(),
        'userId': userId,
        'data': {
          'harcamalar': expenseRepo.getExpenses(userId),
          'gelirler': incomeRepo.getIncomes(userId),
          'varliklar': assetRepo.getAssets(userId),
          'odemeYontemleri': paymentRepo.getPaymentMethods(userId),
          'transferler': paymentRepo.getTransfers(userId),
          'butce': expenseRepo.getBudget(userId),
          'varsayilanOdemeYontemi': paymentRepo.getDefaultPaymentMethod(userId),
          'kategoriler': expenseRepo.getCategories(userId),
          'kategoriButceleri': expenseRepo.getCategoryBudgets(userId),
          'gelirKategorileri': incomeRepo.getCategories(userId),
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
  /// Paylaşım sonucunu döndürür (başarı/iptal kontrolü için)
  static Future<ShareResult> shareBackup(String filePath) async {
    // ignore: deprecated_member_use
    return await Share.shareXFiles([XFile(filePath)], subject: 'Cashly Yedek');
  }

  /// JSON dosyasından verileri geri yükle
  /// [onFileSelected] callback'i dosya seçildikten sonra çağrılır (loading göstermek için)
  static Future<BackupResult> importData(
    String userId, {
    VoidCallback? onFileSelected,
  }) async {
    try {
      // Dosya seç - withData:true ile bytes da alınır (Android için)
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        withData: true, // Android'de bytes alabilmek için
      );

      if (result == null || result.files.isEmpty) {
        return BackupResult(success: false, message: 'Dosya seçilmedi');
      }

      // Dosya seçildi, loading göster
      onFileSelected?.call();

      final pickedFile = result.files.single;
      String jsonString;

      // Önce path ile dene, yoksa bytes kullan
      if (pickedFile.path != null) {
        final file = File(pickedFile.path!);
        jsonString = await file.readAsString();
      } else if (pickedFile.bytes != null) {
        jsonString = String.fromCharCodes(pickedFile.bytes!);
      } else {
        return BackupResult(success: false, message: 'Dosya okunamadı');
      }

      final data = jsonDecode(jsonString) as Map<String, dynamic>;

      // Versiyon kontrolü (1.0, 1.1 ve 1.2 desteklenir)
      final version = data['version'] as String?;
      if (version != '1.0' &&
          version != '1.1' &&
          version != '1.2' &&
          version != '1.3') {
        return BackupResult(
          success: false,
          message: 'Desteklenmeyen yedek versiyonu',
        );
      }

      final backupData = data['data'] as Map<String, dynamic>;

      // Repository'leri al
      final expenseRepo = getIt<ExpenseRepository>();
      final incomeRepo = getIt<IncomeRepository>();
      final assetRepo = getIt<AssetRepository>();
      final paymentRepo = getIt<PaymentMethodRepository>();
      final streakRepo = getIt<StreakRepository>();

      // Verileri geri yükle
      if (backupData['harcamalar'] != null) {
        await expenseRepo.saveExpenses(
          userId,
          List<Map<String, dynamic>>.from(backupData['harcamalar']),
        );
      }

      if (backupData['gelirler'] != null) {
        await incomeRepo.saveIncomes(
          userId,
          List<Map<String, dynamic>>.from(backupData['gelirler']),
        );
      }

      if (backupData['varliklar'] != null) {
        await assetRepo.saveAssets(
          userId,
          List<Map<String, dynamic>>.from(backupData['varliklar']),
        );
      }

      if (backupData['odemeYontemleri'] != null) {
        await paymentRepo.savePaymentMethods(
          userId,
          List<Map<String, dynamic>>.from(backupData['odemeYontemleri']),
        );
      }

      if (backupData['transferler'] != null) {
        await paymentRepo.saveTransfers(
          userId,
          List<Map<String, dynamic>>.from(backupData['transferler']),
        );
      }

      if (backupData['butce'] != null) {
        await expenseRepo.saveBudget(
          userId,
          (backupData['butce'] as num).toDouble(),
        );
      }

      if (backupData['varsayilanOdemeYontemi'] != null) {
        await paymentRepo.saveDefaultPaymentMethod(
          userId,
          backupData['varsayilanOdemeYontemi'] as String,
        );
      }

      if (backupData['kategoriler'] != null) {
        await expenseRepo.saveCategories(
          userId,
          List<Map<String, dynamic>>.from(
            (backupData['kategoriler'] as List).map(
              (e) => Map<String, dynamic>.from(e),
            ),
          ),
        );
      }

      if (backupData['gelirKategorileri'] != null) {
        await incomeRepo.saveCategories(
          userId,
          List<Map<String, dynamic>>.from(
            (backupData['gelirKategorileri'] as List).map(
              (e) => Map<String, dynamic>.from(e),
            ),
          ),
        );
      }

      // Kategori bütçelerini geri yükle (v1.4)
      if (backupData['kategoriButceleri'] != null) {
        final budgetMap = Map<String, dynamic>.from(
          backupData['kategoriButceleri'],
        );
        final categoryBudgets = budgetMap.map(
          (key, value) => MapEntry(key, (value as num).toDouble()),
        );
        await expenseRepo.saveCategoryBudgets(userId, categoryBudgets);
      }

      // Seri verilerini geri yükle (v1.2)
      if (backupData['streak'] != null) {
        // Streak box'ının açık olduğundan emin ol
        await StreakService.initialize();
        final streakMap = Map<String, dynamic>.from(backupData['streak']);
        final streakData = StreakData.fromMap(streakMap);

        // lastLoginDate'i bugüne güncelle ki uygulama açıldığında
        // checkAndUpdateStreak seriyi sıfırlamasın
        final today = DateTime.now();
        final todayString =
            '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

        final updatedStreakData = streakData.copyWith(
          lastLoginDate: todayString,
        );

        await streakRepo.saveStreakData(userId, updatedStreakData);
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

  /// Tüm kullanıcı verilerini sil
  static Future<bool> deleteAllData(String userId) async {
    try {
      // Repository'leri al
      final expenseRepo = getIt<ExpenseRepository>();
      final incomeRepo = getIt<IncomeRepository>();
      final assetRepo = getIt<AssetRepository>();
      final paymentRepo = getIt<PaymentMethodRepository>();
      final streakRepo = getIt<StreakRepository>();

      // Tüm verileri temizle
      await expenseRepo.saveExpenses(userId, []);
      await incomeRepo.saveIncomes(userId, []);
      await assetRepo.saveAssets(userId, []);
      // Ödeme yöntemlerini sıfırla ama varsayılan Nakit'i koru
      await paymentRepo.savePaymentMethods(
        userId,
        PaymentMethodRepositoryImpl.defaultPaymentMethods,
      );
      await paymentRepo.saveTransfers(userId, []);
      await expenseRepo.saveBudget(userId, 0);
      // Varsayılan ödeme yöntemi olarak Nakit seçili olsun
      await paymentRepo.saveDefaultPaymentMethod(userId, 'nakit_default');

      // Streak verilerini sıfırla
      await StreakService.initialize();
      await streakRepo.saveStreakData(userId, StreakData.empty());

      return true;
    } catch (e) {
      return false;
    }
  }
}

/// Yedekleme işlemi sonucu
class BackupResult {
  final bool success;
  final String message;

  BackupResult({required this.success, required this.message});
}
