import 'package:flutter/material.dart';
import '../../services/haptic_service.dart';

/// Boş durum widget'ı
/// Veri olmadığında gösterilir
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Color? iconColor;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = iconColor ?? Theme.of(context).colorScheme.primary;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // İkon
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 48, color: color.withValues(alpha: 0.6)),
            ),
            const SizedBox(height: 24),

            // Başlık
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),

            // Alt başlık
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ],

            // Aksiyon butonu
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  HapticService.lightImpact();
                  onAction!();
                },
                icon: const Icon(Icons.add),
                label: Text(actionLabel!),
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Harcama yok durumu
  factory EmptyStateWidget.noExpenses({VoidCallback? onAdd}) {
    return EmptyStateWidget(
      icon: Icons.receipt_long_outlined,
      title: 'Henüz harcama yok',
      subtitle: 'İlk harcamanızı ekleyerek başlayın',
      actionLabel: onAdd != null ? 'Harcama Ekle' : null,
      onAction: onAdd,
      iconColor: Colors.red,
    );
  }

  /// Gelir yok durumu
  factory EmptyStateWidget.noIncomes({VoidCallback? onAdd}) {
    return EmptyStateWidget(
      icon: Icons.trending_up,
      title: 'Henüz gelir yok',
      subtitle: 'İlk gelirinizi ekleyerek başlayın',
      actionLabel: onAdd != null ? 'Gelir Ekle' : null,
      onAction: onAdd,
      iconColor: Colors.green,
    );
  }

  /// Varlık yok durumu
  factory EmptyStateWidget.noAssets({VoidCallback? onAdd}) {
    return EmptyStateWidget(
      icon: Icons.account_balance_wallet_outlined,
      title: 'Henüz varlık yok',
      subtitle: 'Varlıklarınızı takip etmeye başlayın',
      actionLabel: onAdd != null ? 'Varlık Ekle' : null,
      onAction: onAdd,
      iconColor: Colors.blue,
    );
  }

  /// İşlem yok durumu
  factory EmptyStateWidget.noTransactions() {
    return const EmptyStateWidget(
      icon: Icons.swap_horiz,
      title: 'Henüz işlem yok',
      subtitle: 'Bu ay için işlem bulunmuyor',
      iconColor: Colors.orange,
    );
  }
}
