import 'package:flutter/material.dart';
import 'package:cashly/core/constants/color_constants.dart';

import '../../data/models/payment_method_model.dart';

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
    extends State<PaymentMethodRecycleBinPage> {
  late List<PaymentMethod> _deletedPaymentMethods;

  final List<List<Color>> _cardColors = [
    [const Color(0xFF1a1a2e), const Color(0xFF16213e)],
    [const Color(0xFF2d132c), const Color(0xFF432371)],
    [const Color(0xFF0f3460), const Color(0xFF16537e)],
    [const Color(0xFF1e5128), const Color(0xFF4e9f3d)],
    [const Color(0xFF5c2018), const Color(0xFF8b3a2f)],
    [const Color(0xFF3d3d3d), const Color(0xFF5a5a5a)],
  ];

  @override
  void initState() {
    super.initState();
    _deletedPaymentMethods = List.from(widget.deletedPaymentMethods);
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
              backgroundColor: Colors.green.shade700,
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
              setState(() {
                _deletedPaymentMethods.clear();
              });
              if (widget.onRestoreAll != null) {
                widget.onRestoreAll!();
              }
            },
            child: const Text(
              'Evet, Geri Yükle',
              style: TextStyle(color: Colors.white),
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
              setState(() {
                _deletedPaymentMethods.clear();
              });
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
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Çöp Kutusu'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_deletedPaymentMethods.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.restore, color: Colors.green),
              tooltip: 'Tümünü Geri Yükle',
              onPressed: _confirmRestoreAll,
            ),
          if (_deletedPaymentMethods.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_forever, color: Colors.white),
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
              padding: const EdgeInsets.all(16),
              itemCount: _deletedPaymentMethods.length,
              itemBuilder: (context, index) {
                final pm = _deletedPaymentMethods[index];
                return _buildDeletedCard(pm);
              },
            ),
    );
  }

  Widget _buildDeletedCard(PaymentMethod pm) {
    final colors = _cardColors[pm.colorIndex.clamp(0, _cardColors.length - 1)];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colors[0].withValues(alpha: 0.5),
            colors[1].withValues(alpha: 0.5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: Colors.white.withValues(alpha: 0.2),
          child: Icon(
            pm.type == 'nakit'
                ? Icons.wallet
                : pm.type == 'kredi'
                ? Icons.credit_card
                : Icons.account_balance,
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          pm.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          '${pm.typeDisplayName} • ${pm.balance.toStringAsFixed(2)} ₺',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 12,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                Icons.restore,
                color: Theme.of(context).colorScheme.secondary,
              ),
              tooltip: 'Geri Yükle',
              onPressed: () {
                setState(() {
                  _deletedPaymentMethods.removeWhere((p) => p.id == pm.id);
                });
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
                          setState(() {
                            _deletedPaymentMethods.removeWhere(
                              (p) => p.id == pm.id,
                            );
                          });
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
