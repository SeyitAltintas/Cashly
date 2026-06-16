import 'package:flutter/material.dart';
import '../../../../core/constants/color_constants.dart';
import 'package:provider/provider.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/animated_card.dart';
import '../../../../core/widgets/obscured_amount_text.dart';
import '../../../../core/extensions/l10n_extensions.dart';
import '../controllers/dashboard_controller.dart';

/// Son İşlemler Kartı Widget'ı
/// Harcama, gelir ve transferlerdeki son işlemleri gösterir
class RecentTransactionsCard extends StatelessWidget {
  const RecentTransactionsCard({super.key});

  /// Isolate üzerinden gelen işlemlere UI çevirilerini (localization) uygular
  List<Map<String, dynamic>> _getTranslatedTransactions(BuildContext context) {
    final rawTransactions = context.select(
      (DashboardController c) => c.recentTransactions,
    );

    return rawTransactions.map((tx) {
      // Map'i kopyala ve çevirileri uygula
      final newTx = Map<String, dynamic>.from(tx);

      if (tx['type'] == 'transfer') {
        // Transfer isim formatı 'from → to' şeklindedir, biz sadece çeviri yapabiliriz veya olduğu gibi bırakabiliriz
        // (İsimler zaten Isolate içinde oluşturuldu) ama DB çevirisi uygulayalım
        final parts = (tx['name'] as String).split(' → ');
        if (parts.length == 2) {
          newTx['name'] =
              '${context.translateDbName(parts[0])} → ${context.translateDbName(parts[1])}';
        }
      } else {
        newTx['name'] = context.translateDbName(tx['name'] as String);
      }

      if (tx['category'] != 'Transfer') {
        newTx['category'] = context.translateDbName(tx['category'] as String);
      }

      return newTx;
    }).toList();
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
    final recentTransactions = _getTranslatedTransactions(context);
    final isObscured = context.select((DashboardController c) => c.isObscured);

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
                (transaction) =>
                    _buildTransactionItem(context, transaction, isObscured),
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
    bool isObscured,
  ) {
    final type = transaction['type'];
    final isExpense = type == 'expense';
    final isTransfer = type == 'transfer';

    // Renk ve ikon belirleme
    Color iconColor;
    IconData icon;
    String prefix;

    if (isTransfer) {
      iconColor = ColorConstants.turuncuVurgu;
      icon = Icons.swap_horiz;
      prefix = '';
    } else if (isExpense) {
      iconColor = ColorConstants.kirmiziVurgu;
      icon = Icons.arrow_downward;
      prefix = '-';
    } else {
      iconColor = ColorConstants.yesil;
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
          ObscuredAmountText(
            "$prefix${CurrencyFormatter.formatInteger(transaction['amount'] as double)}",
            isObscured: isObscured,
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
