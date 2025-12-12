import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cashly/core/theme/theme_manager.dart';
import 'package:cashly/core/theme/app_theme.dart';
import '../../data/models/income_model.dart';

class IncomePage extends StatefulWidget {
  final List<Income> incomes;
  final DateTime selectedDate;
  final Function(Income) onDelete;
  final Function(Income) onEdit;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final VoidCallback onSelectMonth;
  final String searchQuery;

  const IncomePage({
    super.key,
    required this.incomes,
    required this.selectedDate,
    required this.onDelete,
    required this.onEdit,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onSelectMonth,
    this.searchQuery = '',
  });

  @override
  State<IncomePage> createState() => _IncomePageState();
}

class _IncomePageState extends State<IncomePage> {
  final List<String> _months = [
    "Ocak",
    "Şubat",
    "Mart",
    "Nisan",
    "Mayıs",
    "Haziran",
    "Temmuz",
    "Ağustos",
    "Eylül",
    "Ekim",
    "Kasım",
    "Aralık",
  ];

  String get monthName {
    return "${_months[widget.selectedDate.month - 1]} ${widget.selectedDate.year}";
  }

  double get totalIncome {
    return widget.incomes
        .where((i) => !i.isDeleted)
        .where(
          (i) =>
              i.date.year == widget.selectedDate.year &&
              i.date.month == widget.selectedDate.month,
        )
        .fold(0.0, (sum, income) => sum + income.amount);
  }

  List<Income> get filteredIncomes {
    var result = widget.incomes
        .where((i) => !i.isDeleted)
        .where(
          (i) =>
              i.date.year == widget.selectedDate.year &&
              i.date.month == widget.selectedDate.month,
        );

    // Arama filtresi
    if (widget.searchQuery.isNotEmpty) {
      final query = widget.searchQuery.toLowerCase();
      result = result.where(
        (i) =>
            i.name.toLowerCase().contains(query) ||
            i.category.toLowerCase().contains(query),
      );
    }

    return result.toList()..sort((a, b) => b.date.compareTo(a.date));
  }

  Map<String, List<Income>> get groupedIncomes {
    Map<String, List<Income>> groups = {};
    for (var income in filteredIncomes) {
      String dateKey = _formatDate(income.date);
      if (!groups.containsKey(dateKey)) {
        groups[dateKey] = [];
      }
      groups[dateKey]!.add(income);
    }
    return groups;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);
    final diff = today.difference(dateOnly).inDays;

    if (diff == 0) return "Bugün";
    if (diff == 1) return "Dün";
    return "${dateOnly.day} ${_months[dateOnly.month - 1]}";
  }

  IconData _getIconForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'maaş':
        return Icons.work;
      case 'freelance':
        return Icons.laptop;
      case 'yatırım':
        return Icons.trending_up;
      case 'kira geliri':
        return Icons.home;
      case 'hediye':
        return Icons.card_giftcard;
      case 'diğer':
        return Icons.category;
      default:
        return Icons.attach_money;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Toplam Gelir Kartı
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            children: [
              // Ay Seçici
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.7),
                      size: 18,
                    ),
                    onPressed: widget.onPreviousMonth,
                  ),
                  TextButton(
                    onPressed: widget.onSelectMonth,
                    style: TextButton.styleFrom(foregroundColor: Colors.white),
                    child: Row(
                      children: [
                        Text(
                          monthName.toUpperCase(),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Icon(
                          Icons.arrow_drop_down,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.7),
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.arrow_forward_ios,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.7),
                      size: 18,
                    ),
                    onPressed: widget.onNextMonth,
                  ),
                ],
              ),
              Divider(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.1),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Toplam Gelir",
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.7),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${totalIncome.toStringAsFixed(2)} ₺",
                        style: TextStyle(
                          color: context.watch<ThemeManager>().isDefaultTheme
                              ? PageThemeColors.incomePrimary
                              : Colors.green,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(
                      Icons.trending_up,
                      color: Theme.of(context).colorScheme.primary,
                      size: 28,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Alt bilgi
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
                      Icons.receipt_long,
                      color: Theme.of(context).colorScheme.secondary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Bu ay ${filteredIncomes.length} adet gelir kaydı eklendi",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        // Gelir Listesi
        Expanded(
          child: filteredIncomes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.account_balance_wallet_outlined,
                        size: 60,
                        color: Colors.white12,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Bu ay gelir kaydı yok",
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.5),
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "+ butonuna tıklayarak gelir ekleyin",
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.3),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: groupedIncomes.keys.length,
                  itemBuilder: (context, groupIndex) {
                    String dateKey = groupedIncomes.keys.toList()[groupIndex];
                    List<Income> incomesForDate = groupedIncomes[dateKey]!;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Tarih Başlığı
                        Padding(
                          padding: const EdgeInsets.only(top: 12, bottom: 8),
                          child: Text(
                            dateKey,
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.5),
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        // Gelir Kartları
                        ...incomesForDate.map(
                          (income) => _buildIncomeCard(income),
                        ),
                      ],
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildIncomeCard(Income income) {
    return Dismissible(
      key: Key(income.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.red.shade700,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        widget.onDelete(income);
      },
      child: GestureDetector(
        onTap: () => widget.onEdit(income),
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.1),
            ),
          ),
          child: Row(
            children: [
              // İkon
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getIconForCategory(income.category),
                  color: context.watch<ThemeManager>().isDefaultTheme
                      ? PageThemeColors.getIconColor(
                          filteredIncomes.indexOf(income),
                        )
                      : Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              // İsim ve Kategori
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      income.name,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      income.category,
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
              // Tutar
              Text(
                "+${income.amount.toStringAsFixed(2)} ₺",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
