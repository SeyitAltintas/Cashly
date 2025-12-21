import 'package:flutter/material.dart';

/// Kategori yönetimi bölümü widget'ı
class CategorySection extends StatelessWidget {
  final VoidCallback onTap;

  const CategorySection({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "KATEGORİ YÖNETİMİ",
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white10),
          ),
          child: Row(
            children: [
              Icon(Icons.format_list_bulleted, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Harcama kategorilerini özelleştirin",
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.7),
                    fontSize: 14,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.arrow_forward_ios,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.54),
                  size: 18,
                ),
                onPressed: onTap,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
