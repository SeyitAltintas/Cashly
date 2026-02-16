import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../core/di/injection_container.dart';
import '../../../../expenses/domain/repositories/expense_repository.dart';
import '../../../../../core/widgets/app_snackbar.dart';

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
    // Format initial value with thousand separators
    String initialText = '';
    if (currentLimit > 0) {
      initialText = _formatWithThousandSeparator(
        currentLimit.toStringAsFixed(0),
      );
    }
    final controller = TextEditingController(text: initialText);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Theme.of(dialogContext).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D32).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.edit, color: Color(0xFF2E7D32), size: 20),
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
              'Bu kategori için aylık harcama limiti belirleyin. Limit aşıldığında ana sayfada uyarı görürsünüz.',
              style: TextStyle(
                color: Theme.of(
                  dialogContext,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                _ThousandSeparatorFormatter(),
                LengthLimitingTextInputFormatter(
                  14,
                ), // Max 10.000.000.000 (10M formatted)
              ],
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Inter',
              ),
              decoration: InputDecoration(
                labelText: 'Aylık Limit',
                labelStyle: TextStyle(
                  color: Theme.of(
                    dialogContext,
                  ).colorScheme.onSurface.withValues(alpha: 0.8),
                  fontFamily: 'Inter',
                ),
                hintText: '0 = Limitsiz',
                hintStyle: TextStyle(
                  fontSize: 14,
                  color: Theme.of(
                    dialogContext,
                  ).colorScheme.onSurface.withValues(alpha: 0.4),
                  fontFamily: 'Inter',
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: Theme.of(
                      dialogContext,
                    ).colorScheme.onSurface.withValues(alpha: 0.15),
                    width: 0.5,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: Theme.of(
                      dialogContext,
                    ).colorScheme.onSurface.withValues(alpha: 0.15),
                    width: 0.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: Theme.of(
                      dialogContext,
                    ).colorScheme.onSurface.withValues(alpha: 0.4),
                    width: 1,
                  ),
                ),
                prefixIcon: Icon(
                  Icons.account_balance_wallet_outlined,
                  color: Theme.of(
                    dialogContext,
                  ).colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                suffixText: '₺',
                suffixStyle: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(
                    dialogContext,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          if (currentLimit > 0)
            TextButton.icon(
              onPressed: () async {
                final navigator = Navigator.of(dialogContext);
                await _saveBudget(kategori, 0);
                if (!mounted) return;
                navigator.pop();
                AppSnackBar.success(context, '$kategori limiti kaldırıldı');
              },
              icon: const Icon(Icons.delete_outline, size: 18),
              label: const Text('Limiti Kaldır'),
              style: TextButton.styleFrom(foregroundColor: Colors.orange),
            ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: () async {
              final navigator = Navigator.of(dialogContext);
              // Parse value removing thousand separators
              final cleanText = controller.text.replaceAll('.', '');
              final value = double.tryParse(cleanText) ?? 0;

              // Edge case: Maximum limit control
              if (value > 10000000000) {
                AppSnackBar.warning(
                  context,
                  'Maximum 10 milyar ₺ limit belirleyebilirsiniz',
                );
                return;
              }

              await _saveBudget(kategori, value);
              if (!mounted) return;
              navigator.pop();
              if (value > 0) {
                AppSnackBar.success(
                  context,
                  '$kategori limiti ${_formatWithThousandSeparator(value.toStringAsFixed(0))}₺ olarak ayarlandı',
                );
              }
            },
            icon: const Icon(Icons.check, size: 18),
            label: const Text('Kaydet'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
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
                  color: const Color(0xFF2E7D32).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF2E7D32).withValues(alpha: 0.3),
                    width: 0.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Color(0xFF2E7D32),
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$activeBudgets aktif',
                      style: const TextStyle(
                        color: Color(0xFF2E7D32),
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
                color: Theme.of(
                  context,
                ).colorScheme.surface.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.1),
                  width: 0.5,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.06),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.info_outline,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.5),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Her kategori için aylık harcama limiti belirleyin. Limit yaklaştığında veya aşıldığında ana sayfada uyarı göreceksiniz.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.7),
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
                  final iconColor = _getCategoryColor(index);

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
                              color: Theme.of(context).colorScheme.onSurface
                                  .withValues(alpha: hasLimit ? 0.15 : 0.08),
                              width: 0.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: iconColor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  _getIconData(
                                    kategori['ikon'] as String? ?? 'category',
                                  ),
                                  color: iconColor,
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
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withValues(
                                              alpha: hasLimit ? 0.6 : 0.4,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                hasLimit
                                    ? Icons.edit
                                    : Icons.add_circle_outline,
                                color: Theme.of(context).colorScheme.onSurface
                                    .withValues(alpha: hasLimit ? 0.5 : 0.3),
                                size: 20,
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

  /// Kategori için rastgele renk döndür (index tabanlı tutarlı)
  Color _getCategoryColor(int index) {
    const colors = [
      Color(0xFFE57373), // Kırmızı
      Color(0xFF81C784), // Yeşil
      Color(0xFF64B5F6), // Mavi
      Color(0xFFFFB74D), // Turuncu
      Color(0xFFBA68C8), // Mor
      Color(0xFF4DD0E1), // Cyan
      Color(0xFFF06292), // Pembe
      Color(0xFFAED581), // Açık yeşil
      Color(0xFF7986CB), // İndigo
      Color(0xFFFFD54F), // Sarı
      Color(0xFFA1887F), // Kahverengi
      Color(0xFF90A4AE), // Gri-mavi
    ];
    return colors[index % colors.length];
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

  /// Binlik ayıraç ile formatla (1000 -> 1.000)
  String _formatWithThousandSeparator(String value) {
    if (value.isEmpty) return '';

    // Sadece rakamları al
    final digitsOnly = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.isEmpty) return '';

    // Baştaki sıfırları kaldır (tek sıfır hariç)
    final trimmed = digitsOnly.replaceFirst(RegExp(r'^0+'), '');
    if (trimmed.isEmpty) return '0';

    // Binlik ayıraç ekle
    final buffer = StringBuffer();
    for (int i = 0; i < trimmed.length; i++) {
      if (i > 0 && (trimmed.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(trimmed[i]);
    }
    return buffer.toString();
  }
}

/// Binlik ayıraç ekleyen TextInputFormatter
class _ThousandSeparatorFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Sadece rakamları al
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    // Baştaki sıfırları kaldır (tek sıfır hariç)
    String trimmed = digitsOnly.replaceFirst(RegExp(r'^0+'), '');
    if (trimmed.isEmpty) trimmed = '0';

    // Binlik ayıraç ekle
    final buffer = StringBuffer();
    for (int i = 0; i < trimmed.length; i++) {
      if (i > 0 && (trimmed.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(trimmed[i]);
    }

    final formatted = buffer.toString();

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
