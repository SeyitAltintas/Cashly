import 'package:flutter/material.dart';
import 'package:cashly/core/extensions/l10n_extensions.dart';
import 'package:cashly/core/di/injection_container.dart';
import 'package:cashly/features/income/domain/repositories/income_repository.dart';
import 'package:cashly/core/utils/validators.dart';
import 'package:cashly/core/utils/error_handler.dart';
import 'package:cashly/core/widgets/app_snackbar.dart';
import 'package:cashly/features/income/presentation/pages/recurring_income_page.dart';

/// Gelir Ayarları Sayfası
/// Aylık gelir hedefi ve tekrarlayan gelir şablonlarını yönetir.
class GelirAyarlariSayfasi extends StatefulWidget {
  final String userId;
  const GelirAyarlariSayfasi({super.key, required this.userId});

  @override
  State<GelirAyarlariSayfasi> createState() => _GelirAyarlariSayfasiState();
}

class _GelirAyarlariSayfasiState extends State<GelirAyarlariSayfasi> {
  final TextEditingController _targetController = TextEditingController();
  bool _isSaved = false;
  bool _categoryChanged = false;

  @override
  void initState() {
    super.initState();
    _verileriYukle();
  }

  @override
  void dispose() {
    _targetController.dispose();
    super.dispose();
  }

  void _verileriYukle() {
    final incomeRepo = getIt<IncomeRepository>();

    final target = incomeRepo.getIncomeTarget(widget.userId);
    _targetController.text = target > 0 ? target.toStringAsFixed(0) : '';

    setState(() {});
  }

  void _hedefiKaydet() {
    final tutarText = _targetController.text
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

    final yeniHedef = double.tryParse(tutarText);
    if (yeniHedef != null) {
      try {
        getIt<IncomeRepository>().saveIncomeTarget(widget.userId, yeniHedef);
        _categoryChanged = true;
        setState(() => _isSaved = true);
        AppSnackBar.success(
          context,
          context.l10n.incomeTargetUpdated,
          duration: const Duration(seconds: 2),
        );
        Future.delayed(const Duration(seconds: 4), () {
          if (mounted) setState(() => _isSaved = false);
        });
      } catch (e, stackTrace) {
        ErrorHandler.handleDatabaseError(context, e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.pop(context, _categoryChanged);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.l10n.incomeSettingsTitle),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context, _categoryChanged),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(context),
              const SizedBox(height: 32),

              // ===== AYLIK GELİR HEDEFİ =====
              _buildSectionTitle(
                context,
                context.l10n.monthlyIncomeTarget,
                Icons.trending_up_rounded,
              ),
              const SizedBox(height: 12),
              _buildIncomeTargetSection(context),

              const SizedBox(height: 30),

              // ===== TEKRARlAYAN GELİRLER =====
              RecurringIncomeSection(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          RecurringIncomePage(userId: widget.userId),
                    ),
                  ).then((value) {
                    if (value == true) {
                      setState(() => _categoryChanged = true);
                    }
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
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: child,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.incomeSettingsTitle,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.incomeSettingsDesc,
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

  Widget _buildSectionTitle(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Theme.of(context).colorScheme.secondary),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            color: Theme.of(context).colorScheme.secondary,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildIncomeTargetSection(BuildContext context) {
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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.incomeTargetQuestion,
            style: TextStyle(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _targetController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    hintText: '0',
                    hintStyle: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.3),
                    ),
                    prefixIcon: Icon(
                      Icons.currency_lira,
                      color: Colors.green.shade400,
                    ),
                    suffixText: context.l10n.perMonth,
                    suffixStyle: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                    filled: true,
                    fillColor: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.05),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _hedefiKaydet,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isSaved
                      ? Colors.green
                      : Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _isSaved ? '✓' : context.l10n.save,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Tekrarlayan gelirler bölümü widget'ı
class RecurringIncomeSection extends StatelessWidget {
  final VoidCallback onTap;

  const RecurringIncomeSection({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(
            context,
          ).colorScheme.onSurface.withValues(alpha: 0.15),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.surface.withValues(alpha: 0.3),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.repeat,
                    color: Colors.green,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  context.l10n.recurringIncomesTitle,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
          // İçerik - Buton
          InkWell(
            onTap: onTap,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.l10n.manageRecurringIncomes,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          context.l10n.manageRecurringIncomesDesc,
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
                    ).colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
