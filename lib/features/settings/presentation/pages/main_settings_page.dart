import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'dart:math';

import 'package:cashly/core/di/injection_container.dart';
import 'package:cashly/features/expenses/domain/repositories/expense_repository.dart';
import 'package:cashly/features/payment_methods/domain/repositories/payment_method_repository.dart';
import 'package:cashly/features/expenses/presentation/pages/category_management_page.dart';
import 'package:cashly/features/income/presentation/pages/income_settings_page.dart';
import 'appearance_page.dart';
import 'voice_assistant_page.dart';
import 'recurring_transactions_page.dart';
import 'haptic_settings_page.dart';
import 'package:cashly/features/payment_methods/data/models/payment_method_model.dart';

import 'package:cashly/features/auth/presentation/controllers/auth_controller.dart';
import 'package:cashly/core/utils/validators.dart';
import 'package:cashly/core/utils/error_handler.dart';

// Modüler widget'lar
import '../widgets/settings_tile.dart';
import '../widgets/expense_settings/budget_section.dart';
import '../widgets/expense_settings/recurring_expense_section.dart';
import '../widgets/expense_settings/default_payment_section.dart';
import '../widgets/expense_settings/category_section.dart';
import 'package:cashly/core/services/backup_service.dart';
import 'package:cashly/core/services/haptic_service.dart';
import 'package:cashly/features/home/presentation/pages/home_page.dart';
import 'package:share_plus/share_plus.dart';

/// Ayarlar Sayfası
class AyarlarSayfasi extends StatefulWidget {
  final AuthController authController;
  final VoidCallback? onNavigationReturn; // Alt sayfalardan dönüşte çağrılır

  const AyarlarSayfasi({
    super.key,
    required this.authController,
    this.onNavigationReturn,
  });

  @override
  State<AyarlarSayfasi> createState() => _AyarlarSayfasiState();
}

