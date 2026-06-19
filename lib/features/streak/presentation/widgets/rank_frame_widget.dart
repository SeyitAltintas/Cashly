import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../data/constants/streak_badges.dart';
import '../../data/models/streak_model.dart';
import 'package:cashly/core/utils/image_utils.dart';

/// Profil fotoğrafını rank Lottie animasyonuyla çerçeveleyen widget
/// Valorant tarzında: animasyon çerçevesi profil fotoğrafının üzerine overlay olarak render edilir
class RankFrameWidget extends StatefulWidget {
  final RankData rankData;
  final String? profileImagePath;
  final double size;
  final VoidCallback? onTap;

  const RankFrameWidget({
    super.key,
    required this.rankData,
    this.profileImagePath,
    this.size = 100,
    this.onTap,
  });

  @override
  State<RankFrameWidget> createState() => _RankFrameWidgetState();
}

class _RankFrameWidgetState extends State<RankFrameWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rank = RankTiers.fromXp(widget.rankData.totalXp);
    final size = widget.size;
    // Lottie çerçeve boyutu profil fotoğrafından biraz büyük olmalı
    final frameSize = size * 1.7;

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _glowController,
        builder: (context, child) {
          return SizedBox(
            width: frameSize,
            height: frameSize,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Rank renkli glow arka plan
                Container(
                  width: size + 8,
                  height: size + 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: rank.glowColor.withValues(
                          alpha: 0.3 + _glowController.value * 0.25,
                        ),
                        blurRadius: 20 + _glowController.value * 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
                // Profil fotoğrafı
                _buildProfileAvatar(size, rank),
                // Lottie rank çerçevesi (üstte overlay)
                RepaintBoundary(
                  child: SizedBox(
                    width: frameSize,
                    height: frameSize,
                    child: Lottie.asset(
                      rank.lottieAsset,
                      fit: BoxFit.contain,
                      frameRate: const FrameRate(60),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileAvatar(double size, RankTier rank) {
    final hasImage = widget.profileImagePath?.isNotEmpty ?? false;
    final provider = hasImage
        ? ImageUtils.getProfileImageProvider(widget.profileImagePath)
        : null;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: rank.primaryColor.withValues(alpha: 0.6),
          width: 2.5,
        ),
      ),
      child: ClipOval(
        child: provider != null
            ? Image(
                image: provider,
                width: size,
                height: size,
                fit: BoxFit.cover,
              )
            : _buildAvatarFallback(size, rank),
      ),
    );
  }

  Widget _buildAvatarFallback(double size, RankTier rank) {
    return Container(
      color: rank.primaryColor.withValues(alpha: 0.15),
      child: Icon(
        Icons.person,
        size: size * 0.5,
        color: rank.primaryColor.withValues(alpha: 0.8),
      ),
    );
  }
}

/// Rank adı badge'i — profil çerçevesinin altında gösterilir
class RankNameBadge extends StatelessWidget {
  final RankData rankData;

  const RankNameBadge({super.key, required this.rankData});

  @override
  Widget build(BuildContext context) {
    final rank = RankTiers.fromXp(rankData.totalXp);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            rank.primaryColor.withValues(alpha: 0.9),
            rank.glowColor.withValues(alpha: 0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: rank.glowColor.withValues(alpha: 0.4),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        rank.name,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
