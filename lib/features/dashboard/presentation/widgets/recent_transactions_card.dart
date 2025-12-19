import 'package:flutter/material.dart';
import '../../../../core/widgets/animated_card.dart';
import '../../../income/data/models/income_model.dart';

/// Son İşlemler Kartı Widget'ı
/// Harcama ve gelirlerdeki son işlemleri gösterir
class RecentTransactionsCard extends StatelessWidget {
  final List<Map<String, dynamic>> harcamalar;
  final List<Income> gelirler;

  const RecentTransactionsCard({
    super.key,
    required this.harcamalar,
    required this.gelirler,
  });

  /// Son işlemleri birleştirir ve sıralar
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
    final recentTransactions = _getRecentTransactions();

    return AnimatedCard(
      delay: 500,
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
              _buildEmptyState(context)
            else
              ...recentTransactions.map(
                (transaction) => _buildTransactionItem(context, transaction),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
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
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(
    BuildContext context,
    Map<String, dynamic> transaction,
  ) {
    final isExpense = transaction['type'] == 'expense';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (isExpense ? Colors.red : Colors.green).withValues(
                alpha: 0.15,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isExpense ? Icons.arrow_downward : Icons.arrow_upward,
              color: isExpense ? Colors.red.shade400 : Colors.green.shade400,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction['name'],
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  _formatDate(transaction['date']),
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
          Text(
            "${isExpense ? '-' : '+'}${(transaction['amount'] as double).toStringAsFixed(2)} ₺",
            style: TextStyle(
              color: isExpense ? Colors.red.shade300 : Colors.green.shade300,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
