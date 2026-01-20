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
                    color: const Color(0xFF4DD0E1).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.pie_chart_outline_rounded,
                    color: Color(0xFF4DD0E1),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  "Kategori Bütçeleri",
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
            onTap: _openCategoryBudgetPage,
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
                          'Kategorilere özel limit belirleyin',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _activeBudgets > 0
                              ? '$_activeBudgets kategori için limit belirlenmiş'
                              : 'Henüz limit belirlenmemiş',
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
