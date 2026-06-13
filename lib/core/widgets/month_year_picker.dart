import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../services/haptic_service.dart';
import '../state/month_year_picker_state.dart';
import '../extensions/l10n_extensions.dart';
import 'package:intl/intl.dart';
import 'dart:ui';

/// Picker Modları
enum PickerMode {
  monthYear, // Sadece Ay ve Yıl
  date, // Gün, Ay, Yıl
  time, // Saat, Dakika
  dateTime, // Gün, Ay, Yıl, Saat, Dakika
}

/// Ortak tarih/saat seçici bottom sheet widget'ı
/// iOS tarzı (Cupertino) tasarım ve Glassmorphism efekti
class MonthYearPicker extends StatefulWidget {
  final DateTime initialDate;
  final DateTime? minimumDate;
  final DateTime? maximumDate;
  final Color? accentColor;
  final Function(DateTime) onDateSelected;
  final bool useNeutralSelectedStyle;
  final PickerMode mode;

  const MonthYearPicker({
    super.key,
    required this.initialDate,
    required this.onDateSelected,
    this.minimumDate,
    this.maximumDate,
    this.accentColor,
    this.useNeutralSelectedStyle = false,
    this.mode = PickerMode.monthYear,
  });

  static Future<DateTime?> show(
    BuildContext context, {
    required DateTime initialDate,
    DateTime? minimumDate,
    DateTime? maximumDate,
    Color? accentColor,
    bool useNeutralSelectedStyle = false,
    PickerMode mode = PickerMode.monthYear,
  }) {
    // Sınır koruması: minimum > maximum ise düzelt
    if (minimumDate != null &&
        maximumDate != null &&
        minimumDate.isAfter(maximumDate)) {
      final temp = minimumDate;
      minimumDate = maximumDate;
      maximumDate = temp;
    }

    return showDialog<DateTime>(
      context: context,
      useSafeArea: true,
      builder: (sheetContext) => MonthYearPicker(
        initialDate: initialDate,
        minimumDate: minimumDate,
        maximumDate: maximumDate,
        accentColor: accentColor,
        useNeutralSelectedStyle: useNeutralSelectedStyle,
        mode: mode,
        onDateSelected: (date) {
          if (sheetContext.mounted) {
            Navigator.of(sheetContext).pop(date);
          }
        },
      ),
    );
  }

  @override
  State<MonthYearPicker> createState() => _MonthYearPickerState();
}

class _MonthYearPickerState extends State<MonthYearPicker> {
  late DateTime _currentDate;
  late int _selectedYear;
  late int _selectedMonthIndex;
  late FixedExtentScrollController _monthController;
  late FixedExtentScrollController _yearController;
  late MonthYearPickerState _pickerState;
  late int _startYear;
  late int _endYear;

  @override
  void initState() {
    super.initState();
    _currentDate = widget.initialDate;

    // Safety: Ensure _currentDate is within bounds
    if (widget.minimumDate != null &&
        _currentDate.isBefore(widget.minimumDate!)) {
      _currentDate = widget.minimumDate!;
    }
    if (widget.maximumDate != null &&
        _currentDate.isAfter(widget.maximumDate!)) {
      _currentDate = widget.maximumDate!;
    }

    _selectedYear = _currentDate.year;
    _selectedMonthIndex = _currentDate.month - 1;

    _startYear =
        widget.minimumDate?.year ??
        (_selectedYear < 2000 ? _selectedYear : 2000);
    _endYear =
        widget.maximumDate?.year ??
        (_selectedYear > 2100 ? _selectedYear : 2100);
    if (_endYear < _startYear) _endYear = _startYear;

    int initialYearItem = _selectedYear - _startYear;
    if (initialYearItem < 0) initialYearItem = 0;
    if (initialYearItem > (_endYear - _startYear)) {
      initialYearItem = _endYear - _startYear;
    }

    _monthController = FixedExtentScrollController(
      initialItem: _selectedMonthIndex,
    );
    _yearController = FixedExtentScrollController(initialItem: initialYearItem);

    _pickerState = MonthYearPickerState();
    _pickerState.initialize(_currentDate);
    _pickerState.addListener(_onStateChanged);
  }

  void _onStateChanged() {
    if (mounted) {
      _currentDate = _pickerState.currentDate;
      _selectedYear = _pickerState.selectedYear;
      _selectedMonthIndex = _pickerState.selectedMonthIndex;
      setState(() {});
    }
  }

