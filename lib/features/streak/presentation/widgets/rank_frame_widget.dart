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
    with TickerProviderStateMixin {
  late AnimationController _glowController;
  late AnimationController _lottieController;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);

    _lottieController = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _glowController.dispose();
    _lottieController.dispose();
    super.dispose();
  }

  double _getAvatarScaleRatio(int level) {
    switch (level) {
      case 1:
      case 2:
        return 0.85;
      case 3:
      case 4:
      case 5:
      case 6:
        return 0.88;
      case 7:
        return 0.75;
      case 8:
        return 0.77;
      case 9:
        return 0.75;
      default:
        return 0.85;
    }
  }

  @override
  Widget build(BuildContext context) {
    final rank = RankTiers.fromXp(widget.rankData.totalXp);
    final size = widget.size;
    // Lottie boyutu (çerçeve) - Daha büyük gösterişli kanatlar
    final frameSize = size * 2.4;
    // Profil resmi boyutu - Level'a özel dinamik oran
    final avatarSize = size * _getAvatarScaleRatio(rank.level);

    return GestureDetector(
      onTap: widget.onTap,
      child: SizedBox(
        width: frameSize,
        height: frameSize,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Glow efekti — sadece bu kısım animate oluyor, resmi etkilemiyor
            AnimatedBuilder(
              animation: _glowController,
              builder: (context, _) => Container(
                width: avatarSize + 8,
                height: avatarSize + 8,
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
            ),
            // Lottie rank çerçevesi (profil resminin arkasında)
            RepaintBoundary(
              child: SizedBox(
                width: frameSize,
                height: frameSize,
                child: Lottie.asset(
                  rank.lottieAsset,
                  controller: _lottieController,
                  fit: BoxFit.contain,
                  alignment: Alignment.center,
                  frameRate: const FrameRate(60),
                  onLoaded: (composition) {
                    // Lottie'nin orijinal süresini composition'dan alır
                    _lottieController.duration = composition.duration;
                    // Baştan sona oynar, sondan başa sarar ve sürekli döngüde kalır
                    _lottieController.repeat(reverse: true);
                  },
                ),
              ),
            ),
            // Profil fotoğrafı — AnimatedBuilder dışında, stabil (titremez)
            _buildProfileAvatar(avatarSize, rank, context),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileAvatar(double size, RankTier rank, BuildContext context) {
    final hasImage =
        widget.profileImagePath != null && widget.profileImagePath!.isNotEmpty;
    final provider = hasImage
        ? ImageUtils.getProfileImageProvider(widget.profileImagePath)
        : null;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        shape: BoxShape.circle,
        border: Border.all(
          // Lottie'nin rengine uyumlu bir border
          color: rank.glowColor.withValues(alpha: 0.8),
          width: 2.5,
        ),
      ),
      child: ClipOval(
        child: provider != null
            ? CircleAvatar(
                radius: size / 2,
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest,
                backgroundImage: provider,
              )
            : _buildAvatarFallback(size, rank, context),
      ),
    );
  }

  Widget _buildAvatarFallback(
    double size,
    RankTier rank,
    BuildContext context,
  ) {
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.person,
        size: size * 0.55,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
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
