import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';
import 'package:cashly/core/extensions/l10n_extensions.dart';

/// Güvenlik ayarları section widget'ı
/// Biyometrik giriş toggle ve tarih bilgileri
class SecuritySection extends StatelessWidget {
  final bool isBiometricAvailable;
  final bool biometricEnabled;
  final String createdAt;
  final String lastLoginAt;
  final Function(bool) onBiometricToggle;

  const SecuritySection({
    super.key,
    required this.isBiometricAvailable,
    required this.biometricEnabled,
    required this.createdAt,
    required this.lastLoginAt,
    required this.onBiometricToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),

        // Biyometrik Giriş
        if (isBiometricAvailable)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  // Dinamik biyometrik ikon rengi (turkuaz)
                  color: PageThemeColors.getIconColor(
                    5,
                  ).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.fingerprint,
                  color: PageThemeColors.getIconColor(5),
                  size: 24,
                ),
              ),
              title: Text(
                context.l10n.biometricLogin,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                context.l10n.biometricDesc,
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
                  fontSize: 12,
                ),
              ),
              trailing: Switch(
                value: biometricEnabled,
                onChanged: onBiometricToggle,
                activeTrackColor: Colors.green.withValues(alpha: 0.5),
                activeThumbColor: Colors.green,
                inactiveTrackColor: Colors.red.withValues(alpha: 0.3),
                inactiveThumbColor: Colors.red,
                // Koyu gri-beyaz çerçeve
                trackOutlineColor: WidgetStateProperty.all(
                  Colors.white.withValues(alpha: 0.25),
                ),
              ),
            ),
          ),

        // Hesap Oluşturulma Tarihi
        _buildInfoCard(
          context,
          title: context.l10n.accountCreatedDate,
          subtitle: createdAt,
          icon: Icons.calendar_today_outlined,
          colorIndex: 3,
        ),
        const SizedBox(height: 16),

        // Son Giriş Tarihi
        _buildInfoCard(
          context,
          title: context.l10n.lastLoginDate,
          subtitle: lastLoginAt,
          icon: Icons.login_outlined,
          colorIndex: 4,
        ),
      ],
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
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
      ),
    );
  }
}