  @override
  void dispose() {
    _pickerState.removeListener(_onStateChanged);
    _pickerState.dispose();
    _monthController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accentColor =
        widget.accentColor ?? Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final useNeutral = widget.useNeutralSelectedStyle;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: CupertinoTheme(
        data: CupertinoThemeData(
          brightness: isDark ? Brightness.dark : Brightness.light,
          textTheme: CupertinoTextThemeData(
            pickerTextStyle: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontSize: 20,
            ),
            dateTimePickerTextStyle: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontSize: 20,
            ),
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              height: 400,
              decoration: BoxDecoration(
                // Gerçek Glassmorphism efekti
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [
                          const Color(0xFF1E1E2E).withValues(alpha: 0.85),
                          const Color(0xFF141420).withValues(alpha: 0.95),
                        ]
                      : [
                          Colors.white.withValues(alpha: 0.85),
                          Colors.grey.shade50.withValues(alpha: 0.95),
                        ],
                ),
                border: Border.all(
                  color: isDark
                      ? Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.1)
                      : Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.15),
                  width: 1.5,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header (Başlık ve İkon)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: useNeutral
                                ? Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withValues(alpha: 0.1)
                                : accentColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _getIconForMode(widget.mode),
                            color: useNeutral
                                ? Theme.of(context).colorScheme.onSurface
                                : accentColor,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Text(
                          _getTitleForMode(widget.mode),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const Spacer(),
                        // Tamam Butonu (Header'da da olsun, iOS tarzı)
                        TextButton(
                          onPressed: () {
                            // MonthYear modunda özel işlem, diğerlerinde _currentDate
                            if (widget.mode == PickerMode.monthYear) {
                              DateTime finalDate = DateTime(
                                _selectedYear,
                                _selectedMonthIndex + 1,
                              );
                              if (widget.minimumDate != null &&
                                  finalDate.isBefore(widget.minimumDate!)) {
                                finalDate = widget.minimumDate!;
                              }
                              if (widget.maximumDate != null &&
                                  finalDate.isAfter(widget.maximumDate!)) {
                                finalDate = widget.maximumDate!;
                              }
                              widget.onDateSelected(finalDate);
                            } else {
                              DateTime finalDate = _currentDate;
                              if (widget.minimumDate != null &&
                                  finalDate.isBefore(widget.minimumDate!)) {
                                finalDate = widget.minimumDate!;
                              }
                              if (widget.maximumDate != null &&
                                  finalDate.isAfter(widget.maximumDate!)) {
                                finalDate = widget.maximumDate!;
                              }
                              widget.onDateSelected(finalDate);
                            }
                          },
                          child: Text(
                            context.l10n.done,
                            style: TextStyle(
                              color: useNeutral
                                  ? Theme.of(context).colorScheme.onSurface
                                  : accentColor,
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Seçilen Tarih/Saat Gösterimi (sadece dateTime ve date modlarında, time hariç)
                  if (widget.mode != PickerMode.monthYear &&
                      widget.mode != PickerMode.time)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 24,
                      ),
                      decoration: BoxDecoration(
                        color: useNeutral
                            ? Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.05)
                            : accentColor.withValues(alpha: 0.08),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _getFormattedDateForMode(),
                            style: TextStyle(
                              color: useNeutral
                                  ? Theme.of(context).colorScheme.onSurface
                                  : accentColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (widget.mode == PickerMode.dateTime) ...[
                            Text(
                              '  •  ',
                              style: TextStyle(
                                color:
                                    (useNeutral
                                            ? Theme.of(
                                                context,
                                              ).colorScheme.onSurface
                                            : accentColor)
                                        .withValues(alpha: 0.5),
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              _getFormattedTimeForMode(),
                              style: TextStyle(
                                color:
                                    (useNeutral
                                            ? Theme.of(
                                                context,
                                              ).colorScheme.onSurface
                                            : accentColor)
                                        .withValues(alpha: 0.8),
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                  // Picker Alanı
                  Expanded(
                    child: widget.mode == PickerMode.monthYear
                        ? _buildMonthYearPicker(isDark)
                        : _buildCupertinoDatePicker(isDark),
                  ),
                ],
              ), // Column
            ), // Container
          ), // BackdropFilter
        ), // ClipRRect
        ), // Outer Container
      ), // CupertinoTheme
    ); // Dialog
  }