class _AyarlarSayfasiState extends State<AyarlarSayfasi> {
  bool _needsRefresh = false;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.pop(context, _needsRefresh);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Ayarlar"),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context, _needsRefresh),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Uygulama Ayarları',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),
              _buildSettingsContainer(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsContainer(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(
            context,
          ).colorScheme.onSurface.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          SettingsTile(
            icon: Icons.palette_outlined,
            iconColor: Colors.purple,
            title: 'Görünüm',
            subtitle: 'Tema ve renk ayarları',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AppearancePage()),
            ),
          ),
          const SettingsDivider(),
          SettingsTile(
            icon: Icons.vibration,
            iconColor: Colors.cyan,
            title: 'Titreşim Geri Bildirimi',
            subtitle: 'Dokunsal geri bildirim ayarları',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const HapticSettingsPage(),
              ),
            ),
          ),
          const SettingsDivider(),
          SettingsTile(
            icon: Icons.mic_outlined,
            iconColor: Colors.orange,
            title: 'Sesli Asistan',
            subtitle: 'Ses komutları ve geri bildirim',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    VoiceAssistantPage(authController: widget.authController),
              ),
            ),
          ),
          const SettingsDivider(),
          SettingsTile(
            icon: Icons.account_balance_wallet_outlined,
            iconColor: Colors.green,
            title: 'Harcamalar',
            subtitle: 'Bütçe, kategoriler ve sabit giderler',
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HarcamalarAyarlariSayfasi(
                    userId: widget.authController.currentUser!.id,
                  ),
                ),
              );
              if (result == true) setState(() => _needsRefresh = true);
            },
          ),
          const SettingsDivider(),
          SettingsTile(
            icon: Icons.trending_up,
            iconColor: Colors.teal,
            title: 'Gelirler',
            subtitle: 'Gelir kategorilerini özelleştirin',
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GelirlerAyarlariSayfasi(
                    userId: widget.authController.currentUser!.id,
                  ),
                ),
              );
              if (result == true) setState(() => _needsRefresh = true);
            },
          ),
          const SettingsDivider(),
          SettingsTile(
            icon: Icons.storage_outlined,
            iconColor: Colors.blue,
            title: 'Veri İşlemleri',
            subtitle: 'Yedekleme, geri yükleme ve silme',
            isLast: true,
            onTap: () => _showBackupDialog(context),
          ),
        ],
      ),
    );
  }

  void _showBackupDialog(BuildContext context) {
    final userId = widget.authController.currentUser?.id;
    if (userId == null) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Veri İşlemleri',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(sheetContext).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 24),
            // Yedekle butonu
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.cloud_upload, color: Colors.green),
              ),
              title: const Text('Verileri Yedekle'),
              subtitle: Text(
                'Tüm verilerinizi JSON olarak dışa aktarın',
                style: TextStyle(
                  color: Theme.of(
                    sheetContext,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
                  fontSize: 12,
                ),
              ),
              onTap: () => _handleBackupData(sheetContext, userId),
            ),
            const SizedBox(height: 12),
            // Geri yükle butonu
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.cloud_download, color: Colors.blue),
              ),
              title: const Text('Verileri Geri Yükle'),
              subtitle: Text(
                'Yedek dosyasından verileri içe aktarın',
                style: TextStyle(
                  color: Theme.of(
                    sheetContext,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
                  fontSize: 12,
                ),
              ),
              onTap: () => _handleRestoreData(sheetContext, userId),
            ),
            const SizedBox(height: 16),
            // Ayırıcı çizgi
            Divider(
              color: Theme.of(
                sheetContext,
              ).colorScheme.onSurface.withValues(alpha: 0.1),
              height: 1,
            ),
            const SizedBox(height: 16),
            // Tüm verileri sil butonu
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.delete_forever, color: Colors.red),
              ),
              title: const Text(
                'Tüm Verilerimi Sil',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                'Dikkat! Bu işlem geri alınamaz',
                style: TextStyle(
                  color: Colors.red.withValues(alpha: 0.7),
                  fontSize: 12,
                ),
              ),
              onTap: () => _handleDeleteAllData(sheetContext, userId),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  /// Verileri yedekleme işlemini yönetir
  Future<void> _handleBackupData(
    BuildContext sheetContext,
    String userId,
  ) async {
    Navigator.pop(sheetContext);
    await HapticService.lightImpact();
    final path = await BackupService.exportData(userId);
    if (path != null && mounted) {
      final shareResult = await BackupService.shareBackup(path);
      if (mounted) {
        if (shareResult.status == ShareResultStatus.success) {
          // Kullanıcı dosyayı gerçekten kaydetti
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Yedek dosyası başarıyla kaydedildi ✅'),
              backgroundColor: Colors.green.shade700,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        } else if (shareResult.status == ShareResultStatus.dismissed) {
          // Kullanıcı iptal etti
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Yedekleme iptal edildi',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.deepOrange.shade900,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      }
    }
  }

  /// Verileri geri yükleme işlemini yönetir
  Future<void> _handleRestoreData(
    BuildContext sheetContext,
    String userId,
  ) async {
    // BottomSheet'i kapat
    Navigator.pop(sheetContext);
    await HapticService.lightImpact();

    // Loading overlay'ın açık olup olmadığını takip et
    bool isLoadingShown = false;

    try {
      final result = await BackupService.importData(
        userId,
        onFileSelected: () {
          // Dosya seçildikten sonra loading overlay'i göster
          _showLoadingOverlay();
          isLoadingShown = true;
        },
      );

      // Loading overlay'i kapat (sadece gösterildiyse)
      // Minimum 3 saniye ekranda kalması için bekle
      if (isLoadingShown && mounted) {
        await Future.delayed(const Duration(seconds: 4));
        if (mounted) Navigator.of(context).pop();
      }

      if (mounted) {
        if (result.success) {
          // Başarı animasyonunu göster
          await _showSuccessOverlay();
          await HapticService.success();
          // Ana sayfadaki verileri yenile
          widget.onNavigationReturn?.call();
          // Dashboard sayfasına yönlendir (AnaSayfa'yı yeniden oluştur)
          if (mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (_) => AnaSayfa(authController: widget.authController),
              ),
              (route) => false,
            );
          }
        } else if (result.message != 'Dosya seçilmedi') {
          // Dosya seçilmedi mesajını gösterme, sadece gerçek hataları göster
          _showErrorSnackBar(result.message);
        }
      }
    } catch (e) {
      // Loading overlay'i kapat (sadece gösterildiyse)
      if (isLoadingShown && mounted) {
        Navigator.of(context).pop();
      }
      // Beklenmeyen hata durumunda
      if (mounted) {
        _showErrorSnackBar('Beklenmeyen hata: $e');
      }
    }
  }

  /// Loading overlay'i gösterir (kullanıcı kapatamaz)
  void _showLoadingOverlay() {
    showDialog(
      context: context,
      barrierDismissible: false, // Kullanıcı dışarı tıklayarak kapatamaz
      barrierColor: Colors.black.withValues(alpha: 0.7), // %50 opaklık
      builder: (context) => PopScope(
        canPop: false, // Geri tuşuyla kapatılamaz
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Lottie animasyonu
              Lottie.asset(
                'assets/lottie/verigeriyukleme.json',
                width: 300,
                height: 300,
              ),
              const SizedBox(height: 16),
              // Yükleniyor metni
              const Text(
                'Veriler geri yükleniyor...',
                style: TextStyle(
                  fontFamily: 'sans-serif',
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Hata mesajı gösterir
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.red.shade800,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  /// Başarı overlay'ini gösterir (2 saniye)
  Future<void> _showSuccessOverlay() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder: (context) => PopScope(
        canPop: false,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Success animasyonu
              Lottie.asset(
                'assets/lottie/Success_animation.json',
                width: 300,
                height: 300,
              ),
              const SizedBox(height: 16),
              // Başarı metni
              const Text(
                'Geri yükleme başarı ile tamamlandı',
                style: TextStyle(
                  fontFamily: 'sans-serif',
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // 2 saniye bekle
    await Future.delayed(const Duration(seconds: 2));

    // Overlay'i kapat
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  /// Tüm verileri silme işlemini yönetir
  Future<void> _handleDeleteAllData(
    BuildContext sheetContext,
    String userId,
  ) async {
    Navigator.pop(sheetContext); // Bottom sheet'i kapat

    // İlk onay dialogu
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF8B0000).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                color: Color(0xFF8B0000),
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Dikkat!',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Yedekleme tavsiyesi
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.lightbulb_outline, color: Colors.amber, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Silmeden önce verilerinizi yedeklemenizi öneririz!',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Tüm verileriniz kalıcı olarak silinecek:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            const Text('• Tüm harcamalar'),
            const Text('• Tüm gelirler'),
            const Text('• Tüm varlıklar'),
            const Text('• Ödeme yöntemleri'),
            const Text('• Transferler'),
            const Text('• Seri kayıtları'),
            const SizedBox(height: 16),
            const Text(
              'Bu işlem geri alınamaz!',
              style: TextStyle(
                color: Color(0xFF8B0000),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal', style: TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B0000),
              foregroundColor: Colors.white,
            ),
            child: const Text('Devam Et'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    // İkinci onay - Matematik işlemi
    final random = Random();
    // 0: Toplama, 1: Çıkarma, 2: Çarpma
    final operatorType = random.nextInt(3);

    int num1, num2, expectedResult;
    String operatorSign;

    if (operatorType == 0) {
      // Toplama: Sayılar 1-20 arası
      num1 = random.nextInt(20) + 1;
      num2 = random.nextInt(20) + 1;
      expectedResult = num1 + num2;
      operatorSign = '+';
    } else if (operatorType == 1) {
      // Çıkarma: Pozitif sonuç için num1 > num2
      num1 = random.nextInt(20) + 10; // 10-29
      num2 = random.nextInt(9) + 1; // 1-9
      expectedResult = num1 - num2;
      operatorSign = '-';
    } else {
      // Çarpma: Sayılar 2-9 arası (tablo çarpım kolaylığı)
      num1 = random.nextInt(8) + 2;
      num2 = random.nextInt(8) + 2;
      expectedResult = num1 * num2;
      operatorSign = 'x';
    }

    final confirmSum = await showDialog<int>(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Güvenlik Doğrulaması'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Silme işlemini onaylamak için sonucu yazın:'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 24,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$num1 $operatorSign $num2 = ?',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20),
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.white.withValues(
                        alpha: 0.2,
                      ), // Silik beyaz/gri çerçeve
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.white.withValues(
                        alpha: 0.5,
                      ), // Odaklanınca biraz daha belirgin
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text('İptal', style: TextStyle(color: Colors.white)),
            ),
            ElevatedButton(
              onPressed: () {
                final val = int.tryParse(controller.text);
                Navigator.pop(context, val);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B0000),
                foregroundColor: Colors.white,
              ),
              child: const Text('Sil'),
            ),
          ],
        );
      },
    );

    if (confirmSum != expectedResult || !mounted) {
      if (confirmSum != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Hatalı işlem sonucu. Silme iptal edildi.'),
            backgroundColor: Colors.orange.shade800,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
      return;
    }

    // Silme işlemini gerçekleştir
    await HapticService.heavyImpact();
    final success = await BackupService.deleteAllData(userId);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Tüm veriler silindi ✅'),
            backgroundColor: Colors.green.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        // Ana sayfaya yönlendir
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => AnaSayfa(authController: widget.authController),
          ),
          (route) => false,
        );
      } else {
        _showErrorSnackBar('Veriler silinirken bir hata oluştu');
      }
    }
  }
}

