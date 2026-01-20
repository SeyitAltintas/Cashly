import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/di/injection_container.dart';
import '../../../expenses/domain/repositories/expense_repository.dart';
import '../../../../core/widgets/app_snackbar.dart';

/// Kategori Bütçe Limitleri Sayfası
/// Ayarlar > Gider Ayarları > Kategori Bütçeleri'nden açılır
/// Tam sayfa olarak tüm kategorilerin limitlerini yönetir
class CategoryBudgetPage extends StatefulWidget {
  final String userId;

  const CategoryBudgetPage({super.key, required this.userId});

  @override
  State<CategoryBudgetPage> createState() => _CategoryBudgetPageState();
}

class _CategoryBudgetPageState extends State<CategoryBudgetPage> {
  late List<Map<String, dynamic>> _kategoriler;
  late Map<String, double> _categoryBudgets;
  bool _isLoading = true;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final expenseRepo = getIt<ExpenseRepository>();
    _kategoriler = expenseRepo.getCategories(widget.userId);
    _categoryBudgets = Map.from(expenseRepo.getCategoryBudgets(widget.userId));
    setState(() => _isLoading = false);
  }

  Future<void> _saveBudget(String kategori, double limit) async {
    final expenseRepo = getIt<ExpenseRepository>();

    if (limit > 0) {
      _categoryBudgets[kategori] = limit;
    } else {
      _categoryBudgets.remove(kategori);
    }

    await expenseRepo.saveCategoryBudgets(widget.userId, _categoryBudgets);
    setState(() => _hasChanges = true);
  }

  void _showEditDialog(String kategori, double currentLimit) {
    final controller = TextEditingController(
      text: currentLimit > 0 ? currentLimit.toStringAsFixed(0) : '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.purple.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.edit, color: Colors.purple, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                kategori,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bu kategori için aylık harcama limiti belirleyin. Limit aşıldığında dashboard\'da uyarı görürsünüz.',
              style: TextStyle(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                labelText: 'Aylık Limit',
                hintText: '0 = Limitsiz',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                prefixIcon: const Icon(Icons.account_balance_wallet_outlined),
                suffixText: '₺',
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          if (currentLimit > 0)
            TextButton.icon(
              onPressed: () async {
                await _saveBudget(kategori, 0);
                if (mounted) {
                  Navigator.pop(context);
                  AppSnackBar.success(context, '$kategori limiti kaldırıldı');
                }
              },
              icon: const Icon(Icons.delete_outline, size: 18),
              label: const Text('Kaldır'),
              style: TextButton.styleFrom(foregroundColor: Colors.orange),
            ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: () async {
              final value = double.tryParse(controller.text) ?? 0;
              await _saveBudget(kategori, value);
              if (mounted) {
                Navigator.pop(context);
                if (value > 0) {
                  AppSnackBar.success(
                    context,
                    '$kategori limiti ${value.toStringAsFixed(0)}₺ olarak ayarlandı',
                  );
                }
              }
            },
            icon: const Icon(Icons.check, size: 18),
            label: const Text('Kaydet'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final activeBudgets = _categoryBudgets.entries
        .where((e) => e.value > 0)
        .length;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.pop(context, _hasChanges);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Kategori Bütçeleri'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context, _hasChanges),
          ),
          actions: [
            if (activeBudgets > 0)
              Container(
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.purple.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Colors.purple,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$activeBudgets aktif',
                      style: const TextStyle(
                        color: Colors.purple,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        body: Column(
          children: [
            // Bilgilendirme kartı
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.purple.shade900.withValues(alpha: 0.3),
                    Colors.purple.shade800.withValues(alpha: 0.2),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.purple.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.purple.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.info_outline,
                      color: Colors.purple,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Her kategori için aylık harcama limiti belirleyin. Limit yaklaştığında veya aşıldığında dashboard\'da uyarı göreceksiniz.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Kategori listesi
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _kategoriler.length,
                itemBuilder: (context, index) {
                  final kategori = _kategoriler[index];
                  final isim = kategori['isim'] as String;
                  final limit = _categoryBudgets[isim] ?? 0.0;
                  final hasLimit = limit > 0;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _showEditDialog(isim, limit),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.surface.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: hasLimit
                                  ? Colors.purple.withValues(alpha: 0.3)
                                  : Colors.white.withValues(alpha: 0.1),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: hasLimit
                                      ? Colors.purple.withValues(alpha: 0.2)
                                      : Colors.grey.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  _getIconData(
                                    kategori['ikon'] as String? ?? 'category',
                                  ),
                                  color: hasLimit ? Colors.purple : Colors.grey,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      isim,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      hasLimit
                                          ? '${limit.toStringAsFixed(0)}₺ aylık limit'
                                          : 'Limit belirlenmemiş',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: hasLimit
                                            ? Colors.purple
                                            : Theme.of(context)
                                                  .colorScheme
                                                  .onSurface
                                                  .withValues(alpha: 0.5),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                hasLimit
                                    ? Icons.edit
                                    : Icons.add_circle_outline,
                                color: hasLimit
                                    ? Colors.purple
                                    : Theme.of(context).colorScheme.onSurface
                                          .withValues(alpha: 0.4),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconData(String iconName) {
    const iconMap = {
      'restaurant': Icons.restaurant,
      'shopping_basket': Icons.shopping_basket,
      'two_wheeler': Icons.two_wheeler,
      'card_giftcard': Icons.card_giftcard,
      'credit_card': Icons.credit_card,
      'category': Icons.category,
      'directions_car': Icons.directions_car,
      'movie': Icons.movie,
      'local_hospital': Icons.local_hospital,
      'shopping_bag': Icons.shopping_bag,
      'school': Icons.school,
      'receipt': Icons.receipt,
      'autorenew': Icons.autorenew,
    };
    return iconMap[iconName] ?? Icons.category;
  }
}
