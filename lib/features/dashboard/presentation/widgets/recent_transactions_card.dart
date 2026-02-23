import 'package:flutter/material.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/animated_card.dart';
import '../../../../core/extensions/l10n_extensions.dart';
import '../../../income/data/models/income_model.dart';
import '../../../payment_methods/data/models/transfer_model.dart';
import '../../../payment_methods/data/models/payment_method_model.dart';

/// Son İşlemler Kartı Widget'ı
/// Harcama, gelir ve transferlerdeki son işlemleri gösterir
class RecentTransactionsCard extends StatelessWidget {
  final List<Map<String, dynamic>> harcamalar;
  final List<Income> gelirler;
  final List<Transfer> transferler;
  final List<PaymentMethod> odemeYontemleri;

  const RecentTransactionsCard({
    super.key,
    required this.harcamalar,
    required this.gelirler,
    required this.transferler,
    required this.odemeYontemleri,
  });

  /// Ödeme yöntemi adını ID'ye göre bulur
  String _getPaymentMethodName(String id) {
    final pm = odemeYontemleri.firstWhere(
      (p) => p.id == id,
      orElse: () => PaymentMethod(
        id: '',
        name: 'Unknown',
        type: 'banka',
        balance: 0,
        createdAt: DateTime.now(),
      ),
    );
    return pm.name;
  }

  /// Son işlemleri birleştirir ve sıralar
  List<Map<String, dynamic>> _getRecentTransactions(BuildContext context) {
    List<Map<String, dynamic>> transactions = [];

    // Harcamalar ekle
    for (var h in harcamalar) {
      if (h['silindi'] == true) continue;
      DateTime? tarih = DateTime.tryParse(h['tarih'].toString());
      if (tarih != null) {
        transactions.add({
          'type': 'expense',
          'name': context.translateDbName(h['isim'] ?? 'Expense'),
          'amount': (h['tutar'] as num?)?.toDouble() ?? 0,
          'date': tarih,
          'category': context.translateDbName(h['kategori'] ?? 'Diğer'),
        });
      }
    }

    // Gelirler ekle
    for (var g in gelirler) {
      if (g.isDeleted) continue;
      transactions.add({
        'type': 'income',
        'name': context.translateDbName(g.name),
        'amount': g.amount,
        'date': g.date,
        'category': context.translateDbName(g.category),
      });
    }

    // Transferler ekle
    for (var t in transferler) {
      final fromName = context.translateDbName(
        _getPaymentMethodName(t.fromAccountId),
      );
      final toName = context.translateDbName(
        _getPaymentMethodName(t.toAccountId),
      );
      transactions.add({
        'type': 'transfer',
        'name': '$fromName → $toName',
        'amount': t.amount,
        'date': t.date,
        'category': 'Transfer',
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

  String _formatDate(BuildContext context, DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);
    final diff = today.difference(dateOnly).inDays;

    if (diff == 0) return context.l10n.today;
    if (diff == 1) return context.l10n.yesterday;
    return "${date.day}/${date.month}";
  }

  @override
  Widget build(BuildContext context) {
    final recentTransactions = _getRecentTransactions(context);

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
              context.l10n.recentTransactions,
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
            context.l10n.noRecentTransactions,
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
    final type = transaction['type'];
    final isExpense = type == 'expense';
    final isTransfer = type == 'transfer';

    // Renk ve ikon belirleme
    Color iconColor;
    IconData icon;
    String prefix;

    if (isTransfer) {
      iconColor = Colors.orange;
      icon = Icons.swap_horiz;
      prefix = '';
    } else if (isExpense) {
      iconColor = Colors.red;
      icon = Icons.arrow_downward;
      prefix = '-';
    } else {
      iconColor = Colors.green;
      icon = Icons.arrow_upward;
      prefix = '+';
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: iconColor.withValues(alpha: 0.8),
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
                  _formatDate(context, transaction['date']),
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
            "$prefix${CurrencyFormatter.format(transaction['amount'] as double)}",
            style: TextStyle(
              color: iconColor.withValues(alpha: 0.9),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
