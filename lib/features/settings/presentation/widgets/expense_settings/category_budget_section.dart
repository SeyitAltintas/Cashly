import 'package:flutter/material.dart';
import '../../../../../core/di/injection_container.dart';
import '../../../../expenses/domain/repositories/expense_repository.dart';
import '../../pages/category_budget_page.dart';

/// Kategori bazlı bütçe limitleri section widget'ı
/// Tıklandığında CategoryBudgetPage'e yönlendirir
class CategoryBudgetSection extends StatefulWidget {
  final String userId;
  final VoidCallback? onChanged;

  const CategoryBudgetSection({
    super.key,
    required this.userId,
    this.onChanged,
  });

  @override
  State<CategoryBudgetSection> createState() => _CategoryBudgetSectionState();
}

class _CategoryBudgetSectionState extends State<CategoryBudgetSection> {
  int _activeBudgets = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final expenseRepo = getIt<ExpenseRepository>();
    final categoryBudgets = expenseRepo.getCategoryBudgets(widget.userId);
    _activeBudgets = categoryBudgets.entries.where((e) => e.value > 0).length;
    setState(() => _isLoading = false);
  }

  Future<void> _openCategoryBudgetPage() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryBudgetPage(userId: widget.userId),
      ),
    );

    // Eğer değişiklik yapıldıysa yenile
    if (result == true) {
      _loadData();
      widget.onChanged?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _openCategoryBudgetPage,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.purple.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.pie_chart_outline_rounded,
                    color: Colors.purple,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Kategori Bütçeleri',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _activeBudgets > 0
                            ? '$_activeBudgets kategori için limit belirlenmiş'
                            : 'Kategorilere özel limit belirleyin',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
