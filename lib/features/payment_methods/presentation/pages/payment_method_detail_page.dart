import 'package:cashly/core/extensions/l10n_extensions.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/color_constants.dart';
import '../../../../core/constants/card_color_constants.dart';
import '../../../../core/mixins/lazy_loading_mixin.dart';
import '../../../../core/widgets/month_selector_button.dart';

import '../../data/models/payment_method_model.dart';
import '../../data/models/transfer_model.dart';
import '../../../income/data/models/income_model.dart';
import '../controllers/payment_methods_controller.dart';
import '../../../../core/services/currency_service.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/utils/currency_formatter.dart';

/// Hesap detay sayfası - Bir ödeme yönteminin tüm işlemlerini gösterir
class PaymentMethodDetailPage extends StatefulWidget {
  final PaymentMethod paymentMethod;
  final List<Map<String, dynamic>> harcamalar;
  final List<Income> gelirler;
  final List<Transfer> transferler;
  final List<PaymentMethod> tumOdemeYontemleri;
  final PaymentMethodsController? controller;

  const PaymentMethodDetailPage({
    super.key,
    required this.paymentMethod,
    required this.harcamalar,
    required this.gelirler,
    required this.transferler,
    required this.tumOdemeYontemleri,
    this.controller,
  });

  @override
  State<PaymentMethodDetailPage> createState() =>
      _PaymentMethodDetailPageState();
}

