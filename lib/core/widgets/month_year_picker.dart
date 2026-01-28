import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../services/haptic_service.dart';
import '../state/month_year_picker_state.dart';

/// Picker Modları
enum PickerMode {
  monthYear, // Sadece Ay ve Yıl
  date, // Gün, Ay, Yıl
  time, // Saat, Dakika
  dateTime, // Gün, Ay, Yıl, Saat, Dakika
}

/// Ay isimleri listesi (Türkçe)
const List<String> _aylarListesi = [
  "Ocak",
  "Şubat",
  "Mart",
  "Nisan",
  "Mayıs",
  "Haziran",
  "Temmuz",
  "Ağustos",
  "Eylül",
  "Ekim",
  "Kasım",
  "Aralık",
];

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

  /// Bottom sheet olarak göster ve seçilen tarihi döndür
  static Future<DateTime?> show(
    BuildContext context, {
    required DateTime initialDate,
    DateTime? minimumDate,
    DateTime? maximumDate,
    Color? accentColor,
    bool useNeutralSelectedStyle = false,
    PickerMode mode = PickerMode.monthYear,
  }) async {
    DateTime? selectedDate;

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => MonthYearPicker(
        initialDate: initialDate,
        minimumDate: minimumDate,
        maximumDate: maximumDate,
        accentColor: accentColor,
        useNeutralSelectedStyle: useNeutralSelectedStyle,
        mode: mode,
        onDateSelected: (date) {
          selectedDate = date;
          Navigator.pop(context);
        },
      ),
    );

    return selectedDate;
  }

  @override
  State<MonthYearPicker> createState() => _MonthYearPickerState();
}

class _MonthYearPickerState extends State<MonthYearPicker> {
  late DateTime _currentDate;
  late int _selectedYear;
  late int _selectedMonthIndex;
  late FixedExtentScrollController _monthController;
  late final MonthYearPickerState _pickerState;

  @override
  void initState() {
    super.initState();
    _currentDate = widget.initialDate;
    _selectedYear = widget.initialDate.year;
    // 0-based index. Ortadan başlatmak için büyük bir sayı ekle (12 * 1000)
    // Böylece hem yukarı hem aşağı sonsuz kaydırılabilir.
    _selectedMonthIndex = widget.initialDate.month - 1;
    _monthController = FixedExtentScrollController(
      initialItem: (12 * 1000) + _selectedMonthIndex,
    );

    _pickerState = MonthYearPickerState();
    _pickerState.initialize(widget.initialDate);
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accentColor =
        widget.accentColor ?? Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final useNeutral = widget.useNeutralSelectedStyle;

    return Container(
      height: 400 + MediaQuery.of(context).padding.bottom,
      decoration: BoxDecoration(
        // Glassmorphism efekti
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [const Color(0xFF1E1E2E), const Color(0xFF141420)]
              : [Colors.white, Colors.grey.shade50],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 48,
            height: 5,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.2)
                  : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(3),
            ),
          ),

          // Header (Başlık ve İkon)
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: useNeutral
                        ? Colors.white.withValues(alpha: 0.1)
                        : accentColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getIconForMode(widget.mode),
                    color: useNeutral ? Colors.white : accentColor,
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
                      widget.onDateSelected(
                        DateTime(_selectedYear, _selectedMonthIndex + 1),
                      );
                    } else {
                      widget.onDateSelected(_currentDate);
                    }
                  },
                  child: Text(
                    "Bitti",
                    style: TextStyle(
                      color: useNeutral ? Colors.white : accentColor,
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
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
              decoration: BoxDecoration(
                color: useNeutral
                    ? Colors.white.withValues(alpha: 0.05)
                    : accentColor.withValues(alpha: 0.08),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _getFormattedDateForMode(),
                    style: TextStyle(
                      color: useNeutral ? Colors.white : accentColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (widget.mode == PickerMode.dateTime) ...[
                    Text(
                      '  •  ',
                      style: TextStyle(
                        color: (useNeutral ? Colors.white : accentColor)
                            .withValues(alpha: 0.5),
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      _getFormattedTimeForMode(),
                      style: TextStyle(
                        color: (useNeutral ? Colors.white : accentColor)
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

          // Alt padding (iOS safe area)
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
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
        return "Saat Seç";
      case PickerMode.monthYear:
        return "Ay ve Yıl Seç";
      case PickerMode.dateTime:
        return "Tarih ve Saat Seç";
      case PickerMode.date:
        return "Tarih Seç";
    }
  }

  /// Seçilen tarihi formatlı döndür
  String _getFormattedDateForMode() {
    // Türkçe ay isimleri
    const aylar = [
      'Ocak',
      'Şubat',
      'Mart',
      'Nisan',
      'Mayıs',
      'Haziran',
      'Temmuz',
      'Ağustos',
      'Eylül',
      'Ekim',
      'Kasım',
      'Aralık',
    ];
    final day = _currentDate.day;
    final month = aylar[_currentDate.month - 1];
    final year = _currentDate.year;
    return '$day $month $year';
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
          child: CupertinoPicker.builder(
            scrollController: _monthController,
            itemExtent: 40,
            onSelectedItemChanged: (index) {
              HapticService.selectionClick();
              _pickerState.setMonth(index);
            },
            // childCount vermezsek sonsuz olur
            itemBuilder: (context, index) {
              return Center(
                child: Text(
                  _aylarListesi[index % 12],
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontSize: 20,
                  ),
                ),
              );
            },
          ),
        ),
        // Yıl Seçici
        Expanded(
          flex: 2,
          child: CupertinoPicker.builder(
            scrollController: FixedExtentScrollController(
              initialItem: _selectedYear - 2000,
            ), // 2000'den başlatarak offset
            itemExtent: 40,
            onSelectedItemChanged: (index) {
              HapticService.selectionClick();
              _pickerState.setYear(2000 + index);
            },
            childCount: 101, // 2000-2100 arası (dahil)
            itemBuilder: (context, index) {
              return Center(
                child: Text(
                  "${2000 + index}",
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontSize: 20,
                  ),
                ),
              );
            },
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

    return Localizations.override(
      context: context,
      locale: const Locale('tr', 'TR'),
      child: CupertinoTheme(
        data: CupertinoThemeData(
          brightness: isDark ? Brightness.dark : Brightness.light,
          textTheme: CupertinoTextThemeData(
            dateTimePickerTextStyle: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontSize: 20,
            ),
          ),
        ),
        child: CupertinoDatePicker(
          mode: cupertinoMode,
          initialDateTime: _currentDate,
          minimumDate: widget.minimumDate,
          maximumDate: widget.maximumDate,
          minimumYear: widget.minimumDate?.year ?? 1, // Yıl tekerleğini kısıtla
          maximumYear: 2100, // Max yıl 2100
          use24hFormat: true,
          onDateTimeChanged: (date) {
            HapticService.selectionClick();
            _pickerState.setDate(date);
          },
        ),
      ),
    );
  }
}

/// Ay isimlerini döndüren yardımcı fonksiyon
/// Diğer dosyalarda kullanılabilir
List<String> get aylarListesi => _aylarListesi;
