import 'dart:io';
import 'package:flutter/material.dart';
import 'settings_page.dart';
import 'features/settings/presentation/pages/profile_settings_page.dart';
import 'features/auth/presentation/controllers/auth_controller.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'core/constants/color_constants.dart';
import 'services/haptic_service.dart';

class ProfilSayfasi extends StatelessWidget {
  final AuthController authController;
  final VoidCallback? onRefresh;

  const ProfilSayfasi({
    super.key,
    required this.authController,
    this.onRefresh,
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
                      width: 3,
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
                        ? (authController.currentUser!.profileImage!.startsWith(
                                    'http',
                                  )
                                  ? NetworkImage(
                                      authController.currentUser!.profileImage!,
                                    )
                                  : (authController.currentUser!.profileImage!
                                            .startsWith('lib/') ||
                                        authController
                                            .currentUser!
                                            .profileImage!
                                            .startsWith('assets/'))
                                  ? AssetImage(
                                      authController.currentUser!.profileImage!,
                                    )
                                  : FileImage(
                                      File(
                                        authController
                                            .currentUser!
                                            .profileImage!,
                                      ),
                                    ))
                              as ImageProvider
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
                        authController.currentUser?.name ?? "Kullanıcı",
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
            'Hesap',
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
                  title: 'Kullanıcı Bilgileri',
                  subtitle: 'Ad, e-posta ve profil resmi',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ProfileSettingsPage(authController: authController),
                      ),
                    );
                  },
                ),
                _buildDivider(context),

                // Ayarlar
                _buildProfileTile(
                  context: context,
                  icon: Icons.settings_outlined,
                  iconColor: Colors.grey,
                  title: 'Ayarlar',
                  subtitle: 'Görünüm, sesli asistan ve harcamalar',
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AyarlarSayfasi(authController: authController),
                      ),
                    );
                    if (result == true && onRefresh != null) {
                      onRefresh!();
                    }
                  },
                  isLast: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Oturum başlığı
          Text(
            'Oturum',
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
              title: 'Çıkış Yap',
              subtitle: 'Hesabından güvenli çıkış yap',
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
