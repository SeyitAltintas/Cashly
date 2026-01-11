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

  // 24 adet premium kart rengi - gradient paletler
  final List<List<Color>> _cardColors = [
    // === KOYU TONLAR ===
    [const Color(0xFF1a1a2e), const Color(0xFF16213e)], // 1. Gece Mavisi
    [const Color(0xFF2d132c), const Color(0xFF432371)], // 2. Derin Mor
    [const Color(0xFF0f3460), const Color(0xFF16537e)], // 3. Okyanus Mavisi
    [const Color(0xFF1e5128), const Color(0xFF4e9f3d)], // 4. Orman Yeşili
    [const Color(0xFF5c2018), const Color(0xFF8b3a2f)], // 5. Bordo
    [const Color(0xFF3d3d3d), const Color(0xFF5a5a5a)], // 6. Grafit
    // === METALİK TONLAR ===
    [const Color(0xFF232526), const Color(0xFF414345)], // 7. Karbon Siyah
    [const Color(0xFF283048), const Color(0xFF859398)], // 8. Çelik Gri
    [const Color(0xFF4b3621), const Color(0xFF8b6914)], // 9. Bronz
    [const Color(0xFF1f1c2c), const Color(0xFF928DAB)], // 10. Gümüş Mor
    [const Color(0xFF0F2027), const Color(0xFF2C5364)], // 11. Titanyum
    [const Color(0xFF141E30), const Color(0xFF243B55)], // 12. Midnight Blue
    // === SICAK TONLAR ===
    [const Color(0xFF642B73), const Color(0xFFC6426E)], // 13. Magenta
    [const Color(0xFF833ab4), const Color(0xFFfd1d1d)], // 14. Günbatımı
    [const Color(0xFFb91d73), const Color(0xFFf953c6)], // 15. Neon Pembe
    [const Color(0xFF6D0EB5), const Color(0xFF4059F1)], // 16. Elektrik Mor
    [const Color(0xFFc31432), const Color(0xFF240b36)], // 17. Şarap Kırmızısı
    [const Color(0xFFeb3349), const Color(0xFFf45c43)], // 18. Ateş Kırmızısı
    // === SOĞUK TONLAR ===
    [const Color(0xFF11998e), const Color(0xFF38ef7d)], // 19. Zümrüt
    [const Color(0xFF00b4db), const Color(0xFF0083b0)], // 20. Turkuaz
    [const Color(0xFF1CB5E0), const Color(0xFF000851)], // 21. Elektrik Mavi
    [const Color(0xFF00c9ff), const Color(0xFF92fe9d)], // 22. Aurora
    [const Color(0xFF373B44), const Color(0xFF4286f4)], // 23. Safir
    [const Color(0xFF134E5E), const Color(0xFF71B280)], // 24. Deniz Yeşili
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
