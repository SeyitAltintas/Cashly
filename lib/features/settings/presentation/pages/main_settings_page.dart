import 'package:flutter/material.dart';
import 'dart:math';

import 'package:cashly/features/income/presentation/pages/income_settings_page.dart';
import 'appearance/appearance_page.dart';
import 'voice/voice_assistant_page.dart';
import 'appearance/haptic_settings_page.dart';
import 'notifications/notification_settings_page.dart';
import 'finance/expense_settings_page.dart';
import 'finance/transfer_settings_page.dart';
import '../state/main_settings_state.dart';

import 'package:cashly/features/auth/presentation/controllers/auth_controller.dart';

// Modüler widget'lar
import '../widgets/settings_tile.dart';

import 'package:cashly/core/services/backup_service.dart';
import 'package:cashly/core/services/haptic_service.dart';
import 'package:cashly/core/widgets/app_snackbar.dart';
import 'package:cashly/core/widgets/app_loading_overlay.dart';
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
  late final MainSettingsState _mainState;

  bool get _needsRefresh => _mainState.needsRefresh;

  @override
  void initState() {
    super.initState();
    _mainState = MainSettingsState();
    _mainState.addListener(_onStateChanged);
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _mainState.removeListener(_onStateChanged);
    _mainState.dispose();
    super.dispose();
  }

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
            subtitle: 'Tema, animasyon ve görsel efektler',
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
            subtitle: 'Tıklama, işlem ve uyarı titreşimleri',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const HapticSettingsPage(),
              ),
            ),
          ),
          const SettingsDivider(),
          SettingsTile(
            icon: Icons.notifications_outlined,
            iconColor: Colors.amber,
            title: 'Bildirimler',
            subtitle: 'Hatırlatıcılar ve uyarı bildirimleri',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NotificationSettingsPage(),
              ),
            ),
          ),
          const SettingsDivider(),
          SettingsTile(
            icon: Icons.mic_outlined,
            iconColor: Colors.orange,
            title: 'Sesli Asistan',
            subtitle: 'Sesli geri bildirim ve komut listesi',
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
            subtitle: 'Bütçe, kategori ve ödeme yöntemleri',
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HarcamalarAyarlariSayfasi(
                    userId: widget.authController.currentUser!.id,
                  ),
                ),
              );
              if (result == true) _mainState.needsRefresh = true;
            },
          ),
          const SettingsDivider(),
          SettingsTile(
            icon: Icons.trending_up,
            iconColor: Colors.teal,
            title: 'Gelirler',
            subtitle: 'Gelir kategorileri ve düzenli gelirler',
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GelirlerAyarlariSayfasi(
                    userId: widget.authController.currentUser!.id,
                  ),
                ),
              );
              if (result == true) _mainState.needsRefresh = true;
            },
          ),
          const SettingsDivider(),
          SettingsTile(
            icon: Icons.swap_horiz_rounded,
            iconColor: Colors.cyan,
            title: 'Para Transferleri',
            subtitle: 'İşlem geçmişi görüntüleme ayarları',
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TransferSettingsPage(
                    userId: widget.authController.currentUser!.id,
                  ),
                ),
              );
              if (result == true) _mainState.needsRefresh = true;
            },
          ),
          const SettingsDivider(),
          SettingsTile(
            icon: Icons.storage_outlined,
            iconColor: Colors.blue,
            title: 'Veri İşlemleri',
            subtitle: 'Yedekleme, geri yükleme ve sıfırlama',
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
          AppSnackBar.success(context, 'Yedek dosyası başarıyla kaydedildi ✅');
        } else if (shareResult.status == ShareResultStatus.dismissed) {
          // Kullanıcı iptal etti
          AppSnackBar.warning(context, 'Yedekleme iptal edildi');
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
          AppLoadingOverlay.show(
            context,
            message: 'Veriler geri yükleniyor...',
          );
          isLoadingShown = true;
        },
      );

      // Loading overlay'i kapat (sadece gösterildiyse)
      // Minimum 3 saniye ekranda kalması için bekle
      if (isLoadingShown && mounted) {
        await Future.delayed(const Duration(seconds: 4));
        if (mounted) AppLoadingOverlay.hide(context);
      }

      if (mounted) {
        if (result.success) {
          // Başarı animasyonunu göster
          await AppLoadingOverlay.showSuccess(
            context,
            message: 'Geri yükleme başarı ile tamamlandı',
          );
          await HapticService.success();
          // Profil bilgilerini yenile (profil resmi dahil)
          await widget.authController.checkAuth();
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
        AppLoadingOverlay.hide(context);
      }
      // Beklenmeyen hata durumunda
      if (mounted) {
        _showErrorSnackBar('Beklenmeyen hata: $e');
      }
    }
  }

  /// Hata mesajı gösterir
  void _showErrorSnackBar(String message) {
    AppSnackBar.error(context, message);
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
        AppSnackBar.warning(
          context,
          'Hatalı işlem sonucu. Silme iptal edildi.',
        );
      }
      return;
    }

    // Silme işlemini gerçekleştir
    await HapticService.heavyImpact();
    final success = await BackupService.deleteAllData(userId);

    if (mounted) {
      if (success) {
        AppSnackBar.success(context, 'Tüm veriler silindi ✅');
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

// HarcamalarAyarlariSayfasi ayrı dosyaya taşındı
// Bkz: expense_settings_page.dart
