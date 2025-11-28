import 'package:flutter/material.dart';

class AddExpenseSheet extends StatefulWidget {
  final Map<String, dynamic>? expenseToEdit;
  final Function(String name, double amount, String category, DateTime date)
  onSave;
  final Map<String, IconData> categories;

  const AddExpenseSheet({
    super.key,
    this.expenseToEdit,
    required this.onSave,
    required this.categories,
  });

  @override
  State<AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends State<AddExpenseSheet> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  late String _selectedCategory;
  DateTime _selectedDate = DateTime.now();
  late Map<String, IconData> _categoryIcons;

  final List<String> _months = [
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

  @override
  void initState() {
    super.initState();
    _categoryIcons = widget.categories;
    _selectedCategory = _categoryIcons.keys.first;

    if (widget.expenseToEdit != null) {
      _nameController.text = widget.expenseToEdit!['isim'];
      _amountController.text = widget.expenseToEdit!['tutar'].toString();
      _selectedCategory =
          widget.expenseToEdit!['kategori'] ?? _categoryIcons.keys.first;
      _selectedDate =
          DateTime.tryParse(widget.expenseToEdit!['tarih'].toString()) ??
          DateTime.now();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF9D00FF),
              onPrimary: Colors.white,
              surface: Color(0xFF1E1E1E),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _save() {
    if (_nameController.text.isEmpty || _amountController.text.isEmpty) return;

    final double? amount = double.tryParse(
      _amountController.text.replaceAll(',', '.'),
    );
    if (amount == null) return;

    widget.onSave(
      _nameController.text,
      amount,
      _selectedCategory,
      _selectedDate,
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        top: 20,
        left: 20,
        right: 20,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              widget.expenseToEdit != null
                  ? "Harcamayı Düzenle"
                  : "Harcama Ekle",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white),
              autofocus: true,
              decoration: InputDecoration(
                hintText: "Ne aldın? (Örn: Çiğköfte)",
                hintStyle: const TextStyle(color: Colors.white54),
                prefixIcon: const Icon(Icons.edit, color: Color(0xFFBB86FC)),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _amountController,
              style: const TextStyle(color: Colors.white),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                hintText: "Tutar (Örn: 260)",
                hintStyle: const TextStyle(color: Colors.white54),
                prefixIcon: const Icon(
                  Icons.currency_lira,
                  color: Color(0xFFBB86FC),
                ),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_month, color: Color(0xFFBB86FC)),
                    const SizedBox(width: 10),
                    Text(
                      "${_selectedDate.day} ${_months[_selectedDate.month - 1]} ${_selectedDate.year}",
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    const Spacer(),
                    const Text(
                      "Değiştir",
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCategory,
                  dropdownColor: const Color(0xFF2C2C2C),
                  style: const TextStyle(color: Colors.white),
                  isExpanded: true,
                  icon: const Icon(
                    Icons.arrow_drop_down,
                    color: Colors.white70,
                  ),
                  items: _categoryIcons.keys.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Row(
                        children: [
                          Icon(
                            _categoryIcons[value],
                            color: const Color(0xFFBB86FC),
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(value, style: const TextStyle(fontSize: 16)),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedCategory = newValue!;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9D00FF),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                onPressed: _save,
                child: const Text(
                  "Kaydet",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
