import 'package:flutter/material.dart';
import 'balance_card_page.dart';
import 'debt_analysis_card_page.dart';
import '../../data/models/payment_method_model.dart';

/// Ödeme yöntemleri özet kartı widget'ı - Kingmode Carousel formatında
/// Sayfa 1: Toplam bakiye, profil, kullanıcı bilgisi
/// Sayfa 2: Borç analizi (limit kullanım oranı)
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
  final PageController _pageController = PageController(viewportFraction: 1.0);
  int _currentPage = 0;

  // Animasyon controller'ları
  late AnimationController _shimmerController;
  late AnimationController _holoController;
  late Animation<double> _shimmerAnimation;
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
    _holoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Ekran genişliğine göre kart yüksekliği hesapla
          final cardWidth = constraints.maxWidth;
          final cardHeight = (cardWidth / 1.7).clamp(180.0, 280.0);

          return SizedBox(
            height: cardHeight + 20, // Page indicator için ek alan
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
                      // Sayfa 1: Bakiye kartı
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: BalanceCardPage(
                          totalBalance: widget.totalBalance,
                          userName: widget.userName,
                          userProfileUrl: widget.userProfileUrl,
                          shimmerAnimation: _shimmerAnimation,
                          holoAnimation: _holoAnimation,
                        ),
                      ),
                      // Sayfa 2: Borç analizi kartı
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: DebtAnalysisCardPage(
                          paymentMethods: widget.paymentMethods,
                        ),
                      ),
                    ],
                  ),
                ),
                // Sayfa göstergesi
                const SizedBox(height: 8),
                _buildPageIndicator(),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Sayfa göstergesi (animated dots)
  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(2, (index) {
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
