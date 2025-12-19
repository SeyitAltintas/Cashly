import 'package:flutter/material.dart';

import 'services/database_helper.dart';
import 'features/expenses/presentation/pages/category_management_page.dart';
import 'features/income/presentation/pages/income_settings_page.dart';
import 'features/settings/presentation/pages/appearance_page.dart';
import 'features/settings/presentation/pages/voice_assistant_page.dart';
import 'features/settings/presentation/pages/recurring_transactions_page.dart';
import 'features/payment_methods/data/models/payment_method_model.dart';

import 'features/auth/presentation/controllers/auth_controller.dart';
import 'core/utils/validators.dart';
import 'core/utils/error_handler.dart';

// Modüler widget'lar
import 'features/settings/presentation/widgets/expense_settings/budget_section.dart';
import 'features/settings/presentation/widgets/expense_settings/recurring_expense_section.dart';
import 'features/settings/presentation/widgets/expense_settings/default_payment_section.dart';
import 'features/settings/presentation/widgets/expense_settings/category_section.dart';

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
              // Ayarlar başlığı
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

              // Ayar kartları container
              Container(
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
                    // Görünüm
                    _buildSettingsTile(
                      icon: Icons.palette_outlined,
                      iconColor: Colors.purple,
                      title: 'Görünüm',
                      subtitle: 'Tema ve renk ayarları',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AppearancePage(),
                          ),
                        );
                      },
                    ),
                    _buildDivider(),

                    // Sesli Asistan
                    _buildSettingsTile(
                      icon: Icons.mic_outlined,
                      iconColor: Colors.orange,
                      title: 'Sesli Asistan',
                      subtitle: 'Ses komutları ve geri bildirim',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VoiceAssistantPage(
                              authController: widget.authController,
                            ),
                          ),
                        );
                      },
                    ),
                    _buildDivider(),

                    // Harcamalar
                    _buildSettingsTile(
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
                        if (result == true) {
                          setState(() {
                            _needsRefresh = true;
                          });
                        }
                      },
                    ),
                    _buildDivider(),

                    // Gelirler
                    _buildSettingsTile(
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
                        if (result == true) {
                          setState(() {
                            _needsRefresh = true;
                          });
                        }
                      },
                      isLast: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isLast = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: isLast
            ? const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              )
            : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.5),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.3),
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.only(left: 72),
      child: Divider(
        height: 1,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08),
      ),
    );
  }
}

/// Harcama Ayarları Sayfası
/// Bütçe limiti, tekrarlayan giderler, varsayılan ödeme yöntemi ve kategoriler
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

  // Ödeme yöntemleri
  List<PaymentMethod> odemeYontemleri = [];
  String? varsayilanOdemeYontemiId;

  @override
  void initState() {
    super.initState();
    verileriYukle();
  }

  void verileriYukle() {
    double mevcutButce = DatabaseHelper.butceGetir(widget.userId);
    tGelir.text = mevcutButce.toStringAsFixed(0);

    // Ödeme yöntemlerini yükle
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

  void butceyiKaydet() {
    // Binlik ayırıcı noktaları temizle
    final tutarText = tGelir.text
        .trim()
        .replaceAll('.', '')
        .replaceAll(',', '');

    // Validation
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

        // Format the amount with thousands separator
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

        // 3 saniye sonra normal değere dön
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
              // Başlık
              _buildHeader(context),
              const SizedBox(height: 32),

              // Bütçe Limiti
              BudgetSection(
                controller: tGelir,
                isSaved: _isSaved,
                onSave: butceyiKaydet,
              ),
              const SizedBox(height: 30),

              // Tekrarlayan Giderler
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

              // Varsayılan Ödeme Yöntemi
              DefaultPaymentSection(
                odemeYontemleri: odemeYontemleri,
                varsayilanOdemeYontemiId: varsayilanOdemeYontemiId,
                onChanged: _handlePaymentMethodChanged,
              ),
              const SizedBox(height: 30),

              // Kategori Yönetimi
              CategorySection(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          KategoriYonetimiSayfasi(userId: widget.userId),
                    ),
                  ).then((_) {
                    setState(() {
                      categoryChanged = true;
                    });
                  });
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
