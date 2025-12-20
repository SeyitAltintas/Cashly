import 'package:flutter/material.dart';
import '../../../../services/haptic_service.dart';

/// Tüm İşlemler Sayfası
/// Profesyonel finans uygulaması tasarımı
class ToolsPage extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          physics: const BouncingScrollPhysics(),
          children: [
            // Header
            _buildHeader(context),
            const SizedBox(height: 28),

            // Ana İşlemler Bölümü
            _buildSectionTitle(context, "Nakit Akışı"),
            const SizedBox(height: 14),

            // Harcama ve Gelir kartları (yan yana)
            Row(
              children: [
                if (onExpensesPressed != null)
                  Expanded(
                    child: _FinanceCard(
                      icon: Icons.arrow_downward_rounded,
                      title: "Harcamalarım",
                      iconColor: const Color(0xFFE53935),
                      iconBgColor: const Color(
                        0xFFE53935,
                      ).withValues(alpha: 0.12),
                      onTap: () {
                        HapticService.lightImpact();
                        onExpensesPressed!();
                      },
                    ),
                  ),
                if (onExpensesPressed != null && onIncomesPressed != null)
                  const SizedBox(width: 14),
                if (onIncomesPressed != null)
                  Expanded(
                    child: _FinanceCard(
                      icon: Icons.arrow_upward_rounded,
                      title: "Gelirlerim",
                      iconColor: const Color(0xFF43A047),
                      iconBgColor: const Color(
                        0xFF43A047,
                      ).withValues(alpha: 0.12),
                      onTap: () {
                        HapticService.lightImpact();
                        onIncomesPressed!();
                      },
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 24),

            // Hesaplarım Bölümü
            _buildSectionTitle(context, "Cüzdanım"),
            const SizedBox(height: 14),

            // Varlıklar ve Ödeme Yöntemleri
            _FinanceListTile(
              icon: Icons.account_balance_wallet_outlined,
              title: "Varlıklarım",
              subtitle: "Altın, döviz, kripto ve diğer varlıklar",
              iconColor: const Color(0xFF1E88E5),
              onTap: () {
                HapticService.lightImpact();
                onAssetsPressed();
              },
            ),
            const SizedBox(height: 10),
            _FinanceListTile(
              icon: Icons.credit_card_outlined,
              title: "Ödeme Yöntemlerim",
              subtitle: "Banka kartları ve nakit hesapları",
              iconColor: const Color(0xFF8E24AA),
              onTap: () {
                HapticService.lightImpact();
                onPaymentMethodsPressed();
              },
            ),

            const SizedBox(height: 24),

            // Araçlar Bölümü
            _buildSectionTitle(context, "Diğer İşlemler"),
            const SizedBox(height: 14),

            // Analiz ve Transfer
            _FinanceListTile(
              icon: Icons.insights_outlined,
              title: "Analiz ve Raporlar",
              subtitle: "Harcama ve gelir istatistikleri",
              iconColor: const Color(0xFFFF7043),
              onTap: () {
                HapticService.lightImpact();
                onAnalysisPressed();
              },
            ),
            const SizedBox(height: 10),
            _FinanceListTile(
              icon: Icons.sync_alt_rounded,
              title: "Para Transferi",
              subtitle: "Hesaplar arası para aktarımı",
              iconColor: const Color(0xFF00ACC1),
              onTap: () {
                HapticService.lightImpact();
                onTransferPressed();
              },
            ),

            const SizedBox(height: 100),
          ],
        ),
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
            "Tüm İşlemler",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Finansal işlemlerinizi yönetin",
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
