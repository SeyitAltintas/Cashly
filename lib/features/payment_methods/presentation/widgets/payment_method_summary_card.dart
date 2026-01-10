import 'package:flutter/material.dart';
import 'dart:io';
import 'package:cashly/core/constants/color_constants.dart';
import 'package:cashly/core/utils/currency_formatter.dart';
import '../../data/models/payment_method_model.dart';

/// Ödeme yöntemleri özet kartı widget'ı - Kingmode Carousel formatında
/// Sayfa 1: Toplam bakiye, profil, kullanıcı bilgisi
/// Sayfa 2: Kart dağılımı (Nakit/Banka/Kredi oranları)
/// Sayfa 3: Borç analizi (limit kullanım oranı)
class PaymentMethodSummaryCard extends StatefulWidget {
  final double totalBalance;
  final double totalDebt;
  final String userName;
  final String? userProfileUrl;
  final List<PaymentMethod> paymentMethods;

  const PaymentMethodSummaryCard({
    super.key,
    required this.totalBalance,
    required this.totalDebt,
    required this.userName,
    required this.paymentMethods,
    this.userProfileUrl,
  });

  @override
  State<PaymentMethodSummaryCard> createState() =>
      _PaymentMethodSummaryCardState();
}

class _PaymentMethodSummaryCardState extends State<PaymentMethodSummaryCard>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Animasyon controller'ları
  late AnimationController _shimmerController;
  late AnimationController _glowController;
  late AnimationController _holoController;
  late Animation<double> _shimmerAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _holoAnimation;

  @override
  void initState() {
    super.initState();

    // Shimmer animasyonu - bakiye için
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();
    _shimmerAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );

    // Glow animasyonu - profil resmi için
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    // Holografik stripe animasyonu
    _holoController = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    )..repeat();
    _holoAnimation = Tween<double>(
      begin: -0.5,
      end: 1.5,
    ).animate(CurvedAnimation(parent: _holoController, curve: Curves.linear));
  }

  @override
  void dispose() {
    _pageController.dispose();
    _shimmerController.dispose();
    _glowController.dispose();
    _holoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      height: 250,
      child: Column(
        children: [
          // Carousel içeriği
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() => _currentPage = index);
              },
              children: [
                _buildBalancePage(context),
                _buildDistributionPage(context),
                _buildDebtAnalysisPage(context),
              ],
            ),
          ),
          // Sayfa göstergesi
          const SizedBox(height: 8),
          _buildPageIndicator(),
        ],
      ),
    );
  }

  /// Sayfa 1: Toplam Bakiye + Profil
  Widget _buildBalancePage(BuildContext context) {
    return Container(
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
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF1a1a2e),
                    Color(0xFF16213e),
                    Color(0xFF0f3460),
                    Color(0xFF1a1a2e),
                  ],
                  stops: [0.0, 0.3, 0.7, 1.0],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),

            // Animated Holografik stripe efekti
            AnimatedBuilder(
              animation: _holoAnimation,
              builder: (context, child) {
                return Positioned(
                  top: 0,
                  bottom: 0,
                  left:
                      MediaQuery.of(context).size.width * _holoAnimation.value,
                  child: Container(
                    width: 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.white.withValues(alpha: 0.05),
                          Colors.white.withValues(alpha: 0.1),
                          Colors.white.withValues(alpha: 0.05),
                          Colors.transparent,
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
                  ),
                );
              },
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

            // Geliştirilmiş Guilloche pattern
            Positioned.fill(
              child: CustomPaint(painter: _EnhancedCardPatternPainter()),
            ),

            // Kart içeriği
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
                        // Üst satır: Logo ve Contactless ikonu
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Image.asset(
                              'assets/image/seffaflogo.png',
                              height: 60,
                              width: 60,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 60,
                                  width: 60,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF6C63FF),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.account_balance_wallet,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                );
                              },
                            ),
                            // Contactless/NFC ikonu
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.contactless,
                                color: Colors.white.withValues(alpha: 0.8),
                                size: 24,
                              ),
                            ),
                          ],
                        ),

                        const Spacer(),

                        // Toplam Bakiye - Shimmer efektli
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'TOPLAM BAKİYE',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.6),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            AnimatedBuilder(
                              animation: _shimmerAnimation,
                              builder: (context, child) {
                                return ShaderMask(
                                  shaderCallback: (bounds) {
                                    return LinearGradient(
                                      colors: const [
                                        Colors.white,
                                        Color(0xFF6C63FF),
                                        Colors.white,
                                      ],
                                      stops: [
                                        _shimmerAnimation.value - 0.3,
                                        _shimmerAnimation.value,
                                        _shimmerAnimation.value + 0.3,
                                      ].map((s) => s.clamp(0.0, 1.0)).toList(),
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ).createShader(bounds);
                                  },
                                  child: Text(
                                    CurrencyFormatter.format(
                                      widget.totalBalance,
                                    ),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 32,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Kullanıcı bilgisi ve borç
                        Row(
                          children: [
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.userName.toUpperCase(),
                                    style: TextStyle(
                                      color: Colors.white.withValues(
                                        alpha: 0.9,
                                      ),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 1,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                  // Kredi borcu (varsa)
                                  if (widget.totalDebt > 0)
                                    Container(
                                      margin: const EdgeInsets.only(top: 6),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            ColorConstants.koyuKirmizi
                                                .withValues(alpha: 0.4),
                                            ColorConstants.koyuKirmizi
                                                .withValues(alpha: 0.2),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: ColorConstants.koyuKirmizi
                                              .withValues(alpha: 0.5),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.credit_card,
                                            color: Colors.white.withValues(
                                              alpha: 0.8,
                                            ),
                                            size: 12,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Borç: ${CurrencyFormatter.format(widget.totalDebt)}',
                                            style: TextStyle(
                                              color: Colors.white.withValues(
                                                alpha: 0.9,
                                              ),
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
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

                  // Sağ bölüm: Profil resmi - Animated glow
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedBuilder(
                        animation: _glowAnimation,
                        builder: (context, child) {
                          return Container(
                            width: 100,
                            height: 100,
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
                                  ).withValues(alpha: _glowAnimation.value),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                                BoxShadow(
                                  color: const Color(0xFF00D9FF).withValues(
                                    alpha: _glowAnimation.value * 0.5,
                                  ),
                                  blurRadius: 30,
                                  spreadRadius: -5,
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: _buildProfileImage(widget.userName),
                            ),
                          );
                        },
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

  /// Sayfa 2: Kart Dağılımı
  Widget _buildDistributionPage(BuildContext context) {
    // Kart tiplerini hesapla
    final nakitKartlar = widget.paymentMethods
        .where((pm) => pm.type == 'nakit')
        .toList();
    final bankaKartlar = widget.paymentMethods
        .where((pm) => pm.type == 'banka')
        .toList();
    final krediKartlar = widget.paymentMethods
        .where((pm) => pm.type == 'kredi')
        .toList();

    final nakitToplam = nakitKartlar.fold(0.0, (sum, pm) => sum + pm.balance);
    final bankaToplam = bankaKartlar.fold(0.0, (sum, pm) => sum + pm.balance);
    final krediToplam = krediKartlar.fold(0.0, (sum, pm) => sum + pm.balance);

    final toplamVarlik = nakitToplam + bankaToplam;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF6C63FF).withValues(alpha: 0.25),
            const Color(0xFF6C63FF).withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF6C63FF).withValues(alpha: 0.4),
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.pie_chart_outline,
                    color: Colors.white.withValues(alpha: 0.6),
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'KART DAĞILIMI',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 11,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${widget.paymentMethods.length} Kart',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const Spacer(),

          // Kart tipleri
          _buildDistributionBar(
            'Nakit',
            nakitKartlar.length,
            nakitToplam,
            toplamVarlik,
            Colors.greenAccent,
            Icons.wallet,
          ),
          const SizedBox(height: 12),
          _buildDistributionBar(
            'Banka',
            bankaKartlar.length,
            bankaToplam,
            toplamVarlik,
            Colors.blueAccent,
            Icons.account_balance,
          ),
          const SizedBox(height: 12),
          _buildDistributionBar(
            'Kredi',
            krediKartlar.length,
            krediToplam,
            krediToplam > 0 ? krediToplam : 1, // Borç gösterimi için
            ColorConstants.kirmiziVurgu,
            Icons.credit_card,
            isDebt: true,
          ),
        ],
      ),
    );
  }

  /// Dağılım bar widget'ı
  Widget _buildDistributionBar(
    String label,
    int count,
    double amount,
    double total,
    Color color,
    IconData icon, {
    bool isDebt = false,
  }) {
    final ratio = total > 0 ? (amount / total).clamp(0.0, 1.0) : 0.0;

    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$label ($count)',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    isDebt
                        ? '-${CurrencyFormatter.format(amount)}'
                        : CurrencyFormatter.format(amount),
                    style: TextStyle(
                      color: isDebt ? color : Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: isDebt ? 1.0 : ratio,
                  backgroundColor: Colors.white.withValues(alpha: 0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  minHeight: 4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Sayfa 3: Borc Analizi
  Widget _buildDebtAnalysisPage(BuildContext context) {
    // Kredi kartlarini al
    final krediKartlar = widget.paymentMethods
        .where((pm) => pm.type == 'kredi')
        .toList();
    final toplamBorc = krediKartlar.fold(0.0, (sum, pm) => sum + pm.balance);
    final toplamLimit = krediKartlar.fold(
      0.0,
      (sum, pm) => sum + (pm.limit ?? 0),
    );
    final kullanimOrani = toplamLimit > 0
        ? (toplamBorc / toplamLimit).clamp(0.0, 1.0)
        : 0.0;

    Color durumRengi = Colors.greenAccent;
    String durumMesaji = 'İyi durumda';
    IconData durumIkon = Icons.check_circle_outline;

    if (kullanimOrani > 0.5) {
      durumRengi = Colors.orangeAccent;
      durumMesaji = 'Dikkatli olun';
      durumIkon = Icons.warning_amber_outlined;
    }
    if (kullanimOrani > 0.8) {
      durumRengi = ColorConstants.kirmiziVurgu;
      durumMesaji = 'Kritik seviye!';
      durumIkon = Icons.error_outline;
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ColorConstants.kirmiziVurgu.withValues(alpha: 0.25),
            ColorConstants.kirmiziVurgu.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: ColorConstants.kirmiziVurgu.withValues(alpha: 0.4),
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.trending_down,
                    color: Colors.white.withValues(alpha: 0.6),
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'BORÇ ANALİZİ',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 11,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: durumRengi.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: durumRengi.withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(durumIkon, color: durumRengi, size: 12),
                    const SizedBox(width: 4),
                    Text(
                      durumMesaji,
                      style: TextStyle(
                        color: durumRengi,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const Spacer(),

          // Toplam borc
          Text(
            CurrencyFormatter.format(toplamBorc),
            style: TextStyle(
              color: toplamBorc > 0
                  ? ColorConstants.kirmiziVurgu
                  : Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 12),

          // Limit kullanım oranı
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Limit Kullanımı',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 11,
                    ),
                  ),
                  Text(
                    '%${(kullanimOrani * 100).toStringAsFixed(0)}',
                    style: TextStyle(
                      color: durumRengi,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: kullanimOrani,
                  backgroundColor: Colors.white.withValues(alpha: 0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(durumRengi),
                  minHeight: 8,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Alt bilgi
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildDebtInfoChip(
                'Kullanilan',
                CurrencyFormatter.format(toplamBorc),
                ColorConstants.kirmiziVurgu,
              ),
              _buildDebtInfoChip(
                'Toplam Limit',
                CurrencyFormatter.format(toplamLimit),
                Colors.blueAccent,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Borç bilgi chip'i
  Widget _buildDebtInfoChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 9,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// Profil resmini oluşturur
  Widget _buildProfileImage(String userName) {
    final profileUrl = widget.userProfileUrl;

    if (profileUrl != null && profileUrl.isNotEmpty) {
      if (profileUrl.startsWith('http://') ||
          profileUrl.startsWith('https://')) {
        return Image.network(
          profileUrl,
          fit: BoxFit.cover,
          width: 100,
          height: 100,
          errorBuilder: (context, error, stackTrace) {
            return _buildDefaultAvatar(userName);
          },
        );
      } else {
        final file = File(profileUrl);
        if (file.existsSync()) {
          return Image.file(
            file,
            fit: BoxFit.cover,
            width: 100,
            height: 100,
            errorBuilder: (context, error, stackTrace) {
              return _buildDefaultAvatar(userName);
            },
          );
        }
      }
    }

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
            fontSize: 40,
          ),
        ),
      ),
    );
  }

  /// Sayfa göstergesi (animated dots)
  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 8,
          width: _currentPage == index ? 24 : 8,
          decoration: BoxDecoration(
            color: _currentPage == index
                ? const Color(0xFF6C63FF)
                : Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(4),
            boxShadow: _currentPage == index
                ? [
                    BoxShadow(
                      color: const Color(0xFF6C63FF).withValues(alpha: 0.5),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
        );
      }),
    );
  }
}

/// Geliştirilmiş banka kartı doku deseni için CustomPainter
class _EnhancedCardPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.03)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    // Çapraz ince çizgiler (Guilloche pattern)
    const spacing = 15.0;
    for (double i = -size.height; i < size.width + size.height; i += spacing) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        paint,
      );
    }

    // Dalgalı çizgiler (wave pattern)
    final wavePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.02)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final path = Path();
    const waveHeight = 30.0;
    const waveLength = 60.0;

    for (double y = 50; y < size.height; y += 50) {
      path.moveTo(0, y);
      for (double x = 0; x < size.width; x += waveLength) {
        path.quadraticBezierTo(
          x + waveLength / 4,
          y - waveHeight,
          x + waveLength / 2,
          y,
        );
        path.quadraticBezierTo(
          x + waveLength * 3 / 4,
          y + waveHeight,
          x + waveLength,
          y,
        );
      }
    }
    canvas.drawPath(path, wavePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
