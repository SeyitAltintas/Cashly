import 'package:flutter/material.dart';
import '../main_settings_page.dart';
import '../support/about_support_page.dart';
import 'profile_settings_page.dart';
import 'package:cashly/features/auth/presentation/controllers/auth_controller.dart';
import 'package:cashly/features/auth/presentation/pages/login_page.dart';
import 'package:cashly/core/constants/color_constants.dart';
import 'package:cashly/core/extensions/l10n_extensions.dart';
import 'package:cashly/core/services/haptic_service.dart';
import 'package:cashly/core/utils/image_utils.dart';

class ProfilSayfasi extends StatelessWidget {
  final AuthController authController;
  final VoidCallback? onRefresh;
  final VoidCallback? onNavigationReturn; // Alt sayfalardan dönüşte çağrılır

  const ProfilSayfasi({
    super.key,
    required this.authController,
    this.onRefresh,
    this.onNavigationReturn,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profil Bilgileri - Modern Tasarım
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                  Theme.of(
                    context,
                  ).colorScheme.secondary.withValues(alpha: 0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                // Profil Resmi (Sol)
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    backgroundImage:
                        authController.currentUser?.profileImage != null
                        ? ImageUtils.getProfileImageProvider(authController.currentUser!.profileImage)
                        : null,
                    child: authController.currentUser?.profileImage == null
                        ? Icon(
                            Icons.person,
                            size: 40,
                            color: Theme.of(context).colorScheme.onSurface,
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 20),
                // Kullanıcı Bilgileri (Sağ)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Kullanıcı Adı
                      Text(
                        authController.currentUser?.name ?? context.l10n.user,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // E-posta
                      if (authController.currentUser?.email != null)
                        Text(
                          authController.currentUser!.email,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 14,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Hesap başlığı
          Text(
            context.l10n.account,
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
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
                  color: Colors.black.withValues(alpha: 0.05),
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
                  iconColor: Colors.blue,
                  title: context.l10n.userInfo,
                  subtitle: context.l10n.userInfoSubtitle,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ProfileSettingsPage(authController: authController),
                      ),
                    ).then((_) => onNavigationReturn?.call());
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
                          authController: authController,
                          // Geri yüklemede streak dahil tüm verileri yenilemek için
                          onNavigationReturn: onRefresh,
                        ),
                      ),
                    );
                    if (result == true && onRefresh != null) {
                      onRefresh!();
                    }
                    onNavigationReturn?.call();
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
              color: Theme.of(context).colorScheme.secondary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
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
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: _buildProfileTile(
              context: context,
              icon: Icons.info_outline,
              iconColor: Colors.cyan,
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
              color: Theme.of(context).colorScheme.secondary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
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
                  color: Colors.black.withValues(alpha: 0.05),
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
                await authController.logout();
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (_) => LoginPage(authController: authController),
                    ),
                    (route) => false,
                  );
                }
              },
              isLast: true,
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
                        fontWeight: FontWeight.w600,
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
