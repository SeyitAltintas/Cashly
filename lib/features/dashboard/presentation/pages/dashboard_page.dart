import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/theme_manager.dart';
import '../../../income/data/models/income_model.dart';
import '../../../assets/data/models/asset_model.dart';
import '../../../payment_methods/data/models/payment_method_model.dart';

class DashboardPage extends StatelessWidget {
  final String userName;
  final List<Map<String, dynamic>> harcamalar;
  final List<Income> gelirler;
  final List<Asset> varliklar;
  final List<PaymentMethod> odemeYontemleri;
  final double butceLimiti;
  final DateTime secilenAy;

  const DashboardPage({
    super.key,
    required this.userName,
    required this.harcamalar,
    required this.gelirler,
    required this.varliklar,
    required this.odemeYontemleri,
    required this.butceLimiti,
    required this.secilenAy,
  });

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 6) return "İyi geceler";
    if (hour < 12) return "Günaydın";
    if (hour < 18) return "İyi günler";
    return "İyi akşamlar";
  }

  double _getTotalBalance() {
    double total = 0;
    for (var pm in odemeYontemleri.where((p) => !p.isDeleted)) {
      if (pm.type == 'kredi') {
        total -= pm.balance; // Kredi borcu
      } else {
        total += pm.balance; // Nakit/Banka
      }
    }
    return total;
  }

  double _getMonthlyExpense() {
    double total = 0;
    for (var h in harcamalar) {
      if (h['silindi'] == true) continue;
      DateTime? tarih = DateTime.tryParse(h['tarih'].toString());
      if (tarih != null &&
          tarih.year == secilenAy.year &&
          tarih.month == secilenAy.month) {
        total += (h['tutar'] as num?)?.toDouble() ?? 0;
      }
    }
    return total;
  }

  double _getMonthlyIncome() {
    double total = 0;
    for (var g in gelirler) {
      if (g.isDeleted) continue;
      if (g.date.year == secilenAy.year && g.date.month == secilenAy.month) {
        total += g.amount;
      }
    }
    return total;
  }

  double _getTotalAssetValue() {
    double total = 0;
    for (var v in varliklar.where((a) => !a.isDeleted)) {
      total += v.amount * v.quantity;
    }
    return total;
  }

  List<Map<String, dynamic>> _getRecentTransactions() {
    List<Map<String, dynamic>> transactions = [];

    // Harcamalar ekle
    for (var h in harcamalar) {
      if (h['silindi'] == true) continue;
      DateTime? tarih = DateTime.tryParse(h['tarih'].toString());
      if (tarih != null) {
        transactions.add({
          'type': 'expense',
          'name': h['isim'] ?? 'Harcama',
          'amount': (h['tutar'] as num?)?.toDouble() ?? 0,
          'date': tarih,
          'category': h['kategori'] ?? 'Diğer',
        });
      }
    }

    // Gelirler ekle
    for (var g in gelirler) {
      if (g.isDeleted) continue;
      transactions.add({
        'type': 'income',
        'name': g.name,
        'amount': g.amount,
        'date': g.date,
        'category': g.category,
      });
    }

    // Tarihe göre sırala (en yeniden en eskiye)
    transactions.sort((a, b) {
      DateTime dateA = a['date'];
      DateTime dateB = b['date'];
      return dateB.compareTo(dateA);
    });

    // İlk 5 işlemi al
    return transactions.take(5).toList();
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);
    final diff = today.difference(dateOnly).inDays;

    if (diff == 0) return "Bugün";
    if (diff == 1) return "Dün";
    return "${date.day}/${date.month}";
  }

  @override
  Widget build(BuildContext context) {
    final isDefaultTheme = context.watch<ThemeManager>().isDefaultTheme;
    final greeting = _getGreeting();
    final totalBalance = _getTotalBalance();
    final monthlyExpense = _getMonthlyExpense();
    final monthlyIncome = _getMonthlyIncome();
    final netDiff = monthlyIncome - monthlyExpense;
    final budgetUsed = butceLimiti > 0 ? (monthlyExpense / butceLimiti) : 0.0;
    final totalAssets = _getTotalAssetValue();
    final recentTransactions = _getRecentTransactions();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hoş Geldin Kartı
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 500),
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, 20 * (1 - value)),
                      child: child,
                    ),
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "$greeting,",
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      userName,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Toplam Bakiye Kartı
              _buildAnimatedCard(
                delay: 100,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDefaultTheme
                          ? [
                              const Color(0xFF1a1a2e),
                              const Color(0xFF16213e),
                              const Color(0xFF0f3460),
                            ]
                          : [
                              Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.3),
                              Theme.of(
                                context,
                              ).colorScheme.secondary.withValues(alpha: 0.15),
                            ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.3),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Toplam Bakiye",
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.account_balance_wallet,
                              color: Theme.of(context).colorScheme.secondary,
                              size: 24,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "${totalBalance >= 0 ? '' : '-'}${totalBalance.abs().toStringAsFixed(2)} ₺",
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: totalBalance >= 0
                              ? Colors.green.shade300
                              : Colors.red.shade300,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Bu Ay Özeti
              _buildAnimatedCard(
                delay: 200,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surface.withValues(alpha: 0.5),
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
                      Text(
                        "Bu Ay Özeti",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildSummaryItem(
                              context,
                              icon: Icons.arrow_downward,
                              iconColor: Colors.red.shade400,
                              label: "Harcama",
                              value: "${monthlyExpense.toStringAsFixed(2)} ₺",
                              valueColor: Colors.red.shade300,
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 50,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.1),
                          ),
                          Expanded(
                            child: _buildSummaryItem(
                              context,
                              icon: Icons.arrow_upward,
                              iconColor: Colors.green.shade400,
                              label: "Gelir",
                              value: "${monthlyIncome.toStringAsFixed(2)} ₺",
                              valueColor: Colors.green.shade300,
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 50,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.1),
                          ),
                          Expanded(
                            child: _buildSummaryItem(
                              context,
                              icon: netDiff >= 0
                                  ? Icons.trending_up
                                  : Icons.trending_down,
                              iconColor: netDiff >= 0
                                  ? Colors.green.shade400
                                  : Colors.red.shade400,
                              label: "Net",
                              value:
                                  "${netDiff >= 0 ? '+' : ''}${netDiff.toStringAsFixed(2)} ₺",
                              valueColor: netDiff >= 0
                                  ? Colors.green.shade300
                                  : Colors.red.shade300,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Bütçe Durumu
              _buildAnimatedCard(
                delay: 300,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surface.withValues(alpha: 0.5),
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
                              color: budgetUsed > 1
                                  ? Colors.red.shade400
                                  : budgetUsed > 0.8
                                  ? Colors.orange.shade400
                                  : Colors.green.shade400,
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
                            budgetUsed > 1
                                ? Colors.red.shade400
                                : budgetUsed > 0.8
                                ? Colors.orange.shade400
                                : Colors.green.shade400,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "${monthlyExpense.toStringAsFixed(2)} ₺ harcandı",
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                          Text(
                            "${butceLimiti.toStringAsFixed(2)} ₺ limit",
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Varlık Özeti
              _buildAnimatedCard(
                delay: 400,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.blue.shade900.withValues(alpha: 0.3),
                        Colors.blue.shade700.withValues(alpha: 0.15),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.blue.shade400.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Toplam Varlık",
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${totalAssets.toStringAsFixed(2)} ₺",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade300,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade400.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.diamond_outlined,
                          color: Colors.blue.shade300,
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Son İşlemler
              _buildAnimatedCard(
                delay: 500,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surface.withValues(alpha: 0.5),
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
                      Text(
                        "Son İşlemler",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (recentTransactions.isEmpty)
                        Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.receipt_long_outlined,
                                size: 40,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.2),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Henüz işlem yok",
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.5),
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        ...recentTransactions.map((transaction) {
                          final isExpense = transaction['type'] == 'expense';
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color:
                                        (isExpense ? Colors.red : Colors.green)
                                            .withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    isExpense
                                        ? Icons.arrow_downward
                                        : Icons.arrow_upward,
                                    color: isExpense
                                        ? Colors.red.shade400
                                        : Colors.green.shade400,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        transaction['name'],
                                        style: TextStyle(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurface,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        _formatDate(transaction['date']),
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withValues(alpha: 0.5),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  "${isExpense ? '-' : '+'}${(transaction['amount'] as double).toStringAsFixed(2)} ₺",
                                  style: TextStyle(
                                    color: isExpense
                                        ? Colors.red.shade300
                                        : Colors.green.shade300,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryItem(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildAnimatedCard({required int delay, required Widget child}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 500 + delay),
      builder: (context, value, c) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - value)),
            child: c,
          ),
        );
      },
      child: child,
    );
  }
}
