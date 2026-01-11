import 'package:flutter/material.dart';
import 'package:cashly/core/constants/color_constants.dart';
import 'package:cashly/core/widgets/skeleton_widget.dart';

import '../../data/models/payment_method_model.dart';
import 'add_payment_method_page.dart';
import '../widgets/payment_method_summary_card.dart';
import 'payment_method_recycle_bin_page.dart';

class PaymentMethodsPage extends StatefulWidget {
  final List<PaymentMethod> paymentMethods;
  final List<PaymentMethod> deletedPaymentMethods;
  final Function(PaymentMethod) onDelete;
  final Function(PaymentMethod) onEdit;
  final Function(PaymentMethod) onRestore;
  final Function(PaymentMethod) onPermanentDelete;
  final VoidCallback onEmptyBin;
  final Function(PaymentMethod)? onCardTap;
  final String? userName;
  final String? userProfileUrl;
  final Function(
    String name,
    String type,
    String? lastFourDigits,
    double balance,
    double? limit,
    int colorIndex,
  )
  onAdd;

  const PaymentMethodsPage({
    super.key,
    required this.paymentMethods,
    required this.deletedPaymentMethods,
    required this.onDelete,
    required this.onEdit,
    required this.onRestore,
    required this.onPermanentDelete,
    required this.onEmptyBin,
    required this.onAdd,
    this.onCardTap,
    this.userName,
    this.userProfileUrl,
  });

  @override
  State<PaymentMethodsPage> createState() => _PaymentMethodsPageState();
}

class _PaymentMethodsPageState extends State<PaymentMethodsPage> {
  bool _aramaModu = false;
  bool _isLoading = true; // Skeleton loading için
  final TextEditingController _aramaController = TextEditingController();
  List<PaymentMethod> _paymentMethods = [];
  List<PaymentMethod> _deletedPaymentMethods = [];
  List<PaymentMethod> _filtrelenmisYontemler = [];

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
    _paymentMethods = List.from(widget.paymentMethods);
    _deletedPaymentMethods = List.from(widget.deletedPaymentMethods);
    _filtrelenmisYontemler = _paymentMethods;

