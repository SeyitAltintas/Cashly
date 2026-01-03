import 'package:flutter/material.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/utils/error_handler.dart';
import '../../../../core/utils/amount_input_formatter.dart';
import '../../../../core/widgets/app_date_picker.dart';
import '../../../payment_methods/data/models/payment_method_model.dart';

class AddIncomeSheet extends StatefulWidget {
  final Map<String, dynamic>? incomeToEdit;
  final Function(
    String name,
    double amount,
    String category,
    DateTime date,
    String? paymentMethodId,
  )
  onSave;
  final Map<String, IconData> categories;
  final List<PaymentMethod> paymentMethods;

  const AddIncomeSheet({
    super.key,
    this.incomeToEdit,
    required this.onSave,
    required this.categories,
    this.paymentMethods = const [],
  });

  @override
  State<AddIncomeSheet> createState() => _AddIncomeSheetState();
}

class _AddIncomeSheetState extends State<AddIncomeSheet> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  late String _selectedCategory;
  DateTime _selectedDate = DateTime.now();
  late Map<String, IconData> _categoryIcons;
  String? _selectedPaymentMethodId;

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

    if (widget.incomeToEdit != null) {
      _nameController.text = widget.incomeToEdit!['name'] ?? '';
      _amountController.text = widget.incomeToEdit!['amount'].toString();
      // Kategorinin mevcut kategoriler arasında olup olmadığını kontrol et
      final editCategory = widget.incomeToEdit!['category'] as String?;
      if (editCategory != null && _categoryIcons.containsKey(editCategory)) {
        _selectedCategory = editCategory;
      }
      // Yoksa varsayılan kategori kullanılır (_categoryIcons.keys.first - satır 60)
      _selectedDate =
          DateTime.tryParse(widget.incomeToEdit!['date'].toString()) ??
          DateTime.now();
      _selectedPaymentMethodId = widget.incomeToEdit!['paymentMethodId'];
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await AppDatePicker.show(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final double? amount = AmountInputFormatter.parseFormattedAmount(
      _amountController.text,
    );

    if (amount == null) {
      ErrorHandler.showErrorSnackBar(context, 'Geçerli bir tutar girin');
      return;
    }

    widget.onSave(
      _nameController.text.trim(),
      amount,
      _selectedCategory,
      _selectedDate,
      _selectedPaymentMethodId,
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
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
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
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.trending_up,
                      color: Colors.green,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    widget.incomeToEdit != null
                        ? "Geliri Düzenle"
                        : "Gelir Ekle",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                autofocus: true,
                validator: (value) =>
                    Validators.validateItemName(value, itemType: 'Gelir'),
                decoration: InputDecoration(
                  hintText: "Gelir kaynağı (Örn: Maaş)",
                  hintStyle: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.54),
                  ),
                  prefixIcon: Icon(Icons.edit, color: Colors.green.shade400),
                  filled: true,
                  fillColor: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  errorStyle: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _amountController,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [AmountInputFormatter()],
                validator: (value) => AmountInputFormatter.validateAmount(
                  value,
                  maxAmount: 10000000,
                ),
                decoration: InputDecoration(
                  hintText: "Tutar (Örn: 25.000)",
                  hintStyle: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.54),
                  ),
                  prefixIcon: Icon(
                    Icons.currency_lira,
                    color: Colors.green.shade400,
                  ),
                  filled: true,
                  fillColor: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  errorStyle: TextStyle(
                    color: Theme.of(context).colorScheme.error,
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
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_month, color: Colors.green.shade400),
                      const SizedBox(width: 10),
                      Text(
                        "${_selectedDate.day} ${_months[_selectedDate.month - 1]} ${_selectedDate.year}",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 16,
                        ),
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
              if (widget.paymentMethods.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedPaymentMethodId,
                      hint: Row(
                        children: [
                          Icon(Icons.credit_card, color: Colors.green.shade400),
                          const SizedBox(width: 10),
                          Text(
                            "Hesap Seç (Opsiyonel)",
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.54),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      dropdownColor: Theme.of(context).colorScheme.surface,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      isExpanded: true,
                      icon: const Icon(
                        Icons.arrow_drop_down,
                        color: Colors.white70,
                      ),
                      items: [
                        DropdownMenuItem<String>(
                          value: null,
                          child: Row(
                            children: [
                              Icon(
                                Icons.money_off,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(width: 12),
                              const Text("Hesap Seçme"),
                            ],
                          ),
                        ),
                        ...widget.paymentMethods.map((pm) {
                          return DropdownMenuItem<String>(
                            value: pm.id,
                            child: Row(
                              children: [
                                Icon(
                                  pm.type == 'nakit'
                                      ? Icons.wallet
                                      : pm.type == 'kredi'
                                      ? Icons.credit_card
                                      : Icons.account_balance,
                                  color: Colors.green.shade400,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  pm.lastFourDigits != null
                                      ? '${pm.name} ****${pm.lastFourDigits} (${pm.balance} ₺)'
                                      : '${pm.name} (${pm.balance} ₺)',
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                      onChanged: (newValue) {
                        setState(() {
                          _selectedPaymentMethodId = newValue;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCategory,
                    dropdownColor: Theme.of(context).colorScheme.surface,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
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
                              color: Colors.green.shade400,
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
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  onPressed: _save,
                  child: const Text(
                    "Kaydet",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
