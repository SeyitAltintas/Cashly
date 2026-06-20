import 'package:flutter/material.dart';
import '../main_settings_page.dart';
import '../support/about_support_page.dart';
import 'profile_settings_page.dart';
import 'package:cashly/features/auth/presentation/controllers/auth_controller.dart';
import 'package:cashly/features/auth/presentation/pages/login_page.dart';
import 'package:cashly/core/constants/color_constants.dart';
import 'package:cashly/core/extensions/l10n_extensions.dart';
import 'package:cashly/core/services/haptic_service.dart';
import 'package:cashly/core/services/mock_data_service.dart';
import 'package:cashly/core/services/cloud_sync_service.dart';
import '../../../../streak/data/models/streak_model.dart';
import '../../../../streak/data/constants/streak_badges.dart';
import '../../../../streak/presentation/widgets/rank_frame_widget.dart';
import '../../../../streak/presentation/pages/streak_page.dart';
import '../../../../dashboard/presentation/widgets/dashboard_card_container.dart';
import '../../../../streak/presentation/controllers/streak_controller.dart';
import 'package:cashly/core/di/injection_container.dart';

class ProfilSayfasi extends StatefulWidget {
  final AuthController authController;
  final StreakData? streakData;
  final VoidCallback? onRefresh;
  final VoidCallback? onNavigationReturn;

  const ProfilSayfasi({
    super.key,
    required this.authController,
    this.streakData,
    this.onRefresh,
    this.onNavigationReturn,
  });

  @override
  State<ProfilSayfasi> createState() => _ProfilSayfasiState();
}

