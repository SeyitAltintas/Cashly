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
          // Profil Bilgileri
          Row(
            children: [
              CircleAvatar(
                radius: 30,
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
                                    authController.currentUser!.profileImage!
                                        .startsWith('assets/'))
                              ? AssetImage(
                                  authController.currentUser!.profileImage!,
                                )
                              : FileImage(
                                  File(
                                    authController.currentUser!.profileImage!,
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
              const SizedBox(width: 16),
              Text(
                authController.currentUser?.name ?? "Kullanıcı",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
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
