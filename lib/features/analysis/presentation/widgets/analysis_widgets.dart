import 'package:flutter/material.dart';
import '../../../../core/utils/currency_formatter.dart';

/// Analiz Boş Durumu Widget'ı
/// Veri yokken gösterilir
class AnalysisEmptyState extends StatelessWidget {
  final String message;
  final String? actionText;
  final VoidCallback? onActionPressed;
  final IconData? icon;

  const AnalysisEmptyState({
    super.key,
    required this.message,
    this.actionText,
    this.onActionPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon ?? Icons.bar_chart_rounded,
              size: 70,
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (actionText != null && onActionPressed != null) ...[
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: onActionPressed,
              icon: const Icon(Icons.add_circle_outline, size: 20),
              label: Text(actionText!),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Kategori Legend Item Widget'ı
/// Pasta grafiği altında kategori listesi için kullanılır
class LegendItem extends StatelessWidget {
  final String title;
  final double value;
  final Color color;
  final double total;
  final double? budgetLimit; // Opsiyonel limit

  const LegendItem({
    super.key,
    required this.title,
    required this.value,
    required this.color,
    required this.total,
    this.budgetLimit,
  });

  @override
  Widget build(BuildContext context) {
    final hasLimit = budgetLimit != null && budgetLimit! > 0;
    final isOverBudget = hasLimit && value > budgetLimit!;
    final usagePercent = hasLimit ? (value / budgetLimit! * 100) : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 16,
                  ),
                ),
                if (hasLimit)
                  Text(
                    'Limit: ${CurrencyFormatter.format(budgetLimit!)} (${usagePercent.toStringAsFixed(0)}%)',
                    style: TextStyle(
                      fontSize: 11,
                      color: isOverBudget
                          ? Colors.red.shade400
                          : usagePercent > 80
                          ? Colors.orange.shade400
                          : Colors.green.shade400,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                CurrencyFormatter.format(value),
                style: TextStyle(
                  color: isOverBudget
                      ? Colors.red.shade400
                      : Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "%${(value / total * 100).toStringAsFixed(1)}",
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.54),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Analiz Başlık Kartı Widget'ı
/// Her analiz türü için başlık ve özet bilgi gösterir
class AnalysisHeaderCard extends StatelessWidget {
  final String title;
  final String totalAmount;
  final Color primaryColor;
  final IconData icon;
  final String topCategoryLabel;
  final String topCategoryName;
  final String topCategoryAmount;

  const AnalysisHeaderCard({
    super.key,
    required this.title,
    required this.totalAmount,
    required this.primaryColor,
    required this.icon,
    required this.topCategoryLabel,
    required this.topCategoryName,
    required this.topCategoryAmount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primaryColor.withValues(alpha: 0.3),
            primaryColor.withValues(alpha: 0.15),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primaryColor.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.7),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    totalAmount,
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(icon, color: primaryColor, size: 28),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.surface.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  icon == Icons.trending_up ? Icons.emoji_events : Icons.star,
                  color: primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 13,
                      ),
                      children: [
                        TextSpan(text: "$topCategoryLabel: "),
                        TextSpan(
                          text: topCategoryName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: " ($topCategoryAmount)",
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
