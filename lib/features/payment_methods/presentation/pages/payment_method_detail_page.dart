import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/color_constants.dart';
import '../../../../core/mixins/lazy_loading_mixin.dart';
import '../../../../core/widgets/month_selector_button.dart';
import '../../data/models/payment_method_model.dart';
import '../../data/models/transfer_model.dart';
import '../../../income/data/models/income_model.dart';

/// Hesap detay sayfası - Bir ödeme yönteminin tüm işlemlerini gösterir
class PaymentMethodDetailPage extends StatefulWidget {
  final PaymentMethod paymentMethod;
  final List<Map<String, dynamic>> harcamalar;
  final List<Income> gelirler;
  final List<Transfer> transferler;
  final List<PaymentMethod> tumOdemeYontemleri;

  const PaymentMethodDetailPage({
    super.key,
    required this.paymentMethod,
    required this.harcamalar,
    required this.gelirler,
    required this.transferler,
    required this.tumOdemeYontemleri,
  });

  @override
  State<PaymentMethodDetailPage> createState() =>
      _PaymentMethodDetailPageState();
}

class _PaymentMethodDetailPageState extends State<PaymentMethodDetailPage>
    with LazyLoadingMixin {
  final List<List<Color>> _cardColors = [
    [const Color(0xFF1a1a2e), const Color(0xFF16213e)],
    [const Color(0xFF2d132c), const Color(0xFF432371)],
    [const Color(0xFF0f3460), const Color(0xFF16537e)],
    [const Color(0xFF1e5128), const Color(0xFF4e9f3d)],
    [const Color(0xFF5c2018), const Color(0xFF8b3a2f)],
    [const Color(0xFF3d3d3d), const Color(0xFF5a5a5a)],
  ];

  /// Seçilen ay ve yıl (filtreleme için)
  late int _secilenAy;
  late int _secilenYil;

  @override
  void initState() {
    super.initState();
    // Varsayılan olarak mevcut ay/yıl
    final now = DateTime.now();
    _secilenAy = now.month;
    _secilenYil = now.year;
    // Lazy loading başlat
    initLazyLoading();
  }

  @override
  void dispose() {
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
            title: g.name,
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
            name: 'Bilinmeyen',
            type: 'banka',
            balance: 0,
            createdAt: DateTime.now(),
          ),
        );
        items.add(
          _TransactionItem(
            type: _TransactionType.transferOut,
            title: '${toAccount.name} hesabına giden transfer',
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
            name: 'Bilinmeyen',
            type: 'banka',
            balance: 0,
            createdAt: DateTime.now(),
          ),
        );
        items.add(
          _TransactionItem(
            type: _TransactionType.transferIn,
            title: '${fromAccount.name} hesabından gelen transfer',
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

  /// Ay seçimi değiştiğinde
  void _onMonthSelected(DateTime date) {
    setState(() {
      _secilenAy = date.month;
      _secilenYil = date.year;
      // Lazy loading'i sıfırla
      final filtered = _getFilteredTransactions();
      resetLazyLoading(filtered.length);
    });
  }

  @override
  Widget build(BuildContext context) {
    final pm = widget.paymentMethod;
    final colors = _cardColors[pm.colorIndex.clamp(0, _cardColors.length - 1)];
    final allFilteredTransactions = _getFilteredTransactions();
    final transactions = applyPagination(allFilteredTransactions);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(pm.name),
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
                  pm.type == 'kredi' ? 'Borç' : 'Bakiye',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 14,
                  ),
                ),
                Text(
                  '${pm.balance.toStringAsFixed(2)} ₺',
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
                        'Limit: ${pm.limit!.toStringAsFixed(0)} ₺',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        'Kalan: ${(pm.limit! - pm.balance).toStringAsFixed(0)} ₺',
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
                  'İşlem Geçmişi (${allFilteredTransactions.length})',
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
                          'Bu ayda işlem bulunamadı',
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
          Text(
            '$amountPrefix${item.amount.toStringAsFixed(2)} ₺',
            style: TextStyle(color: iconColor, fontWeight: FontWeight.bold),
          ),
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
