import 'package:flutter/material.dart';
import '../../../../core/extensions/l10n_extensions.dart';
import '../../../../core/utils/currency_formatter.dart';

/// Kategori Bazlı Bütçe Detay Sayfası
/// Dashboard'dan BudgetStatusCard'a tıklandığında açılır
/// Tüm kategorilerin bütçe durumunu detaylı gösterir
class CategoryBudgetDetailPage extends StatelessWidget {
  final Map<String, double> categoryBudgets;
  final Map<String, double> categoryExpenses;
  final double totalBudget;
  final double totalExpense;

  const CategoryBudgetDetailPage({
    super.key,
    required this.categoryBudgets,
    required this.categoryExpenses,
    required this.totalBudget,
    required this.totalExpense,
  });

  @override
  Widget build(BuildContext context) {
    // Kategorileri kullanım oranına göre sırala
    final sortedCategories = _getSortedCategories();

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.categoryBudgets),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Genel Bütçe Özeti
            _buildOverallSummary(context),
            const SizedBox(height: 24),

            // Kategori Listesi Başlığı
            Text(
              context.l10n.categoryBasedUsage,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),

            // Kategori Listesi
            ...sortedCategories.map((cat) => _buildCategoryCard(context, cat)),

            // Limitsiz kategoriler
            if (_getUnlimitedCategories().isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(
                context.l10n.unlimitedCategories,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 12),
              ..._getUnlimitedCategories().map(
                (cat) => _buildUnlimitedCategoryCard(context, cat),
              ),
            ],

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildOverallSummary(BuildContext context) {
    final usage = totalBudget > 0 ? totalExpense / totalBudget : 0.0;
    final remaining = totalBudget - totalExpense;
    final isOverBudget = remaining < 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isOverBudget
              ? [
                  Colors.red.shade900.withValues(alpha: 0.3),
                  Colors.red.shade800.withValues(alpha: 0.2),
                ]
              : [
                  Colors.purple.shade900.withValues(alpha: 0.3),
                  Colors.purple.shade800.withValues(alpha: 0.2),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isOverBudget
              ? Colors.red.withValues(alpha: 0.3)
              : Colors.purple.withValues(alpha: 0.3),
        ),
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
                    context.l10n.totalBudget,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    CurrencyFormatter.format(totalBudget),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: _getUsageColor(usage).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${(usage * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _getUsageColor(usage),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: usage.clamp(0.0, 1.0),
              minHeight: 12,
              backgroundColor: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(_getUsageColor(usage)),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.l10n.spentAmount(
                  CurrencyFormatter.format(totalExpense),
                ),
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              Text(
                isOverBudget
                    ? context.l10n.exceeded(
                        CurrencyFormatter.format(-remaining),
                      )
                    : context.l10n.remaining(
                        CurrencyFormatter.format(remaining),
                      ),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isOverBudget ? Colors.red : Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, _CategoryData data) {
    final isOverBudget = data.usage > 1.0;
    final remaining = data.limit - data.expense;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isOverBudget
              ? Colors.red.withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  context.translateDbName(data.kategori),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _getUsageColor(data.usage).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isOverBudget
                      ? context.l10n.exceededPercent(
                          (data.usage * 100).toStringAsFixed(0),
                        )
                      : '${(data.usage * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _getUsageColor(data.usage),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: data.usage.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(
                _getUsageColor(data.usage),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${CurrencyFormatter.format(data.expense)} / ${CurrencyFormatter.format(data.limit)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              Text(
                isOverBudget
                    ? context.l10n.exceeded(
                        CurrencyFormatter.format(-remaining),
                      )
                    : context.l10n.remaining(
                        CurrencyFormatter.format(remaining),
                      ),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isOverBudget
                      ? Colors.red.shade400
                      : Colors.green.shade400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUnlimitedCategoryCard(
    BuildContext context,
    MapEntry<String, double> entry,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            context.translateDbName(entry.key),
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          Text(
            CurrencyFormatter.format(entry.value),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  List<_CategoryData> _getSortedCategories() {
    final categories = <_CategoryData>[];

    for (final entry in categoryBudgets.entries) {
      if (entry.value <= 0) continue;
      final expense = categoryExpenses[entry.key] ?? 0.0;
      final usage = expense / entry.value;
      categories.add(
        _CategoryData(
          kategori: entry.key,
          limit: entry.value,
          expense: expense,
          usage: usage,
        ),
      );
    }

    // Kullanım oranına göre sırala (en yüksek önce)
    categories.sort((a, b) => b.usage.compareTo(a.usage));
    return categories;
  }

  List<MapEntry<String, double>> _getUnlimitedCategories() {
    final unlimited = <MapEntry<String, double>>[];

    for (final entry in categoryExpenses.entries) {
      final hasLimit =
          categoryBudgets.containsKey(entry.key) &&
          categoryBudgets[entry.key]! > 0;
      if (!hasLimit && entry.value > 0) {
        unlimited.add(entry);
      }
    }

    unlimited.sort((a, b) => b.value.compareTo(a.value));
    return unlimited;
  }

  Color _getUsageColor(double usage) {
    if (usage > 1.0) return Colors.red.shade400;
    if (usage > 0.8) return Colors.orange.shade400;
    if (usage > 0.5) return Colors.amber.shade600;
    return Colors.green.shade400;
  }
}

class _CategoryData {
  final String kategori;
  final double limit;
  final double expense;
  final double usage;

  _CategoryData({
    required this.kategori,
    required this.limit,
    required this.expense,
    required this.usage,
  });
}
