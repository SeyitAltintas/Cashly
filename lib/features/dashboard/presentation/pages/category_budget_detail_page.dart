import 'package:flutter/material.dart';
import '../../../../core/extensions/l10n_extensions.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/services/currency_service.dart';

/// Kategori Bazlı Bütçe Detay Sayfası
/// Dashboard'dan BudgetStatusCard'a tıklandığında açılır
/// Tüm kategorilerin bütçe durumunu detaylı gösterir
class CategoryBudgetDetailPage extends StatelessWidget {
  final Map<String, double> categoryBudgets;
  final Map<String, double> categoryExpenses;
  final double totalBudget;
  final double totalExpense;
  final List<Map<String, dynamic>>? rawExpenses;

  const CategoryBudgetDetailPage({
    super.key,
    required this.categoryBudgets,
    required this.categoryExpenses,
    required this.totalBudget,
    required this.totalExpense,
    this.rawExpenses,
  });

  @override
  Widget build(BuildContext context) {
    // Kategorileri kullanım oranına göre sırala
    final sortedCategories = _getSortedCategories(context);

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
            if (_getUnlimitedCategories(context).isNotEmpty) ...[
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
              ..._getUnlimitedCategories(
                context,
              ).map((cat) => _buildUnlimitedCategoryCard(context, cat)),
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

    return GestureDetector(
      onTap: () => _showCategoryDetails(context, data.kategori),
      behavior: HitTestBehavior.opaque,
      child: Container(
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
      ),
    );
  }

  Widget _buildUnlimitedCategoryCard(
    BuildContext context,
    MapEntry<String, double> entry,
  ) {
    return GestureDetector(
      onTap: () => _showCategoryDetails(context, entry.key),
      behavior: HitTestBehavior.opaque,
      child: Container(
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
      ),
    );
  }

  List<_CategoryData> _getSortedCategories(BuildContext context) {
    final categories = <_CategoryData>[];

    // Normalize expenses by translated name so English and Turkish keys merge
    final normalizedExpenses = <String, double>{};
    for (final entry in categoryExpenses.entries) {
      final key = context.translateDbName(entry.key);
      normalizedExpenses[key] = (normalizedExpenses[key] ?? 0.0) + entry.value;
    }

    // Normalize budgets
    final normalizedBudgets = <String, double>{};
    for (final entry in categoryBudgets.entries) {
      final key = context.translateDbName(entry.key);
      normalizedBudgets[key] = (normalizedBudgets[key] ?? 0.0) + entry.value;
    }

    for (final entry in normalizedBudgets.entries) {
      if (entry.value <= 0) continue;
      final expense = normalizedExpenses[entry.key] ?? 0.0;
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

  List<MapEntry<String, double>> _getUnlimitedCategories(BuildContext context) {
    final unlimited = <MapEntry<String, double>>[];

    final normalizedBudgets = <String, double>{};
    for (final entry in categoryBudgets.entries) {
      normalizedBudgets[context.translateDbName(entry.key)] = entry.value;
    }

    final normalizedExpenses = <String, double>{};
    for (final entry in categoryExpenses.entries) {
      final key = context.translateDbName(entry.key);
      normalizedExpenses[key] = (normalizedExpenses[key] ?? 0.0) + entry.value;
    }

    for (final entry in normalizedExpenses.entries) {
      final hasLimit =
          normalizedBudgets.containsKey(entry.key) &&
          normalizedBudgets[entry.key]! > 0;
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

  void _showCategoryDetails(BuildContext context, String categoryKey) {
    if (rawExpenses == null || rawExpenses!.isEmpty) return;

    final items = rawExpenses!.where((e) {
      final rawCat = e['kategori']?.toString() ?? 'Diğer';
      final translatedRaw = context.translateDbName(rawCat);
      final translatedTarget = context.translateDbName(categoryKey);

      return translatedRaw == translatedTarget || rawCat == categoryKey;
    }).toList();

    if (items.isEmpty) return;

    final currencyService = getIt<CurrencyService>();
    final currentCurrency = currencyService.currentCurrency;

    double totalAmount = items.fold(0.0, (sum, item) {
      final tutar = ((item['tutar'] as num?)?.toDouble() ?? 0.0);
      final pb = item['paraBirimi']?.toString() ?? 'TRY';
      return sum + currencyService.convert(tutar, pb, currentCurrency);
    });

    final currency = (items.first['paraBirimi']?.toString() ?? 'TRY');
    final categoryIcon = _getCategoryIcon(categoryKey);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        String searchQuery = '';
        return StatefulBuilder(
          builder: (context, setModalState) {
            final filteredItems = items.where((item) {
              if (searchQuery.isEmpty) return true;
              String title = item['isim']?.toString() ?? '';
              return title.toLowerCase().contains(searchQuery.toLowerCase());
            }).toList();

            return GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              behavior: HitTestBehavior.opaque,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.75,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(32),
                  ),
                ),
                child: Column(
                  children: [
                    // Sürükleme Çubuğu (Handle)
                    Center(
                      child: Container(
                        margin: const EdgeInsets.only(top: 12, bottom: 8),
                        height: 5,
                        width: 48,
                        decoration: BoxDecoration(
                          color: Colors.grey.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),

                    // Başlık ve Toplam Tutar
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: const BoxDecoration(
                              color: Colors.transparent,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              categoryIcon,
                              color: Colors.white.withValues(alpha: 0.8),
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  context.translateDbName(categoryKey),
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.5,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.05),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '${context.l10n.total} ${items.length} ${context.l10n.expense}',
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withValues(alpha: 0.6),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 18),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  "-${CurrencyFormatter.format(totalAmount, currency: currency)}",
                                  style: TextStyle(
                                    color: Colors.red.shade400,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 22,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Arama Çubuğu
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                      child: TextField(
                        onChanged: (val) =>
                            setModalState(() => searchQuery = val),
                        decoration: InputDecoration(
                          hintText: context.l10n.searchTransactions,
                          hintStyle: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.5),
                            fontSize: 15,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            size: 22,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.4),
                          ),
                          contentPadding: EdgeInsets.zero,
                          filled: true,
                          fillColor: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest
                              .withValues(alpha: 0.3),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),

                    // Harcama Listesi
                    Expanded(
                      child: filteredItems.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.receipt_long_outlined,
                                    size: 56,
                                    color: Colors.grey.withValues(alpha: 0.2),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    context.l10n.noDetailsFound,
                                    style: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              physics: const BouncingScrollPhysics(),
                              itemCount: filteredItems.length,
                              itemBuilder: (context, index) {
                                final item = filteredItems[index];
                                final title = item['isim']?.toString() ?? '';
                                final amount =
                                    (item['tutar'] as num?)?.toDouble() ?? 0.0;
                                final itemCurrency =
                                    item['paraBirimi']?.toString() ?? 'TRY';
                                final date =
                                    DateTime.tryParse(
                                      item['tarih'].toString(),
                                    ) ??
                                    DateTime.now();
                                final itemColor = _getCategoryColor(
                                  title.isNotEmpty
                                      ? title
                                      : date.toIso8601String(),
                                );

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  decoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.surfaceContainerLow,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withValues(alpha: 0.05),
                                      width: 1,
                                    ),
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 4,
                                    ),
                                    leading: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: itemColor.withValues(
                                          alpha: 0.15,
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.receipt_long_rounded,
                                        color: itemColor,
                                        size: 20,
                                      ),
                                    ),
                                    title: Text(
                                      title.isNotEmpty
                                          ? title
                                          : context.translateDbName(
                                              categoryKey,
                                            ),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    subtitle: Row(
                                      children: [
                                        Icon(
                                          Icons.calendar_today_rounded,
                                          size: 12,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withValues(alpha: 0.5),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          "${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}",
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface
                                                .withValues(alpha: 0.6),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                    trailing: Text(
                                      "-${CurrencyFormatter.format(amount, currency: itemCurrency)}",
                                      style: TextStyle(
                                        color: Colors.red.shade400,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
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
          },
        );
      },
    );
  }

  Color _getCategoryColor(String categoryName) {
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
    final index = categoryName.hashCode.abs() % colors.length;
    return colors[index];
  }

  IconData _getCategoryIcon(String categoryName) {
    final lower = categoryName.toLowerCase();

    if (lower.contains("market") || lower.contains("alışveriş")) {
      return Icons.shopping_basket_rounded;
    }
    if (lower.contains("fatura")) {
      return Icons.receipt_rounded;
    }
    if (lower.contains("ulaşım") ||
        lower.contains("yakıt") ||
        lower.contains("takasi") ||
        lower.contains("otobüs") ||
        lower.contains("metro")) {
      return Icons.directions_car_rounded;
    }
    if (lower.contains("yemek") ||
        lower.contains("restoran") ||
        lower.contains("kafe") ||
        lower.contains("cafe") ||
        lower.contains("dışarı")) {
      return Icons.restaurant_rounded;
    }
    if (lower.contains("eğitim") ||
        lower.contains("okul") ||
        lower.contains("kurs")) {
      return Icons.school_rounded;
    }
    if (lower.contains("sağlık") ||
        lower.contains("hastane") ||
        lower.contains("eczane")) {
      return Icons.local_hospital_rounded;
    }
    if (lower.contains("giyim") ||
        lower.contains("kıyafet") ||
        lower.contains("elbise")) {
      return Icons.checkroom_rounded;
    }
    if (lower.contains("eğlence") ||
        lower.contains("hobi") ||
        lower.contains("sinema") ||
        lower.contains("oyun")) {
      return Icons.movie_rounded;
    }
    if (lower.contains("kira") ||
        lower.contains("ev") ||
        lower.contains("aidat")) {
      return Icons.home_rounded;
    }
    if (lower.contains("hediye") || lower.contains("bağış")) {
      return Icons.card_giftcard_rounded;
    }
    if (lower.contains("abonelik") || lower.contains("dijital")) {
      return Icons.autorenew_rounded;
    }
    if (lower.contains("tatil") ||
        lower.contains("seyahat") ||
        lower.contains("otel")) {
      return Icons.flight_rounded;
    }
    if (lower.contains("evcil") ||
        lower.contains("hayvan") ||
        lower.contains("kedi") ||
        lower.contains("köpek") ||
        lower.contains("mama")) {
      return Icons.pets_rounded;
    }
    if (lower.contains("teknoloji") ||
        lower.contains("elektronik") ||
        lower.contains("telefon") ||
        lower.contains("bilgisayar")) {
      return Icons.phone_android_rounded;
    }
    if (lower.contains("bakım") ||
        lower.contains("kozmetik") ||
        lower.contains("kuaför") ||
        lower.contains("berber")) {
      return Icons.spa_rounded;
    }
    if (lower.contains("spor") ||
        lower.contains("fitness") ||
        lower.contains("gym")) {
      return Icons.fitness_center_rounded;
    }

    return Icons.category_rounded;
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