class _PaymentMethodDetailPageState extends State<PaymentMethodDetailPage>
    with LazyLoadingMixin {
  // Controller veya yerel state
  PaymentMethodsController? _controller;
  int _localSecilenAy = DateTime.now().month;
  int _localSecilenYil = DateTime.now().year;

  int get _secilenAy => _controller?.detailSecilenAy ?? _localSecilenAy;
  int get _secilenYil => _controller?.detailSecilenYil ?? _localSecilenYil;

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
    _controller?.addListener(_onStateChanged);
    // Lazy loading başlat
    initLazyLoading();
  }

  @override
  void dispose() {
    _controller?.removeListener(_onStateChanged);
    disposeLazyLoading();
    super.dispose();
  }

  /// Tüm işlemleri oluştur (filtreleme öncesi)
  List<_TransactionItem> _buildAllTransactions() {
    final List<_TransactionItem> items = [];
    final pmId = widget.paymentMethod.id;

    // Harcamaları ekle
    for (var h in widget.harcamalar) {
      if (h['odemeYontemiId'] == pmId && h['silindi'] != true) {
        items.add(
          _TransactionItem(
            type: _TransactionType.expense,
            title: h['isim'] ?? 'Harcama',
            amount: (h['tutar'] as num?)?.toDouble() ?? 0,
            date:
                DateTime.tryParse(h['tarih']?.toString() ?? '') ??
                DateTime.now(),
            category: h['kategori'] ?? '',
          ),
        );
      }
    }

    // Gelirleri ekle
    for (var g in widget.gelirler) {
      if (g.paymentMethodId == pmId && !g.isDeleted) {
        items.add(
          _TransactionItem(
            type: _TransactionType.income,
            title: context.translateDbName(g.name),
            amount: g.amount,
            date: g.date,
            category: g.category,
          ),
        );
      }
    }

    // Transferleri ekle
    for (var t in widget.transferler) {
      if (t.fromAccountId == pmId) {
        // Giden transfer
        final toAccount = widget.tumOdemeYontemleri.firstWhere(
          (pm) => pm.id == t.toAccountId,
          orElse: () => PaymentMethod(
            id: '',
            name: context.l10n.unknown,
            type: 'banka',
            balance: 0,
            createdAt: DateTime.now(),
          ),
        );
        items.add(
          _TransactionItem(
            type: _TransactionType.transferOut,
            title: context.l10n.transferOutTitle(
              context.translateDbName(toAccount.name),
            ),
            amount: t.amount,
            date: t.date,
            category: '',
          ),
        );
      } else if (t.toAccountId == pmId) {
        // Gelen transfer
        final fromAccount = widget.tumOdemeYontemleri.firstWhere(
          (pm) => pm.id == t.fromAccountId,
          orElse: () => PaymentMethod(
            id: '',
            name: context.l10n.unknown,
            type: 'banka',
            balance: 0,
            createdAt: DateTime.now(),
          ),
        );
        items.add(
          _TransactionItem(
            type: _TransactionType.transferIn,
            title: context.l10n.transferInTitle(
              context.translateDbName(fromAccount.name),
            ),
            amount: t.amount,
            date: t.date,
            category: '',
          ),
        );
      }
    }

    // Tarihe göre sırala (en yeni en üstte)
    items.sort((a, b) => b.date.compareTo(a.date));
    return items;
  }

  /// Seçilen aya göre filtrelenmiş işlemleri döndür
  List<_TransactionItem> _getFilteredTransactions() {
    final allTransactions = _buildAllTransactions();
    // Seçilen ay/yıla göre filtrele
    return allTransactions.where((item) {
      return item.date.month == _secilenAy && item.date.year == _secilenYil;
    }).toList();
  }

  void _onMonthSelected(DateTime date) {
    if (_controller != null) {
      _controller!.selectDetailMonth(date.month, date.year);
    } else {
      _localSecilenAy = date.month;
      _localSecilenYil = date.year;
      setState(() {});
    }
    // Lazy loading'i sıfırla
    final filtered = _getFilteredTransactions();
    resetLazyLoading(filtered.length);
  }

  @override
  Widget build(BuildContext context) {
    final pm = widget.paymentMethod;
    final colors = CardColorConstants
        .gradients[pm.colorIndex.clamp(0, CardColorConstants.count - 1)];
    final allFilteredTransactions = _getFilteredTransactions();
    final transactions = applyPagination(allFilteredTransactions);
    final cur = getIt<CurrencyService>();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(context.translateDbName(pm.name)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Hesap Kartı
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: colors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: colors[0].withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      pm.type == 'kredi'
                          ? Icons.credit_card
                          : pm.type == 'nakit'
                          ? Icons.wallet
                          : Icons.account_balance,
                      color: Colors.white,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        pm.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (pm.lastFourDigits != null)
                      Text(
                        '****${pm.lastFourDigits}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 14,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  pm.type == 'kredi'
                      ? context.l10n.debt
                      : context.l10n.balanceLabel,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 14,
                  ),
                ),
                Text(
                  CurrencyFormatter.format(
                    cur.convert(pm.balance, pm.paraBirimi, cur.currentCurrency),
                  ),
                  style: TextStyle(
                    color: pm.type == 'kredi'
                        ? Colors.redAccent
                        : Colors.greenAccent,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (pm.type == 'kredi' && pm.limit != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${context.l10n.limitLabel}: ${CurrencyFormatter.formatInteger(cur.convert(pm.limit!, pm.paraBirimi, cur.currentCurrency))}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '${context.l10n.remainingLimitLabel}: ${CurrencyFormatter.formatInteger(cur.convert(pm.limit! - pm.balance, pm.paraBirimi, cur.currentCurrency))}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // İşlem Listesi Başlığı ve Ay Seçici
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(
                  Icons.history,
                  color: Theme.of(context).colorScheme.secondary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '${context.l10n.transactionHistory} (${allFilteredTransactions.length})',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                // Ay Seçici Butonu
                MonthSelectorButton(
                  selectedMonth: _secilenAy,
                  selectedYear: _secilenYil,
                  onMonthSelected: _onMonthSelected,
                  useNeutralSelectedStyle: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // İşlem Listesi
          Expanded(
            child: transactions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long,
                          size: 64,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          context.l10n.noTransactionsFoundThisMonth,
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.5),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: lazyScrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: transactions.length + (hasMoreItems ? 1 : 0),
                    itemBuilder: (context, index) {
                      // Son eleman loading indicator
                      if (index == transactions.length) {
                        return buildLoadingIndicator();
                      }
                      return _buildTransactionTile(transactions[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionTile(_TransactionItem item) {
    IconData icon;
    Color iconColor;
    String amountPrefix;

    switch (item.type) {
      case _TransactionType.expense:
        icon = Icons.arrow_downward;
        iconColor = ColorConstants.koyuKirmizi;
        amountPrefix = '-';
        break;
      case _TransactionType.income:
        icon = Icons.arrow_upward;
        iconColor = Colors.green;
        amountPrefix = '+';
        break;
      case _TransactionType.transferOut:
        icon = Icons.arrow_forward;
        iconColor = Colors.orange;
        amountPrefix = '-';
        break;
      case _TransactionType.transferIn:
        icon = Icons.arrow_back;
        iconColor = Colors.blue;
        amountPrefix = '+';
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  DateFormat('d MMM yyyy', 'tr_TR').format(item.date),
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
          Text(() {
            final cur = getIt<CurrencyService>();
            return '$amountPrefix${CurrencyFormatter.format(cur.convert(item.amount, widget.paymentMethod.paraBirimi, cur.currentCurrency))}';
          }(), style: TextStyle(color: iconColor, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

enum _TransactionType { expense, income, transferOut, transferIn }

class _TransactionItem {
  final _TransactionType type;
  final String title;
  final double amount;
  final DateTime date;
  final String category;

  _TransactionItem({
    required this.type,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
  });
}