/// Harcama Ayarları Sayfası
class HarcamalarAyarlariSayfasi extends StatefulWidget {
  final String userId;

  const HarcamalarAyarlariSayfasi({super.key, required this.userId});

  @override
  State<HarcamalarAyarlariSayfasi> createState() =>
      _HarcamalarAyarlariSayfasiState();
}

class _HarcamalarAyarlariSayfasiState extends State<HarcamalarAyarlariSayfasi> {
  final TextEditingController tGelir = TextEditingController();
  bool categoryChanged = false;
  bool _isSaved = false;
  String _savedAmount = "";
  List<PaymentMethod> odemeYontemleri = [];
  String? varsayilanOdemeYontemiId;

  @override
  void initState() {
    super.initState();
    _verileriYukle();
  }

  void _verileriYukle() {
    final expenseRepo = getIt<ExpenseRepository>();
    final paymentRepo = getIt<PaymentMethodRepository>();

    double mevcutButce = expenseRepo.getBudget(widget.userId);
    tGelir.text = mevcutButce.toStringAsFixed(0);

    List<Map<String, dynamic>> pmVerileri = paymentRepo.getPaymentMethods(
      widget.userId,
    );
    List<PaymentMethod> pmList = pmVerileri
        .map((m) => PaymentMethod.fromMap(m))
        .toList();
    String? varsayilanPm = paymentRepo.getDefaultPaymentMethod(widget.userId);

    setState(() {
      odemeYontemleri = pmList.where((pm) => !pm.isDeleted).toList();
      varsayilanOdemeYontemiId = varsayilanPm;
    });
  }

