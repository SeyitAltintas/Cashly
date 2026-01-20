import 'package:flutter/material.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/animated_card.dart';

/// Bütçe Durumu Kartı Widget'ı
/// Bütçe limiti, kullanım oranını ve kategori bazlı limitleri gösterir
/// Tıklandığında detay sayfasına yönlendirir
class BudgetStatusCard extends StatelessWidget {
  final double monthlyExpense;
  final double butceLimiti;
  final Map<String, double>? categoryBudgets;
  final Map<String, double>? categoryExpenses;
  final VoidCallback? onTap;

  const BudgetStatusCard({
    super.key,
    required this.monthlyExpense,
    required this.butceLimiti,
    this.categoryBudgets,
    this.categoryExpenses,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final budgetUsed = butceLimiti > 0 ? (monthlyExpense / butceLimiti) : 0.0;

    // Limiti aşan veya %80'i geçen kategorileri bul
    final warningCategories = _getWarningCategories();

    return GestureDetector(
      onTap: onTap,
      child: AnimatedCard(
        delay: 300,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.08),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Global bütçe durumu
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Bütçe Durumu",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    "${(budgetUsed * 100).toStringAsFixed(0)}%",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: _getStatusColor(budgetUsed),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: budgetUsed.clamp(0.0, 1.0),
                  minHeight: 10,
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getStatusColor(budgetUsed),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${CurrencyFormatter.formatWithoutSymbol(monthlyExpense)} ₺ harcandı",
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  Text(
                    "${CurrencyFormatter.formatWithoutSymbol(butceLimiti)} ₺ limit",
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),

              // Kategori uyarıları (varsa)
              if (warningCategories.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 12),
                Text(
                  "Kategori Limitleri",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 8),
                ...warningCategories.map(
                  (cat) => _buildCategoryWarning(context, cat),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  List<_CategoryWarningData> _getWarningCategories() {
    if (categoryBudgets == null || categoryExpenses == null) return [];

    final warnings = <_CategoryWarningData>[];

    for (final entry in categoryBudgets!.entries) {
      final kategori = entry.key;
      final limit = entry.value;
      if (limit <= 0) continue;

      final expense = categoryExpenses![kategori] ?? 0.0;
      final usage = expense / limit;

      // %70'i geçenleri göster
      if (usage >= 0.7) {
        warnings.add(
          _CategoryWarningData(
            kategori: kategori,
            expense: expense,
            limit: limit,
            usage: usage,
          ),
        );
      }
    }

    // Kullanım oranına göre sırala (en yükseği önce)
    warnings.sort((a, b) => b.usage.compareTo(a.usage));

    // En fazla 3 kategori göster
    return warnings.take(3).toList();
  }

  Widget _buildCategoryWarning(
    BuildContext context,
    _CategoryWarningData data,
  ) {
    final isOverBudget = data.usage > 1.0;
    final color = isOverBudget
        ? Colors.red.shade400
        : data.usage > 0.9
        ? Colors.orange.shade400
        : Colors.amber.shade600;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              data.kategori,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
          ),
          Text(
            isOverBudget
                ? "Aşıldı! (${(data.usage * 100).toStringAsFixed(0)}%)"
                : "${(data.usage * 100).toStringAsFixed(0)}%",
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(double budgetUsed) {
    if (budgetUsed > 0.8) return Colors.red.shade400;
    if (budgetUsed > 0.5) return Colors.orange.shade400;
    return Colors.green.shade400;
  }
}

class _CategoryWarningData {
  final String kategori;
  final double expense;
  final double limit;
  final double usage;

  _CategoryWarningData({
    required this.kategori,
    required this.expense,
    required this.limit,
    required this.usage,
  });
}
