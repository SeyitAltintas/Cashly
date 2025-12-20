import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';

/// Profil bilgi kartları widget'ı
/// İsim, E-posta, PIN gibi ayar kartlarını gösterir
class ProfileInfoCards extends StatelessWidget {
  final String name;
  final String email;
  final String createdAt;
  final String lastLoginAt;
  final VoidCallback? onNameTap;
  final VoidCallback? onPinTap;

  const ProfileInfoCards({
    super.key,
    required this.name,
    required this.email,
    required this.createdAt,
    required this.lastLoginAt,
    this.onNameTap,
    this.onPinTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 24),

        // İsim Değiştirme Kartı
        _buildSettingsCard(
          context,
          title: "İsim Soyisim",
          subtitle: name,
          icon: Icons.person_outline,
          onTap: onNameTap,
          colorIndex: 7,
        ),
        const SizedBox(height: 16),

        // E-posta (Değiştirilemez)
        _buildSettingsCard(
          context,
          title: "E-posta",
          subtitle: email,
          icon: Icons.email_outlined,
          onTap: null,
          colorIndex: 5,
        ),
        const SizedBox(height: 16),

        // PIN Değiştirme
        _buildSettingsCard(
          context,
          title: "Güvenlik PIN'i",
          subtitle: "****",
          icon: Icons.lock_outline,
          onTap: onPinTap,
          colorIndex: 2,
        ),
      ],
    );
  }

  Widget _buildSettingsCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    VoidCallback? onTap,
    required int colorIndex,
  }) {
    // Dinamik ikon rengi
    final iconColor = PageThemeColors.getIconColor(colorIndex);

    return Card(
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        trailing: onTap != null
            ? Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.5),
              )
            : null,
        onTap: onTap,
      ),
    );
  }
}
