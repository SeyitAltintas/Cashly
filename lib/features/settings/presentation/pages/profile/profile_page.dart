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
import '../../../../streak/presentation/widgets/rank_frame_widget.dart';
import '../../../../streak/presentation/pages/streak_page.dart';

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

  Future<void> _generateMockData() async {
    final userId = widget.authController.currentUser?.id;
    if (userId == null) return;

    setState(() => _mockLoading = true);
    try {
      await MockDataService().generateMockData(userId);
      await CloudSyncService.syncAllUserData(userId);
      if (mounted) {
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
          // Profil Bilgileri - Modern Tasarım
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Theme.of(context).colorScheme.surface.withValues(alpha: 0.8)
                  : Theme.of(
                      context,
                    ).colorScheme.surface.withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.06),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.black.withValues(alpha: 0.2)
                      : Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.05),
                  blurRadius: 32,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      children: [
                        // Profil Resmi + Rank Çerçevesi (Sol)
                        Column(
                          children: [
                            RankFrameWidget(
                              rankData: widget.streakData ?? RankData.empty(),
                              profileImagePath: widget
                                  .authController
                                  .currentUser
                                  ?.profileImage,
                              size: 72,
                              onTap: () {
                                HapticService.lightImpact();
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder:
                                        (
                                          context,
                                          animation,
                                          secondaryAnimation,
                                        ) => StreakPage(
                                          streakData:
                                              widget.streakData ??
                                              RankData.empty(),
                                        ),
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
                          ],
                        ),
                        const SizedBox(width: 16),
                        // Kullanıcı Bilgileri (Sağ)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.authController.currentUser?.name ??
                                    context.l10n.user,
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              const SizedBox(height: 3),
                              if (widget.authController.currentUser?.email !=
                                  null)
                                Text(
                                  widget.authController.currentUser!.email,
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.7),
                                    fontSize: 13,
                                  ),
                                ),
                              const SizedBox(height: 8),
                              // Mini Rank Badge
                              RankNameBadge(
                                rankData: widget.streakData ?? RankData.empty(),
                              ),
                            ],
                          ),
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
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.08),
              ),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
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

          // Destek kartı
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.08),
              ),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
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
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.08),
              ),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
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