class _ProfilSayfasiState extends State<ProfilSayfasi>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  bool _mockLoading = false;
  RankData? _localRankData;

  @override
  void initState() {
    super.initState();
    // widget.streakData ile geliniyorsa controller'a da set et
    if (widget.streakData != null) {
      _localRankData = widget.streakData;
    }
  }

  @override
  void didUpdateWidget(ProfilSayfasi oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.streakData != widget.streakData &&
        widget.streakData != null) {
      setState(() => _localRankData = widget.streakData);
    }
  }

  Future<void> _generateMockData() async {
    final userId = widget.authController.currentUser?.id;
    if (userId == null) return;

    setState(() => _mockLoading = true);
    try {
      await MockDataService().generateMockData(userId);
      await CloudSyncService.syncAllUserData(userId);
      if (mounted) {
        // Streak controller'a userId ver ve veriyi yenile
        getIt<StreakController>().loadStreakData(userId);
        final freshData = getIt<StreakController>().streakData;
        setState(() => _localRankData = freshData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Sahte veriler oluşturuldu!'),
            backgroundColor: ColorConstants.yesil,
          ),
        );
        widget.onRefresh?.call();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: ColorConstants.kirmiziVurgu,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _mockLoading = false);
    }
  }

  Future<void> _clearMockData() async {
    final userId = widget.authController.currentUser?.id;
    if (userId == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Mock Verileri Temizle'),
        content: const Text(
          'Sahte veriler silinecek. Gerçek verileriniz korunur.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Sil',
              style: TextStyle(color: ColorConstants.kirmiziVurgu),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _mockLoading = true);
    try {
      await MockDataService().clearMockData(userId);
      await CloudSyncService.syncAllUserData(userId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Sahte veriler temizlendi!'),
            backgroundColor: ColorConstants.yesil,
          ),
        );
        getIt<StreakController>().refresh();
        widget.onRefresh?.call();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: ColorConstants.kirmiziVurgu,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _mockLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final rankData = _localRankData ?? widget.streakData ?? RankData.empty();
    final rankTier = RankTiers.fromXp(rankData.totalXp);
    
    final rankColor = Theme.of(context).brightness == Brightness.dark
        ? Color.lerp(rankTier.glowColor, Colors.white, 0.3) ?? rankTier.glowColor
        : rankTier.primaryColor;

    return SingleChildScrollView(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16.0,
        left: 16.0,
        right: 16.0,
        bottom: 16.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profil Bilgileri - Sade Tasarım
          DashboardCardContainer(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  // Sol Taraf: Animasyon ve Rank Yazısı
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RankFrameWidget(
                        rankData: rankData,
                        profileImagePath:
                            widget.authController.currentUser?.profileImage,
                        size: 72,
                        onTap: () {
                          HapticService.lightImpact();
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      StreakPage(streakData: rankData),
                              transitionsBuilder:
                                  (
                                    context,
                                    animation,
                                    secondaryAnimation,
                                    child,
                                  ) {
                                    return FadeTransition(
                                      opacity: animation,
                                      child: child,
                                    );
                                  },
                              transitionDuration: const Duration(
                                milliseconds: 300,
                              ),
                            ),
                          );
                        },
                      ),
                      Transform.translate(
                        offset: const Offset(0, -12),
                        child: Text(
                          rankTier.name,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: rankColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 40),
                  // Sağ Taraf: Kullanıcı Bilgileri
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.authController.currentUser?.name ??
                              context.l10n.user,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (widget.authController.currentUser?.email != null)
                          Text(
                            widget.authController.currentUser!.email,
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.7),
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        const SizedBox(height: 8),
                        // XP ve Seri Bilgisi
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.stars_rounded,
                                  size: 16,
                                  color: rankColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${rankData.totalXp} XP',
                                  style: TextStyle(
                                    color: rankColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.local_fire_department,
                                  size: 16,
                                  color: Color(0xFFFF6B35),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${rankData.currentStreak} Gün Seri',
                                  style: const TextStyle(
                                    color: Color(0xFFFF6B35),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Hesap başlığı
          Text(
            context.l10n.account,
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontSize: 13,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),

          // Hesap seçenekleri kartı
          DashboardCardContainer(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                // Kullanıcı Bilgileri
                _buildProfileTile(
                  context: context,
                  icon: Icons.person_outline,
                  iconColor: ColorConstants.maviVurgu,
                  title: context.l10n.userInfo,
                  subtitle: context.l10n.userInfoSubtitle,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfileSettingsPage(
                          authController: widget.authController,
                        ),
                      ),
                    ).then((_) => widget.onNavigationReturn?.call());
                  },
                ),
                _buildDivider(context),

                // Ayarlar
                _buildProfileTile(
                  context: context,
                  icon: Icons.settings_outlined,
                  iconColor: Colors.grey,
                  title: context.l10n.settings,
                  subtitle: context.l10n.settingsSubtitle,
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AyarlarSayfasi(
                          authController: widget.authController,
                          // Geri yüklemede streak dahil tüm verileri yenilemek için
                          onNavigationReturn: widget.onRefresh,
                        ),
                      ),
                    );
                    if (result == true && widget.onRefresh != null) {
                      widget.onRefresh!();
                    }
                    widget.onNavigationReturn?.call();
                  },
                  isLast: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Destek başlığı
          Text(
            context.l10n.support,
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontSize: 13,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),

          // Tercihler Kartı
          DashboardCardContainer(
            padding: EdgeInsets.zero,
            child: _buildProfileTile(
              context: context,
              icon: Icons.info_outline,
              iconColor: Theme.of(context).colorScheme.primary,
              title: context.l10n.aboutAndSupport,
              subtitle: context.l10n.aboutAndSupportSubtitle,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AboutSupportPage(),
                  ),
                );
              },
              isLast: true,
            ),
          ),
          const SizedBox(height: 24),

          // Oturum başlığı
          Text(
            context.l10n.session,
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontSize: 13,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),

          // Çıkış yap kartı
          DashboardCardContainer(
            padding: EdgeInsets.zero,
            child: _buildProfileTile(
              context: context,
              icon: Icons.logout,
              iconColor: ColorConstants.kirmiziVurgu,
              title: context.l10n.logout,
              subtitle: context.l10n.logoutSubtitle,
              titleColor: ColorConstants.kirmiziVurgu,
              onTap: () async {
                await widget.authController.logout();
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (_) =>
                          LoginPage(authController: widget.authController),
                    ),
                    (route) => false,
                  );
                }
              },
              isLast: true,
            ),
          ),
          const SizedBox(height: 24),

          // ===== GELİŞTİRİCİ ARAÇLARI =====
          Container(
            decoration: BoxDecoration(
              color: Colors.deepPurple.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.deepPurple.withValues(alpha: 0.25),
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.science_outlined,
                      color: Colors.deepPurple,
                      size: 18,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Geliştirici Araçları',
                      style: TextStyle(
                        color: ColorConstants.morVurgu,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Test verisi oluşturmak ve temizlemek için.',
                  style: TextStyle(
                    color: Colors.deepPurple.withValues(alpha: 0.6),
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 16),
                if (_mockLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _generateMockData,
                          icon: const Icon(Icons.data_object, size: 18),
                          label: const Text('Sahte Veri Üret'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: ColorConstants.morVurgu,
                            side: BorderSide(
                              color: ColorConstants.morVurgu.withValues(
                                alpha: 0.4,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        onPressed: _clearMockData,
                        icon: const Icon(Icons.delete_sweep_outlined, size: 18),
                        label: const Text('Temizle'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: ColorConstants.kirmiziVurgu,
                          side: BorderSide(
                            color: ColorConstants.kirmiziVurgu.withValues(
                              alpha: 0.4,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildProfileTile({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? titleColor,
    bool isLast = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticService.lightImpact();
          onTap();
        },
        borderRadius: isLast
            ? const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              )
            : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              // İkon container
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 14),
              // Başlık ve alt başlık
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color:
                            titleColor ??
                            Theme.of(context).colorScheme.onSurface,
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.5),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              // Ok ikonu
              Icon(
                Icons.chevron_right,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.3),
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 72),
      child: Divider(
        height: 1,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08),
      ),
    );
  }
}
