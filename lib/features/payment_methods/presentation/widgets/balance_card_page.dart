import 'package:flutter/material.dart';
import 'dart:io';
import 'package:cashly/core/utils/currency_formatter.dart';

/// Carousel Sayfa 1: Toplam Bakiye + Profil
/// Premium banka kartı tasarımıyla toplam bakiye ve kullanıcı bilgilerini gösterir
class BalanceCardPage extends StatelessWidget {
  final double totalBalance;
  final String userName;
  final String? userProfileUrl;
  final Animation<double> shimmerAnimation;
  final Animation<double> holoAnimation;

  const BalanceCardPage({
    super.key,
    required this.totalBalance,
    required this.userName,
    required this.shimmerAnimation,
    required this.holoAnimation,
    this.userProfileUrl,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive değerler hesapla
        final cardWidth = constraints.maxWidth;
        final cardHeight = constraints.maxHeight;

        // Profil resmi boyutu - kart yüksekliğinin %40'i
        final profileSize = (cardHeight * 0.40).clamp(60.0, 100.0);

        // Logo boyutu - kart yüksekliğinin %35'i
        final logoSize = (cardHeight * 0.35).clamp(50.0, 80.0);

        // Font boyutları
        final balanceFontSize = (cardWidth * 0.085).clamp(22.0, 32.0);
        final labelFontSize = (cardWidth * 0.028).clamp(9.0, 11.0);
        final userNameFontSize = (cardWidth * 0.032).clamp(10.0, 12.0);

        // Padding değerleri
        final horizontalPadding = (cardWidth * 0.04).clamp(12.0, 20.0);
        final verticalPadding = (cardHeight * 0.08).clamp(12.0, 20.0);
        final spacing = (cardHeight * 0.08).clamp(12.0, 20.0);

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 0.2,
            ),
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
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: holoAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(cardWidth * holoAnimation.value, 0),
                        child: child,
                      );
                    },
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

                // Geliştirilmiş Guilloche pattern
                Positioned.fill(
                  child: CustomPaint(painter: EnhancedCardPatternPainter()),
                ),

                // Kart içeriği
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    verticalPadding,
                    horizontalPadding,
                    verticalPadding,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Sol bölüm: Tüm bilgiler
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Üst satır: Logo
                            Transform.translate(
                              offset: const Offset(0, -20),
                              child: Image.asset(
                                'assets/image/seffaflogo.png',
                                height: logoSize,
                                width: logoSize,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    height: logoSize,
                                    width: logoSize,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF6C63FF),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.account_balance_wallet,
                                      color: Colors.white,
                                      size: logoSize * 0.5,
                                    ),
                                  );
                                },
                              ),
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
                                    fontSize: labelFontSize,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                AnimatedBuilder(
                                  animation: shimmerAnimation,
                                  builder: (context, child) {
                                    return ShaderMask(
                                      shaderCallback: (bounds) {
                                        return LinearGradient(
                                          colors: const [
                                            Colors.white,
                                            Color(0xFF6C63FF),
                                            Colors.white,
                                          ],
                                          stops:
                                              [
                                                    shimmerAnimation.value -
                                                        0.3,
                                                    shimmerAnimation.value,
                                                    shimmerAnimation.value +
                                                        0.3,
                                                  ]
                                                  .map((s) => s.clamp(0.0, 1.0))
                                                  .toList(),
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight,
                                        ).createShader(bounds);
                                      },
                                      child: Text(
                                        CurrencyFormatter.format(totalBalance),
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: balanceFontSize,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: -0.5,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),

                            SizedBox(height: spacing),

                            // Kullanıcı bilgisi
                            Row(
                              children: [
                                Flexible(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        userName.toUpperCase(),
                                        style: TextStyle(
                                          color: Colors.white.withValues(
                                            alpha: 0.9,
                                          ),
                                          fontSize: userNameFontSize,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 1,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      SizedBox(width: horizontalPadding * 0.5),

                      // Sağ bölüm: Chip ve profil
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // Üst: Altın kart çipi ve temassız simgesi
                          SizedBox(
                            height: logoSize,
                            child: Align(
                              alignment: Alignment.topRight,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Altın kart çipi
                                  Container(
                                    width: 40,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4),
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFFB8860B),
                                          Color(0xFFDAA520),
                                          Color(0xFFB8860B),
                                          Color(0xFF8B6914),
                                        ],
                                        stops: [0.0, 0.3, 0.6, 1.0],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(
                                            0xFFD4AF37,
                                          ).withValues(alpha: 0.3),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: CustomPaint(
                                      painter: ChipLinePainter(),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // Temassız simgesi
                                  Transform.rotate(
                                    angle: 1.5708,
                                    child: Icon(
                                      Icons.wifi,
                                      color: Colors.white.withValues(
                                        alpha: 0.8,
                                      ),
                                      size: 24,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const Spacer(),
                          // Alt: Profil resmi
                          SizedBox(
                            width: profileSize,
                            height: profileSize,
                            child: ClipOval(
                              child: ShaderMask(
                                shaderCallback: (Rect bounds) {
                                  return RadialGradient(
                                    center: Alignment.center,
                                    radius: 0.5,
                                    colors: [
                                      Colors.white,
                                      Colors.white,
                                      Colors.white.withValues(alpha: 0.7),
                                      Colors.white.withValues(alpha: 0.3),
                                      Colors.white.withValues(alpha: 0.0),
                                    ],
                                    stops: const [0.0, 0.6, 0.8, 0.9, 1.0],
                                  ).createShader(bounds);
                                },
                                blendMode: BlendMode.dstIn,
                                child: _buildProfileImage(userName),
                              ),
                            ),
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
      },
    );
  }

  /// Profil resmini oluşturur
  Widget _buildProfileImage(String userName) {
    if (userProfileUrl != null && userProfileUrl!.isNotEmpty) {
      if (userProfileUrl!.startsWith('http://') ||
          userProfileUrl!.startsWith('https://')) {
        return Image.network(
          userProfileUrl!,
          fit: BoxFit.cover,
          width: 100,
          height: 100,
          errorBuilder: (context, error, stackTrace) {
            return _buildDefaultAvatar(userName);
          },
        );
      } else {
        final file = File(userProfileUrl!);
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
}

/// Geliştirilmiş banka kartı doku deseni için CustomPainter
class EnhancedCardPatternPainter extends CustomPainter {
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

/// Altın kart çipi üzerindeki yatay çizgiler için CustomPainter
class ChipLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF8B6914).withValues(alpha: 0.6)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Yatay çizgiler
    for (double y = 5; y < size.height; y += 8) {
      canvas.drawLine(Offset(3, y), Offset(size.width - 3, y), paint);
    }

    // Dikey orta çizgi
    canvas.drawLine(
      Offset(size.width / 2, 2),
      Offset(size.width / 2, size.height - 2),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
