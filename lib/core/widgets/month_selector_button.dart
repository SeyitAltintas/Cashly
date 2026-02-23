import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'month_year_picker.dart';

/// Ortak ay seçici buton widget'ı
/// Üç sayfada (Harcamalar, Gelirler, İşlem Geçmişi) kullanılır
class MonthSelectorButton extends StatelessWidget {
  /// Seçilen ay (1-12)
  final int selectedMonth;

  /// Seçilen yıl
  final int selectedYear;

  /// Vurgu rengi (her sayfa için farklı olabilir)
  final Color? accentColor;

  /// Ay seçildiğinde çağrılacak callback
  final Function(DateTime) onMonthSelected;

  /// Seçili ay için nötr stil kullan (açık gri arka plan, siyah yazı)
  final bool useNeutralSelectedStyle;

  const MonthSelectorButton({
    super.key,
    required this.selectedMonth,
    required this.selectedYear,
    required this.onMonthSelected,
    this.accentColor,
    this.useNeutralSelectedStyle = false,
  });

  /// Ay ismini dile göre döndür
  String _monthName(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode == 'tr'
        ? 'tr_TR'
        : 'en_US';
    return DateFormat(
      'MMMM',
      locale,
    ).format(DateTime(selectedYear, selectedMonth));
  }

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? Theme.of(context).colorScheme.primary;

    return InkWell(
      onTap: () => _showMonthPicker(context),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.calendar_month, size: 16, color: Colors.white),
            const SizedBox(width: 6),
            Text(
              '${_monthName(context)} $selectedYear',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down, size: 18, color: Colors.white),
          ],
        ),
      ),
    );
  }

  /// Ay/yıl seçici bottom sheet'i göster
  Future<void> _showMonthPicker(BuildContext context) async {
    final selectedDate = await MonthYearPicker.show(
      context,
      initialDate: DateTime(selectedYear, selectedMonth),
      accentColor: accentColor,
      useNeutralSelectedStyle: useNeutralSelectedStyle,
    );

    if (selectedDate != null) {
      onMonthSelected(selectedDate);
    }
  }
}
