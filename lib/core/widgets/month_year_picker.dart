import 'package:flutter/material.dart';

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

/// Ortak ay/yıl seçici bottom sheet widget'ı
/// Modern glassmorphism tasarımı ile
class MonthYearPicker extends StatefulWidget {
  /// Başlangıç tarihi
  final DateTime initialDate;

  /// Seçilen ay için vurgu rengi
  final Color? accentColor;

  /// Tarih seçildiğinde çağrılacak callback
  final Function(DateTime) onDateSelected;

  /// Seçili ay için nötr stil kullan (açık gri arka plan, siyah yazı)
  final bool useNeutralSelectedStyle;

  const MonthYearPicker({
    super.key,
    required this.initialDate,
    required this.onDateSelected,
    this.accentColor,
    this.useNeutralSelectedStyle = false,
  });

  /// Bottom sheet olarak göster ve seçilen tarihi döndür
  static Future<DateTime?> show(
    BuildContext context, {
    required DateTime initialDate,
    Color? accentColor,
    bool useNeutralSelectedStyle = false,
  }) async {
    DateTime? selectedDate;

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => MonthYearPicker(
        initialDate: initialDate,
        accentColor: accentColor,
        useNeutralSelectedStyle: useNeutralSelectedStyle,
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
  late int _secilenYil;
  late int _secilenAyIndex;

  @override
  void initState() {
    super.initState();
    _secilenYil = widget.initialDate.year;
    _secilenAyIndex = widget.initialDate.month;
  }

  @override
  Widget build(BuildContext context) {
    final accentColor =
        widget.accentColor ?? Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final useNeutral = widget.useNeutralSelectedStyle;

    return Container(
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
          const SizedBox(height: 20),

          // Başlık
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
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
                    Icons.calendar_month_rounded,
                    color: useNeutral ? Colors.white : accentColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Text(
                  "Tarih Seç",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Yıl seçici - Modern tasarım
          _buildYearSelector(context, accentColor, isDark, useNeutral),
          const SizedBox(height: 24),

          // Ay grid'i
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildMonthGrid(context, accentColor, isDark),
          ),
          const SizedBox(height: 28),

          // Uygula butonu
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: _buildApplyButton(context, accentColor, useNeutral),
          ),
        ],
      ),
    );
  }

  Widget _buildYearSelector(
    BuildContext context,
    Color accentColor,
    bool isDark,
    bool useNeutral,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Önceki yıl butonu
          _buildYearButton(
            icon: Icons.keyboard_arrow_left_rounded,
            onTap: () => setState(() => _secilenYil--),
            isDark: isDark,
          ),

          // Yıl gösterimi
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _secilenYil.toString(),
              style: TextStyle(
                color: useNeutral ? Colors.white : accentColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),

          // Sonraki yıl butonu
          _buildYearButton(
            icon: Icons.keyboard_arrow_right_rounded,
            onTap: () => setState(() => _secilenYil++),
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildYearButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Icon(
            icon,
            color: isDark
                ? Colors.white.withValues(alpha: 0.7)
                : Colors.grey.shade600,
            size: 28,
          ),
        ),
      ),
    );
  }

  Widget _buildMonthGrid(BuildContext context, Color accentColor, bool isDark) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.6,
      ),
      itemCount: 12,
      itemBuilder: (context, index) {
        final ayNumarasi = index + 1;
        final seciliMi = ayNumarasi == _secilenAyIndex;

        // Nötr stil: koyu gri arka plan, beyaz yazı
        final useNeutral = widget.useNeutralSelectedStyle;
        final selectedBgColor = useNeutral
            ? Colors.blueGrey.shade700
            : accentColor;
        final selectedTextColor = useNeutral ? Colors.white : Colors.white;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => setState(() => _secilenAyIndex = ayNumarasi),
            borderRadius: BorderRadius.circular(12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                color: seciliMi
                    ? selectedBgColor
                    : isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: seciliMi
                    ? null
                    : Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : Colors.grey.shade200,
                      ),
              ),
              alignment: Alignment.center,
              child: Text(
                _aylarListesi[index].substring(0, 3),
                style: TextStyle(
                  color: seciliMi
                      ? selectedTextColor
                      : isDark
                      ? Colors.white.withValues(alpha: 0.8)
                      : Colors.grey.shade700,
                  fontWeight: seciliMi ? FontWeight.bold : FontWeight.w500,
                  fontSize: seciliMi ? 14 : 13,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildApplyButton(
    BuildContext context,
    Color accentColor,
    bool useNeutral,
  ) {
    final buttonColor = useNeutral ? Colors.blueGrey.shade700 : accentColor;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () {
          final selectedDate = DateTime(_secilenYil, _secilenAyIndex, 1);
          widget.onDateSelected(selectedDate);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_outline_rounded, size: 22),
            const SizedBox(width: 10),
            Text(
              "${_aylarListesi[_secilenAyIndex - 1]} $_secilenYil",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Ay isimlerini döndüren yardımcı fonksiyon
/// Diğer dosyalarda kullanılabilir
List<String> get aylarListesi => _aylarListesi;
