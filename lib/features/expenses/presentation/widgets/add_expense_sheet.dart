import 'package:flutter/material.dart';
import 'package:cashly/core/widgets/balance_warning_dialog.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/utils/error_handler.dart';
import '../../../../core/widgets/app_date_picker.dart';
import '../../../payment_methods/data/models/payment_method_model.dart';

class AddExpenseSheet extends StatefulWidget {
  final Map<String, dynamic>? expenseToEdit;
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
  final String? defaultPaymentMethodId;

  const AddExpenseSheet({
    super.key,
    this.expenseToEdit,
    required this.onSave,
    required this.categories,
    this.paymentMethods = const [],
    this.defaultPaymentMethodId,
  });

  @override
  State<AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends State<AddExpenseSheet> {
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

    if (widget.expenseToEdit != null) {
      _nameController.text = widget.expenseToEdit!['isim'];
      _amountController.text = widget.expenseToEdit!['tutar'].toString();
      _selectedCategory =
          widget.expenseToEdit!['kategori'] ?? _categoryIcons.keys.first;
      _selectedDate =
          DateTime.tryParse(widget.expenseToEdit!['tarih'].toString()) ??
          DateTime.now();
      _selectedPaymentMethodId = widget.expenseToEdit!['odemeYontemiId'];
    } else if (widget.defaultPaymentMethodId != null &&
        widget.paymentMethods.any(
          (pm) => pm.id == widget.defaultPaymentMethodId,
        )) {
      // Varsayılan ödeme yöntemini kullan
      _selectedPaymentMethodId = widget.defaultPaymentMethodId;
    } else if (widget.paymentMethods.isNotEmpty) {
      // Varsayılan olarak ilk ödeme yöntemini seç
      _selectedPaymentMethodId = widget.paymentMethods.first.id;
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

  Future<void> _save() async {
    // Form validation
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final double? amount = double.tryParse(
      _amountController.text.replaceAll(',', '.'),
    );

    if (amount == null) {
      ErrorHandler.showErrorSnackBar(context, 'Geçerli bir tutar girin');
      return;
    }

    // Bakiye/limit kontrolü
    if (_selectedPaymentMethodId != null) {
      final pm = widget.paymentMethods.firstWhere(
        (p) => p.id == _selectedPaymentMethodId,
        orElse: () => PaymentMethod(
          id: '',
          name: '',
          type: '',
          balance: double.infinity,
          colorIndex: 0,
          createdAt: DateTime.now(),
          isDeleted: false,
        ),
      );

      if (pm.id.isNotEmpty) {
        bool yetersizBakiye = false;

        if (pm.type == 'kredi') {
          // Kredi kartı: limit kontrolü
          final kalanLimit = (pm.limit ?? 0) - pm.balance;
          if (amount > kalanLimit) {
            yetersizBakiye = true;
          }
        } else {
          // Banka kartı/Nakit: bakiye kontrolü
          if (amount > pm.balance) {
            yetersizBakiye = true;
          }
        }

        if (yetersizBakiye) {
          // Kalan bakiye hesapla
          final currentBalance = pm.type == 'kredi'
              ? (pm.limit ?? 0) - pm.balance
              : pm.balance;

          final onay = await BalanceWarningDialog.show(
            context: context,
            paymentType: pm.type,
            currentBalance: currentBalance,
            expenseAmount: amount,
          );

          if (onay != true) return;
        }
      }
    }

    widget.onSave(
      _nameController.text.trim(),
      amount,
      _selectedCategory,
      _selectedDate,
      _selectedPaymentMethodId,
    );
    if (mounted) Navigator.pop(context);
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
              Text(
                widget.expenseToEdit != null
                    ? "Harcamayı Düzenle"
                    : "Harcama Ekle",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                autofocus: true,
                validator: (value) =>
                    Validators.validateItemName(value, itemType: 'Harcama'),
                decoration: InputDecoration(
                  hintText: "Ne aldın? (Örn: Çiğköfte)",
                  hintStyle: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.54),
                  ),
                  prefixIcon: Icon(
                    Icons.edit,
                    color: Theme.of(context).colorScheme.secondary,
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
              TextFormField(
                controller: _amountController,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) =>
                    Validators.validateAmount(value, maxAmount: 1000000),
                decoration: InputDecoration(
                  hintText: "Tutar (Örn: 260)",
                  hintStyle: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.54),
                  ),
                  prefixIcon: Icon(
                    Icons.currency_lira,
                    color: Theme.of(context).colorScheme.secondary,
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
                      Icon(
                        Icons.calendar_month,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
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
                              color: Theme.of(context).colorScheme.secondary,
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
              // Ödeme Yöntemi Seçimi
              if (widget.paymentMethods.isNotEmpty) ...[
                const SizedBox(height: 12),
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
                    child: DropdownButton<String?>(
                      value: _selectedPaymentMethodId,
                      dropdownColor: Theme.of(context).colorScheme.surface,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      isExpanded: true,
                      icon: const Icon(
                        Icons.arrow_drop_down,
                        color: Colors.white70,
                      ),
                      hint: Row(
                        children: [
                          Icon(
                            Icons.credit_card,
                            color: Theme.of(context).colorScheme.secondary,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Ödeme Yöntemi Seçin',
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.54),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      items: widget.paymentMethods.map((pm) {
                        return DropdownMenuItem<String?>(
                          value: pm.id,
                          child: Row(
                            children: [
                              Icon(
                                pm.type == 'nakit'
                                    ? Icons.wallet
                                    : pm.type == 'kredi'
                                    ? Icons.credit_card
                                    : Icons.account_balance,
                                color: Theme.of(context).colorScheme.secondary,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  pm.name,
                                  style: const TextStyle(fontSize: 16),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (pm.lastFourDigits != null)
                                Text(
                                  '****${pm.lastFourDigits}',
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.5),
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          _selectedPaymentMethodId = newValue;
                        });
                      },
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  onPressed: _save,
                  child: Text(
                    "Kaydet",
                    style: const TextStyle(
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