    // Kısa skeleton animasyonu için 300ms bekle
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  void didUpdateWidget(covariant PaymentMethodsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.paymentMethods != oldWidget.paymentMethods) {
      _paymentMethods = List.from(widget.paymentMethods);
      _filtrele();
    }
  }

  void _filtrele() {
    setState(() {
      if (_aramaModu && _aramaController.text.isNotEmpty) {
        String aranan = _aramaController.text.toLowerCase();
        _filtrelenmisYontemler = _paymentMethods.where((pm) {
          return pm.name.toLowerCase().contains(aranan) ||
              pm.typeDisplayName.toLowerCase().contains(aranan);
        }).toList();
      } else {
        _filtrelenmisYontemler = _paymentMethods;
      }
    });
  }

  @override
  void dispose() {
    _aramaController.dispose();
    super.dispose();
  }

  double get totalBalance {
    return _filtrelenmisYontemler
        .where((pm) => pm.type != 'kredi')
        .fold(0.0, (sum, pm) => sum + pm.balance);
  }

  double get totalDebt {
    return _filtrelenmisYontemler
        .where((pm) => pm.type == 'kredi')
        .fold(0.0, (sum, pm) => sum + pm.balance);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: _aramaModu
            ? TextField(
                controller: _aramaController,
                onChanged: (value) => _filtrele(),
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Ödeme yöntemi ara...",
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              )
            : const Text("Ödeme Yöntemlerim"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.white),
            tooltip: "Çöp Kutusu",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PaymentMethodRecycleBinPage(
                    deletedPaymentMethods: _deletedPaymentMethods,
                    onRestore: (pm) {
                      setState(() {
                        _deletedPaymentMethods.removeWhere(
                          (p) => p.id == pm.id,
                        );
                        final restored = pm.copyWith(isDeleted: false);
                        _paymentMethods.add(restored);
                        _filtrele();
                      });
                      widget.onRestore(pm);
                    },
                    onPermanentDelete: (pm) {
                      setState(() {
                        _deletedPaymentMethods.removeWhere(
                          (p) => p.id == pm.id,
                        );
                      });
                      widget.onPermanentDelete(pm);
                    },
                    onEmptyBin: () {
                      setState(() {
                        _deletedPaymentMethods.clear();
                      });
                      widget.onEmptyBin();
                    },
                  ),
                ),
              ).then((_) => setState(() {}));
            },
          ),
          IconButton(
            icon: Icon(
              _aramaModu ? Icons.close : Icons.search,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _aramaModu = !_aramaModu;
                if (!_aramaModu) {
                  _aramaController.clear();
                  _filtrelenmisYontemler = widget.paymentMethods;
                }
              });
            },
          ),
        ],
      ),
      body: _isLoading
          ? const PaymentMethodsPageSkeleton()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Toplam Özet Kartı - Kingmode Carousel
                  PaymentMethodSummaryCard(
                    totalBalance: totalBalance,
                    totalDebt: totalDebt,
                    userName: widget.userName ?? 'Kullanıcı',
                    userProfileUrl: widget.userProfileUrl,
                    paymentMethods: _filtrelenmisYontemler,
                  ),
                  const SizedBox(height: 24),
                  _buildPaymentMethodsList(),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Yeni ödeme yöntemi ekleme sayfasına git
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddPaymentMethodPage(
                onSave:
                    (name, type, lastFourDigits, balance, limit, colorIndex) {
                      final newPm = PaymentMethod(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        name: name,
                        type: type,
                        lastFourDigits: lastFourDigits,
                        balance: balance,
                        limit: limit,
                        colorIndex: colorIndex,
                        createdAt: DateTime.now(),
                        isDeleted: false,
                      );
                      setState(() {
                        _paymentMethods.add(newPm);
                        _filtrele();
                      });
                      widget.onAdd(
                        name,
                        type,
                        lastFourDigits,
                        balance,
                        limit,
                        colorIndex,
                      );
                    },
              ),
            ),
          ).then((_) => setState(() {})); // Sayfadan dönünce state'i yenile
        },
        backgroundColor: Theme.of(context).colorScheme.secondary,
        icon: const Icon(Icons.add, color: Colors.black),
        label: const Text(
          "Kart Ekle",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildPaymentMethodsList() {
    if (_filtrelenmisYontemler.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 40),
          child: Text(
            _aramaModu && _aramaController.text.isNotEmpty
                ? "Sonuç bulunamadı."
                : "Henüz ödeme yöntemi eklenmedi.",
            style: TextStyle(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.54),
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _filtrelenmisYontemler.length,
      // itemExtent: Sabit yükseklik belirterek scroll performansını artırır
      // Her kart 140px yükseklik + 16px bottom margin = 156px
      itemExtent: 156,
      itemBuilder: (context, index) {
        final pm = _filtrelenmisYontemler[index];
        return _buildPaymentMethodCard(pm);
      },
    );
  }

  Widget _buildPaymentMethodCard(PaymentMethod pm) {
    final colors = _cardColors[pm.colorIndex.clamp(0, _cardColors.length - 1)];

    // RepaintBoundary: Bu kartın repaint'ini izole eder
    return RepaintBoundary(
      child: Dismissible(
        key: Key(pm.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: ColorConstants.koyuKirmizi,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(Icons.delete, color: Colors.white),
        ),
        onDismissed: (direction) {
          setState(() {
            _paymentMethods.removeWhere((p) => p.id == pm.id);
            final deleted = pm.copyWith(isDeleted: true);
            _deletedPaymentMethods.add(deleted);
            _filtrele();
          });
          widget.onDelete(pm);
        },
        child: GestureDetector(
          onTap: () {
            // Detay sayfasına yönlendir (eğer callback tanımlıysa)
            if (widget.onCardTap != null) {
              widget.onCardTap!(pm);
            }
          },
          onLongPress: () {
            // Düzenleme sayfasına git
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddPaymentMethodPage(
                  paymentMethod: pm,
                  onSave:
                      (name, type, lastFourDigits, balance, limit, colorIndex) {
                        final updatedPm = PaymentMethod(
                          id: pm.id,
                          name: name,
                          type: type,
                          lastFourDigits: lastFourDigits,
                          balance: balance,
                          limit: limit,
                          colorIndex: colorIndex,
                          createdAt: pm.createdAt,
                          isDeleted: false,
                        );
                        setState(() {
                          final idx = _paymentMethods.indexWhere(
                            (p) => p.id == pm.id,
                          );
                          if (idx != -1) {
                            _paymentMethods[idx] = updatedPm;
                          }
                          _filtrele();
                        });
                        widget.onEdit(updatedPm);
                      },
                ),
              ),
            ).then((_) => setState(() {})); // Sayfadan dönünce state'i yenile
          },
          child: Container(
            height: 140,
            margin: const EdgeInsets.only(bottom: 16),
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
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Üst satır
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        pm.typeDisplayName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Icon(
                      pm.type == 'nakit'
                          ? Icons.wallet
                          : pm.type == 'kredi'
                          ? Icons.credit_card
                          : Icons.account_balance,
                      color: Colors.white.withValues(alpha: 0.7),
                      size: 24,
                    ),
                  ],
                ),
                // Kart numarası
                if (pm.type != 'nakit' && pm.lastFourDigits != null)
                  Text(
                    '•••• •••• •••• ${pm.lastFourDigits}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 14,
                      letterSpacing: 2,
                    ),
                  ),
                // Alt satır
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pm.name.toUpperCase(),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 11,
                            letterSpacing: 1,
                          ),
                        ),
                        if (pm.type == 'kredi' && pm.limit != null)
                          Text(
                            'Limit: ${pm.limit!.toStringAsFixed(0)} ₺',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.5),
                              fontSize: 10,
                            ),
                          ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          pm.type == 'kredi' ? 'Borç' : 'Bakiye',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 10,
                          ),
                        ),
                        Text(
                          '${pm.balance.toStringAsFixed(2)} ₺',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
