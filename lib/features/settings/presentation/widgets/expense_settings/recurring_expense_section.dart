import 'package:flutter/material.dart';

/// Tekrarlayan giderler bölümü widget'ı
class RecurringExpenseSection extends StatelessWidget {
  final VoidCallback onTap;

  const RecurringExpenseSection({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "TEKRARLAYAN GİDERLER",
          style: TextStyle(
            color: Theme.of(context).colorScheme.secondary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white10),
          ),
          child: ListTile(
            leading: const Icon(Icons.repeat, color: Colors.white),
            title: Text(
              'Tekrarlayan Giderleri Yönet',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            ),
            subtitle: Text(
              'Otomatik ödenen fatura ve abonelikler',
              style: TextStyle(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.5),
                fontSize: 12,
              ),
            ),
            trailing: Icon(
              Icons.chevron_right,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            onTap: onTap,
          ),
        ),
      ],
    );
  }
}
