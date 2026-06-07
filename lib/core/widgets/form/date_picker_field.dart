import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../constants/color_constants.dart';
import '../../extensions/l10n_extensions.dart';

/// Tarih seçici form alanı widget'ı
/// Tarih seçimi için tutarlı görünüm ve davranış sağlar.
class DatePickerField extends StatelessWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateChanged;
  final String? labelText;
  final Color? accentColor;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final String dateFormat;

  const DatePickerField({
    super.key,
    required this.selectedDate,
    required this.onDateChanged,
    this.labelText,
    this.accentColor,
    this.firstDate,
    this.lastDate,
    this.dateFormat = 'dd MMMM yyyy',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = accentColor ?? ColorConstants.kirmiziVurgu;
    final displayLabel = labelText ?? context.l10n.expenseDate;
    final locale = Localizations.localeOf(context).languageCode == 'tr'
        ? 'tr_TR'
        : 'en_US';

    return GestureDetector(
      onTap: () => _showDatePicker(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    displayLabel,
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    DateFormat(dateFormat, locale).format(selectedDate),
                    style: TextStyle(
                      fontSize: 16,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_drop_down,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDatePicker(BuildContext context) async {
    final color = accentColor ?? ColorConstants.kirmiziVurgu;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: firstDate ?? DateTime(2020),
      lastDate: lastDate ?? DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: color, onPrimary: Colors.white),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedDate) {
      onDateChanged(picked);
    }
  }

  /// Harcama için tarih seçici (kırmızı tema)
  static DatePickerField expense({
    Key? key,
    required DateTime selectedDate,
    required Function(DateTime) onDateChanged,
    String? labelText,
  }) {
    return DatePickerField(
      key: key,
      selectedDate: selectedDate,
      onDateChanged: onDateChanged,
      labelText: labelText,
      accentColor: ColorConstants.kirmiziVurgu,
    );
  }

  /// Gelir için tarih seçici (yeşil tema)
  static DatePickerField income({
    Key? key,
    required DateTime selectedDate,
    required Function(DateTime) onDateChanged,
    String? labelText,
  }) {
    return DatePickerField(
      key: key,
      selectedDate: selectedDate,
      onDateChanged: onDateChanged,
      labelText: labelText,
      accentColor: Colors.green,
    );
  }
}
