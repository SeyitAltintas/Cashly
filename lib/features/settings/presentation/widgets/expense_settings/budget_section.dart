import 'package:flutter/material.dart';

/// Bütçe limiti ayarları bölümü widget'ı
class BudgetSection extends StatelessWidget {
  final TextEditingController controller;
  final bool isSaved;
  final VoidCallback onSave;

  const BudgetSection({
    super.key,
    required this.controller,
    required this.isSaved,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "AYLIK GELİR (BÜTÇE LİMİTİ)",
          style: TextStyle(
            color: Theme.of(context).colorScheme.secondary,
            fontWeight: FontWeight.bold,
          ),
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
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: isSaved ? 13 : 20,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    suffixText: isSaved ? "" : "₺",
                  ),
                ),
              ),
              const SizedBox(width: 5),
              Container(
                height: 30,
                width: 1,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.2),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return ScaleTransition(scale: animation, child: child);
                },
                child: isSaved
                    ? const IconButton(
                        key: ValueKey('check'),
                        icon: Icon(Icons.check, color: Colors.green),
                        onPressed: null,
                        tooltip: "Kaydedildi",
                      )
                    : IconButton(
                        key: const ValueKey('save'),
                        icon: const Icon(Icons.save, color: Colors.white),
                        onPressed: onSave,
                        tooltip: "Kaydet",
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
