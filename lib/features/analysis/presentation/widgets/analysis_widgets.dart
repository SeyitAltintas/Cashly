import 'package:flutter/material.dart';
import '../../../../core/utils/currency_formatter.dart';
import 'package:cashly/core/extensions/l10n_extensions.dart';

/// Analiz Boş Durumu Widget'ı
/// Veri yokken gösterilir
class AnalysisEmptyState extends StatelessWidget {
  final String message;
  final String? actionText;
  final VoidCallback? onActionPressed;
  final IconData? icon;
  final Color? buttonColor;

  const AnalysisEmptyState({
    super.key,
    required this.message,
    this.actionText,
    this.onActionPressed,
    this.icon,
    this.buttonColor,
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
                backgroundColor:
                    buttonColor ?? Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
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

/// Akıllı Trend ve Kıyaslama Kartı
/// Önceki aya göre kıyaslama yapar ve gösterir.
class TrendInsightCard extends StatelessWidget {
  final double currentAmount;
  final double previousAmount;
  final String title;
  final bool isExpense;
  final String increaseText;
  final String decreaseText;
  final String noChangeText;

  // Eklenen Yeni Alanlar (En Çok Kategoriler vs)
  final String? topCategoryLabel;
  final String? topCategoryName;
  final String? topCategoryAmount;
  final String? noteText;

  const TrendInsightCard({
    super.key,
    required this.currentAmount,
    required this.previousAmount,
    required this.title,
    this.isExpense = true,
    required this.increaseText,
    required this.decreaseText,
    required this.noChangeText,
    this.topCategoryLabel,
    this.topCategoryName,
    this.topCategoryAmount,
    this.noteText,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasPreviousData = previousAmount > 0;

    // Geçen aydan veri yoksa ve top kategoriler de verilmemişse hiçbir şey gösterme
    if (!hasPreviousData && topCategoryLabel == null) {
      return const SizedBox.shrink();
    }

    final double diff = currentAmount - previousAmount;
    final double percent = (diff / previousAmount).abs() * 100;

    // Yön tespiti
    final bool isIncreased = diff > 0;
    final bool isDecreased = diff < 0;

    // Renk ve ikonlar harcama/gelir durumuna göre değişir
    // Harcama artarsa kötü (kırmızı), Gelir artarsa iyi (yeşil)
    Color iconColor = Colors.grey;
    IconData icon = Icons.trending_flat;
    String message = noChangeText;

    if (isIncreased) {
      iconColor = isExpense ? Colors.red.shade400 : Colors.green.shade400;
      icon = Icons.trending_up;
      message = increaseText.replaceAll(
        '{percent}',
        percent.toStringAsFixed(1),
      );
    } else if (isDecreased) {
      iconColor = isExpense ? Colors.green.shade400 : Colors.red.shade400;
      icon = Icons.trending_down;
      message = decreaseText.replaceAll(
        '{percent}',
        percent.toStringAsFixed(1),
      );
    }

    if (!hasPreviousData) {
      message = "Geçen aya ait veri yok";
      iconColor = Colors.grey;
    }

    return Container(
      height: 120, // Liste kaydırma için sabit yükseklik
      margin: const EdgeInsets.only(bottom: 24),
      child: ListView(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        children: [
          // Gidişat Kartı (Mevcut olan - Yalnızca öneki ay varsa gösterilir)
          if (hasPreviousData) ...[
            Container(
              width:
                  MediaQuery.of(context).size.width *
                  0.75, // Ekranın %75'i kadar
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.surface.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: iconColor.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: iconColor),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          message,
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (noteText != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            noteText!,
                            style: TextStyle(
                              fontSize: 11,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
          ],

          // En Çok Harcama / Gelir Kartı (Sağa Kaydırılabilir veya Tek)
          if (topCategoryLabel != null &&
              topCategoryName != null &&
              topCategoryAmount != null)
            Container(
              width:
                  MediaQuery.of(context).size.width *
                  0.65, // Ekranın %65'i kadar
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.surface.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color:
                      (isExpense ? Colors.red.shade400 : Colors.green.shade400)
                          .withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color:
                          (isExpense
                                  ? Colors.red.shade400
                                  : Colors.green.shade400)
                              .withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isExpense ? Icons.emoji_events : Icons.star,
                      color: isExpense
                          ? Colors.red.shade400
                          : Colors.green.shade400,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          topCategoryLabel!,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          topCategoryName!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          topCategoryAmount!,
                          style: TextStyle(
                            fontSize: 13,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.7),
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
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

/// Kategori Legend Item Widget'ı
/// Pasta grafiği altında kategori listesi için kullanılır
class LegendItem extends StatelessWidget {
  final String title;
  final double value;
  final Color color;
  final double total;
  final double? budgetLimit; // Opsiyonel limit
  final IconData? icon; // Kategori için isteğe bağlı ikon
  final VoidCallback? onTap;
  final bool isExpense; // Harcama durumu

  const LegendItem({
    super.key,
    required this.title,
    required this.value,
    required this.color,
    required this.total,
    this.budgetLimit,
    this.icon,
    this.onTap,
    this.isExpense = false,
  });

  @override
  Widget build(BuildContext context) {
    final hasLimit = budgetLimit != null && budgetLimit! > 0;
    final isOverBudget = hasLimit && value > budgetLimit!;
    final usagePercent = hasLimit ? (value / budgetLimit! * 100) : 0.0;
    final ratio = total > 0 ? (value / total).clamp(0.0, 1.0) : 0.0;

    Color progressColor = color;
    if (isExpense) {
      if (hasLimit) {
        progressColor = isOverBudget
            ? Colors.red.shade400
            : usagePercent > 80
            ? Colors.orange.shade400
            : Colors.green.shade400;
      } else {
        if (ratio < 0.15) {
          progressColor = Colors.green.shade400;
        } else if (ratio < 0.40) {
          progressColor = Colors.yellow.shade600;
        } else if (ratio < 0.70) {
          progressColor = Colors.orange.shade400;
        } else {
          progressColor = Colors.red.shade400;
        }
      }
    } else {
      progressColor = color;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // İkon Alanı (Dairesel ve Yumuşak)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon ?? Icons.circle, color: color, size: 24),
                ),
                const SizedBox(width: 16),

                // Metin Alanı
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            CurrencyFormatter.format(value),
                            style: TextStyle(
                              color: isOverBudget
                                  ? Colors.red.shade400
                                  : Theme.of(context).colorScheme.onSurface,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "${(ratio * 100).toStringAsFixed(1)}%",
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.5),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (hasLimit)
                            Text(
                              '${context.l10n.total} ${CurrencyFormatter.format(budgetLimit!)}',
                              style: TextStyle(
                                color: isOverBudget
                                    ? Colors.red.shade400
                                    : Theme.of(context).colorScheme.onSurface
                                          .withValues(alpha: 0.5),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // İnce ve Şık Progress Bar (Track/Ayraç görevi görüyor)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: hasLimit
                    ? (value / budgetLimit!).clamp(0.0, 1.0)
                    : ratio,
                minHeight: 6,
                backgroundColor: color.withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