  IconData _getIconForMode(PickerMode mode) {
    switch (mode) {
      case PickerMode.time:
        return Icons.access_time_rounded;
      case PickerMode.monthYear:
        return Icons.calendar_month_rounded;
      case PickerMode.dateTime:
      case PickerMode.date:
        return Icons.calendar_today_rounded;
    }
  }

  String _getTitleForMode(PickerMode mode) {
    switch (mode) {
      case PickerMode.time:
        return context.l10n.selectTime;
      case PickerMode.monthYear:
        return context.l10n.selectMonthAndYear;
      case PickerMode.dateTime:
        return context.l10n.selectDateAndTime;
      case PickerMode.date:
        return context.l10n.selectDate;
    }
  }

  /// Seçilen tarihi formatlı döndür
  String _getFormattedDateForMode() {
    final locale = Localizations.localeOf(context).languageCode == 'tr'
        ? 'tr_TR'
        : 'en_US';
    return DateFormat('d MMMM yyyy', locale).format(_currentDate);
  }

  /// Seçilen saati formatlı döndür
  String _getFormattedTimeForMode() {
    final hour = _currentDate.hour.toString().padLeft(2, '0');
    final minute = _currentDate.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Özel Ay/Yıl Seçici (Custom Cupertino Pickers)
  Widget _buildMonthYearPicker(bool isDark) {
    return Row(
      children: [
        // Ay Seçici
        Expanded(
          flex: 3,
          child: CupertinoPicker(
            backgroundColor: Colors.transparent,
            selectionOverlay: CupertinoPickerDefaultSelectionOverlay(
              background: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.05),
            ),
            scrollController: _monthController,
            itemExtent: 40,
            looping: true,
            onSelectedItemChanged: (index) {
              HapticService.selectionClick();
              _pickerState.setMonth(index);
            },
            children: List.generate(12, (index) {
              final locale =
                  Localizations.localeOf(context).languageCode == 'tr'
                  ? 'tr_TR'
                  : 'en_US';
              final monthName = DateFormat(
                'MMMM',
                locale,
              ).format(DateTime(2023, index + 1));
              return Center(
                child: Text(
                  monthName,
                ),
              );
            }),
          ),
        ),
        // Yıl Seçici
        Expanded(
          flex: 2,
          child: CupertinoPicker(
            backgroundColor: Colors.transparent,
            selectionOverlay: CupertinoPickerDefaultSelectionOverlay(
              background: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.05),
            ),
            scrollController: _yearController,
            itemExtent: 40,
            onSelectedItemChanged: (index) {
              HapticService.selectionClick();
              _pickerState.setYear(_startYear + index);
            },
            children: List.generate(_endYear - _startYear + 1, (index) {
              return Center(
                child: Text(
                  "${_startYear + index}",
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  /// Standart Cupertino Date Picker
  Widget _buildCupertinoDatePicker(bool isDark) {
    CupertinoDatePickerMode cupertinoMode;
    switch (widget.mode) {
      case PickerMode.time:
        cupertinoMode = CupertinoDatePickerMode.time;
        break;
      case PickerMode.dateTime:
        cupertinoMode = CupertinoDatePickerMode.dateAndTime;
        break;
      case PickerMode.date:
      default:
        cupertinoMode = CupertinoDatePickerMode.date;
        break;
    }

    final appLocale = Localizations.localeOf(context);

    return Localizations.override(
      context: context,
      locale: appLocale,
      child: CupertinoDatePicker(
        backgroundColor: Colors.transparent,
        mode: cupertinoMode,
        initialDateTime: _currentDate,
          minimumDate: widget.minimumDate,
          maximumDate: widget.maximumDate,
          minimumYear:
              widget.minimumDate?.year ??
              (_currentDate.year < 1
                  ? _currentDate.year
                  : 1), // Yıl tekerleğini kısıtla
          maximumYear:
              widget.maximumDate?.year ??
              ((widget.minimumDate?.year ?? 0) > 2100
                  ? widget.minimumDate!.year
                  : 2100), // Max yıl çökmesini önle
          use24hFormat: true,
          onDateTimeChanged: (date) {
            HapticService.selectionClick();
            _pickerState.setDate(date);
          },
        ),
    );
  }
}
