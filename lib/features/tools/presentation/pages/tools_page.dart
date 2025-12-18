import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/theme_manager.dart';

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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 500),
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
                      "Araçlar",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Finansal araçlarınıza hızlıca erişin",
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Tool Cards
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.0,
                  children: [
                    _buildToolCard(
                      context,
                      icon: Icons.account_balance_wallet,
                      title: "Varlıklarım",
                      subtitle: "Varlıklarınızı yönetin",
                      gradientColors:
                          context.watch<ThemeManager>().isDefaultTheme
                          ? [
                              const Color(0xFF1a1a2e),
                              const Color(0xFF16213e),
                              const Color(0xFF0f3460),
                            ]
                          : [
                              Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.3),
                              Theme.of(
                                context,
                              ).colorScheme.secondary.withValues(alpha: 0.15),
                            ],
                      onTap: onAssetsPressed,
                      delay: 100,
                    ),
                    _buildToolCard(
                      context,
                      icon: Icons.pie_chart,
                      title: "Analiz ve\nRaporlar",
                      subtitle: "Detaylı analizler",
                      gradientColors:
                          context.watch<ThemeManager>().isDefaultTheme
                          ? [
                              const Color(0xFF1a1a2e),
                              const Color(0xFF2d132c),
                              const Color(0xFF432371),
                            ]
                          : [
                              Theme.of(
                                context,
                              ).colorScheme.secondary.withValues(alpha: 0.3),
                              Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.15),
                            ],
                      onTap: onAnalysisPressed,
                      delay: 200,
                    ),
                    _buildToolCard(
                      context,
                      icon: Icons.credit_card,
                      title: "Ödeme\nYöntemlerim",
                      subtitle: "Kartlarınızı yönetin",
                      gradientColors:
                          context.watch<ThemeManager>().isDefaultTheme
                          ? [
                              const Color(0xFF1a1a2e),
                              const Color(0xFF0f3460),
                              const Color(0xFF16537e),
                            ]
                          : [
                              Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.25),
                              Theme.of(
                                context,
                              ).colorScheme.secondary.withValues(alpha: 0.2),
                            ],
                      onTap: onPaymentMethodsPressed,
                      delay: 300,
                    ),
                    _buildToolCard(
                      context,
                      icon: Icons.swap_horiz,
                      title: "Para\nTransferi",
                      subtitle: "Hesaplar arası transfer",
                      gradientColors:
                          context.watch<ThemeManager>().isDefaultTheme
                          ? [
                              const Color(0xFF1a1a2e),
                              const Color(0xFF16213e),
                              const Color(0xFF432371),
                            ]
                          : [
                              Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.15),
                              Theme.of(
                                context,
                              ).colorScheme.secondary.withValues(alpha: 0.3),
                            ],
                      onTap: onTransferPressed,
                      delay: 400,
                    ),
                    // Harcamalarım - Yeni eklendi
                    if (onExpensesPressed != null)
                      _buildToolCard(
                        context,
                        icon: Icons.receipt_long,
                        title: "Harcamalarım",
                        subtitle: "Harcamalarınızı yönetin",
                        gradientColors:
                            context.watch<ThemeManager>().isDefaultTheme
                            ? [
                                const Color(0xFF1a1a2e),
                                const Color(0xFF3d1f1f),
                                const Color(0xFF5c2323),
                              ]
                            : [
                                Colors.red.shade900.withValues(alpha: 0.3),
                                Colors.red.shade700.withValues(alpha: 0.15),
                              ],
                        onTap: onExpensesPressed!,
                        delay: 500,
                      ),
                    // Gelirlerim - Yeni eklendi
                    if (onIncomesPressed != null)
                      _buildToolCard(
                        context,
                        icon: Icons.trending_up,
                        title: "Gelirlerim",
                        subtitle: "Gelirlerinizi yönetin",
                        gradientColors:
                            context.watch<ThemeManager>().isDefaultTheme
                            ? [
                                const Color(0xFF1a1a2e),
                                const Color(0xFF1f3d1f),
                                const Color(0xFF235c23),
                              ]
                            : [
                                Colors.green.shade900.withValues(alpha: 0.3),
                                Colors.green.shade700.withValues(alpha: 0.15),
                              ],
                        onTap: onIncomesPressed!,
                        delay: 600,
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

  Widget _buildToolCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Color> gradientColors,
    required VoidCallback onTap,
    required int delay,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 500 + delay),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.scale(scale: 0.8 + (0.2 * value), child: child),
        );
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [gradientColors[0], gradientColors[1]],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.08),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: gradientColors[0].withValues(alpha: 0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                  spreadRadius: -3,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Icon(
                        icon,
                        color: Theme.of(context).colorScheme.secondary,
                        size: 30,
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.7),
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
