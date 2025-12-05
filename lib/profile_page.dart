import 'dart:io';
import 'package:flutter/material.dart';
import 'settings_page.dart';
import 'features/settings/presentation/pages/profile_settings_page.dart';
import 'features/auth/presentation/controllers/auth_controller.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'core/constants/color_constants.dart';

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
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Profil Bilgileri - Modern Tasarım
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
                  Theme.of(
                    context,
                  ).colorScheme.primaryContainer.withValues(alpha: 0.6),
                  Theme.of(
                    context,
                  ).colorScheme.secondary.withValues(alpha: 0.4),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: const [0.0, 0.5, 1.0],
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.15),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.4),
                  blurRadius: 25,
                  offset: const Offset(0, 12),
                  spreadRadius: -5,
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
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
          const SizedBox(height: 32),
          // Kullanıcı Bilgileri Butonu
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.surface,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.1),
                  ),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ProfileSettingsPage(authController: authController),
                  ),
                );
              },
              child: const Text(
                "Kullanıcı Bilgileri",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Ayarlar Butonu
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.surface,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.1),
                  ),
                ),
              ),
              onPressed: () async {
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
              child: const Text(
                "Ayarlar",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Çıkış Yap Butonu
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.surface,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: ColorConstants.kirmiziVurgu.withValues(alpha: 0.5),
                  ),
                ),
              ),
              onPressed: () async {
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
              child: const Text(
                "Çıkış Yap",
                style: TextStyle(
                  color: ColorConstants.kirmiziVurgu,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
