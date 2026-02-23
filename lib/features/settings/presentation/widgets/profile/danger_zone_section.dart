import 'package:flutter/material.dart';
import 'package:cashly/core/extensions/l10n_extensions.dart';

/// Tehlikeli bölge section widget'ı
/// Hesap silme butonu
class DangerZoneSection extends StatelessWidget {
  final VoidCallback onDeleteAccount;

  const DangerZoneSection({super.key, required this.onDeleteAccount});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 40),

        // Tehlikeli Bölge Başlık
        Text(
          context.l10n.dangerZone,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        const SizedBox(height: 16),

        // Hesabı Sil
        Card(
          color: Colors.red.withValues(alpha: 0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: Colors.red.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.delete_forever, color: Colors.red),
            ),
            title: Text(
              context.l10n.deleteAccount,
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              context.l10n.deleteAccountDesc,
              style: TextStyle(color: Colors.red.withValues(alpha: 0.7)),
            ),
            trailing: Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.red.withValues(alpha: 0.5),
            ),
            onTap: onDeleteAccount,
          ),
        ),
      ],
    );
  }
}
