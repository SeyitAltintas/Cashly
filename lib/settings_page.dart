import 'package:flutter/material.dart';

import 'services/database_helper.dart';
import 'features/expenses/presentation/pages/category_management_page.dart';
import 'features/income/presentation/pages/income_settings_page.dart';
import 'features/settings/presentation/pages/appearance_page.dart';
import 'features/settings/presentation/pages/voice_assistant_page.dart';
import 'features/settings/presentation/pages/recurring_transactions_page.dart';
import 'features/settings/presentation/pages/haptic_settings_page.dart';
import 'features/payment_methods/data/models/payment_method_model.dart';

import 'features/auth/presentation/controllers/auth_controller.dart';
import 'core/utils/validators.dart';
import 'core/utils/error_handler.dart';

// Modüler widget'lar
import 'features/settings/presentation/widgets/settings_tile.dart';
import 'features/settings/presentation/widgets/expense_settings/budget_section.dart';
import 'features/settings/presentation/widgets/expense_settings/recurring_expense_section.dart';
import 'features/settings/presentation/widgets/expense_settings/default_payment_section.dart';
import 'features/settings/presentation/widgets/expense_settings/category_section.dart';
import 'services/backup_service.dart';
import 'services/haptic_service.dart';

/// Ayarlar Sayfası
class AyarlarSayfasi extends StatefulWidget {
  final AuthController authController;

  const AyarlarSayfasi({super.key, required this.authController});

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
            icon: Icons.backup_outlined,
            iconColor: Colors.blue,
            title: 'Veri Yedekleme',
            subtitle: 'Verilerinizi yedekleyin veya geri yükleyin',
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
      builder: (context) => Padding(
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
              'Veri Yedekleme',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
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
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
                  fontSize: 12,
                ),
              ),
              onTap: () async {
                Navigator.pop(context);
                await HapticService.lightImpact();
                final path = await BackupService.exportData(userId);
                if (path != null && context.mounted) {
                  await BackupService.shareBackup(path);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Yedek dosyası oluşturuldu ✅'),
                        backgroundColor: Colors.green.shade700,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  }
                }
              },
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
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
                  fontSize: 12,
                ),
              ),
              onTap: () async {
                Navigator.pop(context);
                await HapticService.lightImpact();
                final result = await BackupService.importData(userId);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(result.message),
                      backgroundColor: result.success
                          ? Colors.green.shade700
                          : Colors.red.shade700,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                  if (result.success) {
                    setState(() => _needsRefresh = true);
                  }
                }
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
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
    double mevcutButce = DatabaseHelper.butceGetir(widget.userId);
    tGelir.text = mevcutButce.toStringAsFixed(0);

    List<Map<String, dynamic>> pmVerileri = DatabaseHelper.odemeYontemleriGetir(
      widget.userId,
    );
    List<PaymentMethod> pmList = pmVerileri
        .map((m) => PaymentMethod.fromMap(m))
        .toList();
    String? varsayilanPm = DatabaseHelper.varsayilanOdemeYontemiGetir(
      widget.userId,
    );

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
        DatabaseHelper.butceKaydet(widget.userId, yeniLimit);
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
    DatabaseHelper.varsayilanOdemeYontemiKaydet(widget.userId, newValue);
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
