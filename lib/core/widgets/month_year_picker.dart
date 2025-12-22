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
/// expenses_page ve incomes_page'de ortak kullanılır
class MonthYearPicker extends StatefulWidget {
  /// Başlangıç tarihi
  final DateTime initialDate;

  /// Seçilen ay için vurgu rengi
  final Color? accentColor;

  /// Tarih seçildiğinde çağrılacak callback
  final Function(DateTime) onDateSelected;

  const MonthYearPicker({
    super.key,
    required this.initialDate,
    required this.onDateSelected,
    this.accentColor,
  });

  /// Bottom sheet olarak göster ve seçilen tarihi döndür
  static Future<DateTime?> show(
    BuildContext context, {
    required DateTime initialDate,
    Color? accentColor,
  }) async {
    DateTime? selectedDate;

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => MonthYearPicker(
        initialDate: initialDate,
        accentColor: accentColor,
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

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Başlık çubuğu (handle)
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // Başlık
          Text(
            "Tarih Seç",
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),

          // Yıl seçici
          _buildYearSelector(context),
          const SizedBox(height: 20),

          // Ay grid'i
          _buildMonthGrid(context, accentColor),
          const SizedBox(height: 24),

          // Uygula butonu
          _buildApplyButton(context),
        ],
      ),
    );
  }

  Widget _buildYearSelector(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(
            Icons.chevron_left,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          onPressed: () => setState(() => _secilenYil--),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _secilenYil.toString(),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        IconButton(
          icon: Icon(
            Icons.chevron_right,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          onPressed: () => setState(() => _secilenYil++),
        ),
      ],
    );
  }

  Widget _buildMonthGrid(BuildContext context, Color accentColor) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 2,
      ),
      itemCount: 12,
      itemBuilder: (context, index) {
        final ayNumarasi = index + 1;
        final seciliMi = ayNumarasi == _secilenAyIndex;

        return GestureDetector(
          onTap: () => setState(() => _secilenAyIndex = ayNumarasi),
          child: Container(
            decoration: BoxDecoration(
              color: seciliMi
                  ? accentColor
                  : Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(
              _aylarListesi[index].substring(0, 3),
              style: TextStyle(
                color: seciliMi
                    ? Colors.white
                    : Theme.of(context).colorScheme.onSurface,
                fontWeight: seciliMi ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildApplyButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          final selectedDate = DateTime(_secilenYil, _secilenAyIndex, 1);
          widget.onDateSelected(selectedDate);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          "Seçilen tarihe git",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

/// Ay isimlerini döndüren yardımcı fonksiyon
/// Diğer dosyalarda kullanılabilir
List<String> get aylarListesi => _aylarListesi;
