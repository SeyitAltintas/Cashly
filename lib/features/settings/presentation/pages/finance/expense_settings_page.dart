import 'package:flutter/material.dart';
import 'package:cashly/core/extensions/l10n_extensions.dart';

import 'package:cashly/core/di/injection_container.dart';
import 'package:cashly/features/expenses/domain/repositories/expense_repository.dart';
import 'package:cashly/features/payment_methods/domain/repositories/payment_method_repository.dart';
import 'package:cashly/features/expenses/presentation/pages/category_management_page.dart';
import 'package:cashly/features/payment_methods/data/models/payment_method_model.dart';
import 'package:cashly/core/utils/validators.dart';
import 'package:cashly/core/utils/error_handler.dart';
import 'package:cashly/core/widgets/app_snackbar.dart';

import '../../widgets/expense_settings/budget_section.dart';
import '../../widgets/expense_settings/recurring_expense_section.dart';
import '../../widgets/expense_settings/default_payment_section.dart';
import '../../widgets/expense_settings/category_section.dart';
import '../../widgets/expense_settings/category_budget_section.dart';
import 'recurring_transactions_page.dart';
import 'state/expense_settings_state.dart';

/// Harcama Ayarları Sayfası
/// Bütçe limiti, varsayılan ödeme yöntemi ve kategori yönetimi ayarlarını içerir.
class HarcamalarAyarlariSayfasi extends StatefulWidget {
  final String userId;

  const HarcamalarAyarlariSayfasi({super.key, required this.userId});

  @override
  State<HarcamalarAyarlariSayfasi> createState() =>
      _HarcamalarAyarlariSayfasiState();
}

class _HarcamalarAyarlariSayfasiState extends State<HarcamalarAyarlariSayfasi> {
  final TextEditingController tGelir = TextEditingController();
  late final ExpenseSettingsState _expState;

  bool get categoryChanged => _expState.categoryChanged;
  bool get _isSaved => _expState.isSaved;
  List<PaymentMethod> get odemeYontemleri => _expState.odemeYontemleri;
  String? get varsayilanOdemeYontemiId => _expState.varsayilanOdemeYontemiId;

  @override
  void initState() {
    super.initState();
    _expState = ExpenseSettingsState();
    _expState.addListener(_onStateChanged);
    _verileriYukle();
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _expState.removeListener(_onStateChanged);
    _expState.dispose();
    tGelir.dispose();
    super.dispose();
  }

  /// Bütçe ve ödeme yöntemi verilerini repository'den yükler
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

    _expState.odemeYontemleri = pmList.where((pm) => !pm.isDeleted).toList();
    _expState.varsayilanOdemeYontemiId = varsayilanPm;
  }

  /// Bütçe limitini kaydeder
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

        _expState.categoryChanged = true;
        _expState.isSaved = true;
        _expState.savedAmount = formattedAmount;
        _expState.savedMessage = context.l10n.budgetUpdated(formattedAmount);

        Future.delayed(const Duration(seconds: 4), () {
          if (mounted) {
            _expState.isSaved = false;
            _expState.savedMessage = null;
          }
        });
      } catch (e) {
        ErrorHandler.handleDatabaseError(context, e);
      }
    }
  }

  /// Varsayılan ödeme yöntemi değişikliğini işler
  void _handlePaymentMethodChanged(String? newValue) {
    _expState.varsayilanOdemeYontemiId = newValue;
    _expState.categoryChanged = true;
    getIt<PaymentMethodRepository>().saveDefaultPaymentMethod(
      widget.userId,
      newValue,
    );
    AppSnackBar.success(
      context,
      context.l10n.defaultPaymentUpdated,
      duration: const Duration(seconds: 1),
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
          title: Text(context.l10n.expenseSettingsTitle),
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
                savedMessage: _expState.savedMessage,
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
                  ).then((_) {
                    if (mounted) _expState.categoryChanged = true;
                  });
                },
              ),
              const SizedBox(height: 30),
              // Kategori bazlı bütçe limitleri
              CategoryBudgetSection(
                userId: widget.userId,
                onChanged: () => _expState.categoryChanged = true,
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  /// Sayfa başlığı animasyonlu header
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
            context.l10n.expenseSettingsTitle,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.expenseSettingsDesc,
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
