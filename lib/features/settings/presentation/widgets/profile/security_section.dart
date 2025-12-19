import 'package:flutter/material.dart';

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
                  color: Theme.of(
                    context,
                  ).colorScheme.secondary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.fingerprint,
                  color: Theme.of(context).colorScheme.secondary,
                  size: 24,
                ),
              ),
              title: Text(
                "Biyometrik Giriş",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                "Parmak izi veya yüz tanıma ile giriş",
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
              ),
            ),
          ),

        // Hesap Oluşturulma Tarihi
        _buildInfoCard(
          context,
          title: "Hesap Oluşturulma Tarihi",
          subtitle: createdAt,
          icon: Icons.calendar_today_outlined,
        ),
        const SizedBox(height: 16),

        // Son Giriş Tarihi
        _buildInfoCard(
          context,
          title: "Son Giriş Tarihi",
          subtitle: lastLoginAt,
          icon: Icons.login_outlined,
        ),
      ],
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Card(
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.secondary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Theme.of(context).colorScheme.secondary),
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
