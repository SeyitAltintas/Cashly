import 'package:flutter/material.dart';
import 'dart:io';
import 'package:cashly/core/constants/color_constants.dart';
import 'package:cashly/core/widgets/skeleton_widget.dart';

import '../../data/models/payment_method_model.dart';
import '../widgets/add_payment_method_sheet.dart';
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

  final List<List<Color>> _cardColors = [
    [const Color(0xFF1a1a2e), const Color(0xFF16213e)], // Koyu Mavi
    [const Color(0xFF2d132c), const Color(0xFF432371)], // Mor
    [const Color(0xFF0f3460), const Color(0xFF16537e)], // Mavi
    [const Color(0xFF1e5128), const Color(0xFF4e9f3d)], // Yeşil
    [const Color(0xFF5c2018), const Color(0xFF8b3a2f)], // Kırmızı
    [const Color(0xFF3d3d3d), const Color(0xFF5a5a5a)], // Gri
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
                  // Toplam Özet Kartı
                  _buildSummaryCard(context),
                  const SizedBox(height: 24),
                  _buildPaymentMethodsList(),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => AddPaymentMethodSheet(
              onSave: (name, type, lastFourDigits, balance, limit, colorIndex) {
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
          );
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

  Widget _buildSummaryCard(BuildContext context) {
    final userName = widget.userName ?? 'Kullanıcı';

    return Container(
      height: 250,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C63FF).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
            spreadRadius: -5,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Arka plan gradient - Premium metalik efekt
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF1a1a2e),
                    const Color(0xFF16213e),
                    const Color(0xFF0f3460),
                    const Color(0xFF1a1a2e),
                  ],
                  stops: const [0.0, 0.3, 0.7, 1.0],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),

            // Holografik şerit efekti (sağ üst köşeden)
            Positioned(
              top: -50,
              right: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF6C63FF).withValues(alpha: 0.15),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Alt sol köşede ışık efekti
            Positioned(
              bottom: -30,
              left: -30,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF00D9FF).withValues(alpha: 0.1),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // İnce çizgi deseni (kart dokusu)
            Positioned.fill(child: CustomPaint(painter: _CardPatternPainter())),

            // Kart içeriği - Row ile sol bölüm ve sağda profil resmi
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Sol bölüm: Tüm bilgiler
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Üst satır: Sadece Cashly Logo (80px)
                        Image.asset(
                          'assets/image/seffaflogo.png',
                          height: 80,
                          width: 80,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 80,
                              width: 80,
                              decoration: BoxDecoration(
                                color: const Color(0xFF6C63FF),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.account_balance_wallet,
                                color: Colors.white,
                                size: 40,
                              ),
                            );
                          },
                        ),

                        const Spacer(),

                        // Toplam Bakiye
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'TOPLAM BAKİYE',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.5),
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            ShaderMask(
                              shaderCallback: (bounds) => const LinearGradient(
                                colors: [Colors.white, Color(0xFFE0E0E0)],
                              ).createShader(bounds),
                              child: Text(
                                '${totalBalance.toStringAsFixed(2)} ₺',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 25),

                        // Kullanıcı bilgisi ve borç (alt satır)
                        Row(
                          children: [
                            // Kullanıcı adı ve üyelik tipi
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    userName.toUpperCase(),
                                    style: TextStyle(
                                      color: Colors.white.withValues(
                                        alpha: 0.9,
                                      ),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 1,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                  // Kredi borcu (varsa)
                                  if (totalDebt > 0)
                                    Container(
                                      margin: const EdgeInsets.only(top: 4),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: ColorConstants.koyuKirmizi
                                            .withValues(alpha: 0.25),
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(
                                          color: ColorConstants.koyuKirmizi
                                              .withValues(alpha: 0.3),
                                        ),
                                      ),
                                      child: Text(
                                        'Borç: ${totalDebt.toStringAsFixed(0)} ₺',
                                        style: TextStyle(
                                          color: Colors.white.withValues(
                                            alpha: 0.9,
                                          ),
                                          fontSize: 9,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Sağ bölüm: Sadece Profil resmi
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Profil resmi
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.4),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFF6C63FF,
                              ).withValues(alpha: 0.4),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                              spreadRadius: -2,
                            ),
                          ],
                        ),
                        child: ClipOval(child: _buildProfileImage(userName)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Profil resmini oluşturur - dosya yolu, network URL veya varsayılan avatar
  Widget _buildProfileImage(String userName) {
    final profileUrl = widget.userProfileUrl;

    // Profil resmi yolu varsa
    if (profileUrl != null && profileUrl.isNotEmpty) {
      // Dosya yolu mu yoksa network URL mi kontrol et
      if (profileUrl.startsWith('http://') ||
          profileUrl.startsWith('https://')) {
        // Network resmi
        return Image.network(
          profileUrl,
          fit: BoxFit.cover,
          width: 90,
          height: 90,
          errorBuilder: (context, error, stackTrace) {
            return _buildDefaultAvatar(userName);
          },
        );
      } else {
        // Dosya yolu (lokal dosya)
        final file = File(profileUrl);
        if (file.existsSync()) {
          return Image.file(
            file,
            fit: BoxFit.cover,
            width: 90,
            height: 90,
            errorBuilder: (context, error, stackTrace) {
              return _buildDefaultAvatar(userName);
            },
          );
        }
      }
    }

    // Varsayılan avatar
    return _buildDefaultAvatar(userName);
  }

  /// Varsayılan avatar widget'ı
  Widget _buildDefaultAvatar(String userName) {
    return Container(
      color: const Color(0xFF6C63FF),
      child: Center(
        child: Text(
          userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 36,
          ),
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
            // Düzenleme sheet'ini aç
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => AddPaymentMethodSheet(
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
            );
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

/// Banka kartı doku deseni için CustomPainter
class _CardPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.03)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    // Çapraz ince çizgiler
    const spacing = 20.0;
    for (double i = -size.height; i < size.width + size.height; i += spacing) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