  void _butceyiKaydet() {
    final tutarText = tGelir.text
        .trim()
        .replaceAll('.', '')
        .replaceAll(',', '');
    final validationError = Validators.validateAmount(
      tutarText,
      maxAmount: 10000000,
    );

    if (validationError != null) {
      ErrorHandler.showErrorSnackBar(context, validationError);
      return;
    }

    double? yeniLimit = double.tryParse(tutarText);
    if (yeniLimit != null) {
      try {
        getIt<ExpenseRepository>().saveBudget(widget.userId, yeniLimit);
        final formattedAmount = yeniLimit
            .toStringAsFixed(0)
            .replaceAllMapped(
              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
              (Match m) => '${m[1]}.',
            );

        setState(() {
          categoryChanged = true;
          _isSaved = true;
          _savedAmount = formattedAmount;
          tGelir.text =
              "Bütçe Limitiniz $formattedAmount TL olarak güncellendi.";
        });

        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            setState(() {
              _isSaved = false;
              tGelir.text = _savedAmount;
            });
          }
        });
      } catch (e) {
        ErrorHandler.handleDatabaseError(context, e);
      }
    }
  }

  void _handlePaymentMethodChanged(String? newValue) {
    setState(() {
      varsayilanOdemeYontemiId = newValue;
      categoryChanged = true;
    });
    getIt<PaymentMethodRepository>().saveDefaultPaymentMethod(
      widget.userId,
      newValue,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          "Varsayılan ödeme yöntemi güncellendi ✅",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(12),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.pop(context, categoryChanged);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Gider Ayarları"),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context, categoryChanged),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 32),
              BudgetSection(
                controller: tGelir,
                isSaved: _isSaved,
                onSave: _butceyiKaydet,
              ),
              const SizedBox(height: 30),
              RecurringExpenseSection(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          RecurringTransactionsPage(userId: widget.userId),
                    ),
                  );
                },
              ),
              const SizedBox(height: 30),
              DefaultPaymentSection(
                odemeYontemleri: odemeYontemleri,
                varsayilanOdemeYontemiId: varsayilanOdemeYontemiId,
                onChanged: _handlePaymentMethodChanged,
              ),
              const SizedBox(height: 30),
              CategorySection(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          KategoriYonetimiSayfasi(userId: widget.userId),
                    ),
                  ).then((_) => setState(() => categoryChanged = true));
                },
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 600),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Gider Ayarları",
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Bütçenizi ve harcama tercihlerinizi yönetin",
            style: TextStyle(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.54),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
