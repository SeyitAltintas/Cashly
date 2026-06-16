import 'package:flutter/material.dart';
import 'package:cashly/core/extensions/l10n_extensions.dart';
import 'package:cashly/core/constants/color_constants.dart';
import 'package:cashly/core/constants/card_color_constants.dart';
import 'package:cashly/core/mixins/lazy_loading_mixin.dart';

import '../../data/models/payment_method_model.dart';
import '../../../../core/services/currency_service.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../settings/presentation/state/recycle_bin_states.dart';

class PaymentMethodRecycleBinPage extends StatefulWidget {
  final List<PaymentMethod> deletedPaymentMethods;
  final Function(PaymentMethod) onRestore;
  final Function(PaymentMethod) onPermanentDelete;
  final VoidCallback onEmptyBin;
  final VoidCallback? onRestoreAll;

  const PaymentMethodRecycleBinPage({
    super.key,
    required this.deletedPaymentMethods,
    required this.onRestore,
    required this.onPermanentDelete,
    required this.onEmptyBin,
    this.onRestoreAll,
  });

  @override
  State<PaymentMethodRecycleBinPage> createState() =>
      _PaymentMethodRecycleBinPageState();
}

class _PaymentMethodRecycleBinPageState
    extends State<PaymentMethodRecycleBinPage>
    with LazyLoadingMixin {
  late final PaymentMethodRecycleBinState _binState;

  List<PaymentMethod> get _deletedPaymentMethods =>
      _binState.deletedPaymentMethods;

  @override
  void initState() {
    super.initState();
    _binState = PaymentMethodRecycleBinState();
    _binState.init(widget.deletedPaymentMethods);
    _binState.addListener(_onStateChanged);
    initLazyLoading();
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _binState.removeListener(_onStateChanged);
    _binState.dispose();
    disposeLazyLoading();
    super.dispose();
  }

  /// Tüm silinen ödeme yöntemlerini geri yükler
  void _confirmRestoreAll() {
    if (_deletedPaymentMethods.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          'Tümünü Geri Yükle',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
        content: Text(
          '${_deletedPaymentMethods.length} ödeme yöntemi geri yüklenecek. Onaylıyor musun?',
          style: TextStyle(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'İptal',
              style: TextStyle(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorConstants.yesil,
            ),
            onPressed: () {
              Navigator.pop(context);
              // Tüm ödeme yöntemlerini tek tek geri yükle
              final methodsToRestore = List<PaymentMethod>.from(
                _deletedPaymentMethods,
              );
              for (var pm in methodsToRestore) {
                widget.onRestore(pm);
              }
              _binState.clearBin();
              if (widget.onRestoreAll != null) {
                widget.onRestoreAll!();
              }
            },
            child: Text(
              'Evet, Geri Yükle',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmEmptyBin() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          'Çöp Kutusunu Boşalt',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
        content: Text(
          'Tüm silinen ödeme yöntemleri kalıcı olarak silinecek. Bu işlem geri alınamaz.',
          style: TextStyle(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'İptal',
              style: TextStyle(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _binState.clearBin();
              widget.onEmptyBin();
            },
            child: const Text(
              'Boşalt',
              style: TextStyle(color: ColorConstants.koyuKirmizi),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(context.l10n.recycleBin),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_deletedPaymentMethods.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.restore, color: ColorConstants.yesil),
              tooltip: 'Tümünü Geri Yükle',
              onPressed: _confirmRestoreAll,
            ),
          if (_deletedPaymentMethods.isNotEmpty)
            IconButton(
              icon: Icon(Icons.delete_forever, color: Theme.of(context).colorScheme.onSurface),
              tooltip: 'Çöp Kutusunu Boşalt',
              onPressed: _confirmEmptyBin,
            ),
        ],
      ),
      body: _deletedPaymentMethods.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.delete_outline,
                    size: 64,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Çöp kutusu boş',
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
              padding: const EdgeInsets.all(16),
              itemCount: _deletedPaymentMethods.length + (hasMoreItems ? 1 : 0),
              itemBuilder: (context, index) {
                // Son item ise ve daha fazla veri varsa loading göster
                if (index >= _deletedPaymentMethods.length) {
                  return buildLoadingIndicator();
                }
                final pm = _deletedPaymentMethods[index];
                return _buildDeletedCard(
                  pm,
                  index == 0,
                  index == _deletedPaymentMethods.length - 1,
                );
              },
            ),
    );
  }

  Widget _buildDeletedCard(PaymentMethod pm, bool isFirst, bool isLast) {
    final colors = CardColorConstants
        .gradients[pm.colorIndex.clamp(0, CardColorConstants.count - 1)];

    final cur = getIt<CurrencyService>();
    final convertedAmount = cur.convert(
      pm.balance,
      pm.paraBirimi,
      cur.currentCurrency,
    );

    return Container(
      margin: EdgeInsets.zero,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colors[0].withValues(alpha: 0.5),
            colors[1].withValues(alpha: 0.5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(
          top: isFirst ? const Radius.circular(16) : Radius.zero,
          bottom: isLast ? const Radius.circular(16) : Radius.zero,
        ),
        border: Border(
          top: isFirst
              ? BorderSide(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1))
              : BorderSide.none,
          bottom: BorderSide(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1)),
          left: BorderSide(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1)),
          right: BorderSide(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1)),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
          child: Icon(
            pm.type == 'nakit'
                ? Icons.wallet
                : pm.type == 'kredi'
                ? Icons.credit_card
                : Icons.account_balance,
            color: Theme.of(context).colorScheme.onSurface,
            size: 20,
          ),
        ),
        title: Text(
          pm.name,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          '${pm.typeDisplayName} • ${CurrencyFormatter.format(convertedAmount)}',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            fontSize: 12,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                Icons.restore,
                color: Theme.of(context).colorScheme.primary,
              ),
              tooltip: 'Geri Yükle',
              onPressed: () {
                _binState.removeMethod(pm);
                widget.onRestore(pm);
              },
            ),
            IconButton(
              icon: const Icon(
                Icons.delete_forever,
                color: ColorConstants.koyuKirmizi,
              ),
              tooltip: 'Kalıcı Sil',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    title: Text(
                      'Kalıcı Silme',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    content: Text(
                      '"${pm.name}" kalıcı olarak silinecek. Bu işlem geri alınamaz.',
                      style: TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'İptal',
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _binState.removeMethod(pm);
                          widget.onPermanentDelete(pm);
                        },
                        child: const Text(
                          'Sil',
                          style: TextStyle(color: ColorConstants.koyuKirmizi),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
