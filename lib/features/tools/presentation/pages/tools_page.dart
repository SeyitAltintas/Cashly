import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cashly/core/extensions/l10n_extensions.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/services/haptic_service.dart';
import '../controllers/tools_controller.dart';

/// Tüm İşlemler Sayfası
/// Profesyonel finans uygulaması tasarımı
/// ToolsController ile entegre edilmiştir
class ToolsPage extends StatefulWidget {
  final VoidCallback onAssetsPressed;
  final VoidCallback onAnalysisPressed;
  final VoidCallback onPaymentMethodsPressed;
  final VoidCallback onTransferPressed;
  final VoidCallback? onExpensesPressed;
  final VoidCallback? onIncomesPressed;

  const ToolsPage({
    super.key,
    required this.onAssetsPressed,
    required this.onAnalysisPressed,
    required this.onPaymentMethodsPressed,
    required this.onTransferPressed,
    this.onExpensesPressed,
    this.onIncomesPressed,
  });

  @override
  State<ToolsPage> createState() => _ToolsPageState();
}

class _ToolsPageState extends State<ToolsPage> {
  late final ToolsController _controller;

  @override
  void initState() {
    super.initState();
    // DI'dan controller al
    _controller = getIt<ToolsController>();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Consumer<ToolsController>(
        builder: (context, controller, child) {
          return Scaffold(
            backgroundColor: Colors.transparent,
            body: SafeArea(
              child: controller.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      physics: const BouncingScrollPhysics(),
                      children: [
                        // Header
                        _buildHeader(context),
                        const SizedBox(height: 28),

                        // Ana İşlemler Bölümü
                        _buildSectionTitle(context, context.l10n.cashFlow),
                        const SizedBox(height: 14),

                        // Harcama ve Gelir kartları (yan yana)
                        Row(
                          children: [
                            if (widget.onExpensesPressed != null)
                              Expanded(
                                child: _FinanceCard(
                                  icon: Icons.arrow_downward_rounded,
                                  title: context.l10n.myExpenses,
                                  iconColor: const Color(0xFFE53935),
                                  iconBgColor: const Color(
                                    0xFFE53935,
                                  ).withValues(alpha: 0.12),
                                  onTap: () {
                                    HapticService.lightImpact();
                                    widget.onExpensesPressed!();
                                  },
                                ),
                              ),
                            if (widget.onExpensesPressed != null &&
                                widget.onIncomesPressed != null)
                              const SizedBox(width: 14),
                            if (widget.onIncomesPressed != null)
                              Expanded(
                                child: _FinanceCard(
                                  icon: Icons.arrow_upward_rounded,
                                  title: context.l10n.myIncomes,
                                  iconColor: const Color(0xFF43A047),
                                  iconBgColor: const Color(
                                    0xFF43A047,
                                  ).withValues(alpha: 0.12),
                                  onTap: () {
                                    HapticService.lightImpact();
                                    widget.onIncomesPressed!();
                                  },
                                ),
                              ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Hesaplarım Bölümü
                        _buildSectionTitle(context, context.l10n.myWallet),
                        const SizedBox(height: 14),

                        // Varlıklar ve Ödeme Yöntemleri
                        _FinanceListTile(
                          icon: Icons.account_balance_wallet_outlined,
                          title: context.l10n.myAssets,
                          subtitle: context.l10n.assetsSubtitle,
                          iconColor: const Color(0xFF1E88E5),
                          onTap: () {
                            HapticService.lightImpact();
                            widget.onAssetsPressed();
                          },
                        ),
                        const SizedBox(height: 10),
                        _FinanceListTile(
                          icon: Icons.credit_card_outlined,
                          title: context.l10n.myPaymentMethods,
                          subtitle: context.l10n.paymentMethodsSubtitle,
                          iconColor: const Color(0xFF8E24AA),
                          onTap: () {
                            HapticService.lightImpact();
                            widget.onPaymentMethodsPressed();
                          },
                        ),

                        const SizedBox(height: 24),

                        // Araçlar Bölümü
                        _buildSectionTitle(
                          context,
                          context.l10n.otherTransactions,
                        ),
                        const SizedBox(height: 14),

                        // Analiz ve Transfer
                        _FinanceListTile(
                          icon: Icons.insights_outlined,
                          title: context.l10n.analysisAndReports,
                          subtitle: context.l10n.analysisSubtitle,
                          iconColor: const Color(0xFFFF7043),
                          onTap: () {
                            HapticService.lightImpact();
                            widget.onAnalysisPressed();
                          },
                        ),
                        const SizedBox(height: 10),
                        _FinanceListTile(
                          icon: Icons.sync_alt_rounded,
                          title: context.l10n.moneyTransfer,
                          subtitle: context.l10n.transferSubtitle,
                          iconColor: const Color.fromARGB(255, 0, 123, 110),
                          onTap: () {
                            HapticService.lightImpact();
                            widget.onTransferPressed();
                          },
                        ),

                        const SizedBox(height: 100),
                      ],
                    ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 15 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.allTransactions,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            context.l10n.manageFinancialTransactions,
            style: TextStyle(
              fontSize: 15,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
        letterSpacing: 0.5,
      ),
    );
  }
}

/// Kompakt finans kartı (Harcama/Gelir için)
class _FinanceCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color iconColor;
  final Color iconBgColor;
  final VoidCallback onTap;

  const _FinanceCard({
    required this.icon,
    required this.title,
    required this.iconColor,
    required this.iconBgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.06),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(height: 14),
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Liste tipi finans kartı (diğer işlemler için)
class _FinanceListTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconColor;
  final VoidCallback onTap;

  const _FinanceListTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.06),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
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
}
