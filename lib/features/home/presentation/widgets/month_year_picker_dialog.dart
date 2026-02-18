import 'package:flutter/material.dart';
import 'package:cashly/core/extensions/l10n_extensions.dart';

/// Ay ve yıl seçici dialog widget'ı.
/// Kullanıcının dönem seçmesini sağlar.
class MonthYearPickerDialog extends StatefulWidget {
  final DateTime secilenAy;
  final List<String> aylarListesi;
  final void Function(int yil, int ay) onSecildi;

  const MonthYearPickerDialog({
    super.key,
    required this.secilenAy,
    required this.aylarListesi,
    required this.onSecildi,
  });

  /// Dialog'u gösterir
  static void show(
    BuildContext context, {
    required DateTime secilenAy,
    required List<String> aylarListesi,
    required void Function(int yil, int ay) onSecildi,
  }) {
    showDialog(
      context: context,
      builder: (context) => MonthYearPickerDialog(
        secilenAy: secilenAy,
        aylarListesi: aylarListesi,
        onSecildi: onSecildi,
      ),
    );
  }

  @override
  State<MonthYearPickerDialog> createState() => _MonthYearPickerDialogState();
}

class _MonthYearPickerDialogState extends State<MonthYearPickerDialog> {
  late int geciciYil;
  late int geciciAyIndex;

  @override
  void initState() {
    super.initState();
    geciciYil = widget.secilenAy.year;
    geciciAyIndex = widget.secilenAy.month;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
        ),
      ),
      title: Center(
        child: Text(
          context.l10n.selectPeriod,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      content: SizedBox(
        height: 300,
        width: double.maxFinite,
        child: Row(
          children: [
            // Yıl seçici
            Expanded(
              child: Column(
                children: [
                  Text(
                    context.l10n.year,
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.54),
                      fontSize: 12,
                    ),
                  ),
                  const Divider(color: Colors.white24),
                  Expanded(
                    child: ListView.builder(
                      itemCount: 11,
                      itemBuilder: (context, index) {
                        int yil = 2020 + index;
                        bool seciliMi = (yil == geciciYil);
                        return ListTile(
                          title: Center(
                            child: Text(
                              "$yil",
                              style: TextStyle(
                                color: seciliMi
                                    ? Theme.of(context).colorScheme.secondary
                                    : Theme.of(context).colorScheme.onSurface
                                          .withValues(alpha: 0.7),
                                fontWeight: seciliMi
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                fontSize: seciliMi ? 18 : 16,
                              ),
                            ),
                          ),
                          onTap: () => setState(() => geciciYil = yil),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const VerticalDivider(color: Colors.white24),
            // Ay seçici
            Expanded(
              child: Column(
                children: [
                  Text(
                    context.l10n.month,
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.54),
                      fontSize: 12,
                    ),
                  ),
                  const Divider(color: Colors.white24),
                  Expanded(
                    child: ListView.builder(
                      itemCount: 12,
                      itemBuilder: (context, index) {
                        int ayNo = index + 1;
                        bool seciliMi = (ayNo == geciciAyIndex);
                        return ListTile(
                          title: Center(
                            child: Text(
                              widget.aylarListesi[index],
                              style: TextStyle(
                                color: seciliMi
                                    ? Theme.of(context).colorScheme.secondary
                                    : Theme.of(context).colorScheme.onSurface
                                          .withValues(alpha: 0.7),
                                fontWeight: seciliMi
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                fontSize: seciliMi ? 18 : 16,
                              ),
                            ),
                          ),
                          onTap: () => setState(() => geciciAyIndex = ayNo),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            context.l10n.cancel,
            style: TextStyle(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.54),
            ),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () {
            widget.onSecildi(geciciYil, geciciAyIndex);
            Navigator.pop(context);
          },
          child: Text(context.l10n.ok),
        ),
      ],
    );
  }
}
