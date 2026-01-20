import 'package:flutter/material.dart';

/// Tekrarlayan giderler bölümü widget'ı
class RecurringExpenseSection extends StatelessWidget {
  final VoidCallback onTap;

  const RecurringExpenseSection({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(
            context,
          ).colorScheme.onSurface.withValues(alpha: 0.15),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Başlık
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.surface.withValues(alpha: 0.3),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFBA68C8).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.repeat,
                    color: Color(0xFFBA68C8),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  "Tekrarlayan Giderler",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
          // İçerik - Buton
          InkWell(
            onTap: onTap,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tekrarlayan Giderleri Yönet',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Otomatik ödenen fatura ve abonelikler',
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
                  Icon(
                    Icons.chevron_right,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
