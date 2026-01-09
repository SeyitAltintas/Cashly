import 'package:flutter/material.dart';
import 'package:cashly/core/widgets/balance_warning_dialog.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/utils/error_handler.dart';
import '../../../../core/utils/amount_input_formatter.dart';
import '../../../../core/widgets/app_date_picker.dart';
import '../../../payment_methods/data/models/payment_method_model.dart';

/// Harcama ekleme/düzenleme sayfası
/// Bottom sheet yerine tam sayfa olarak tasarlandı
class AddExpensePage extends StatefulWidget {
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

  const AddExpensePage({
    super.key,
    this.expenseToEdit,
    required this.onSave,
    required this.categories,
    this.paymentMethods = const [],
    this.defaultPaymentMethodId,
  });

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
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
      // Kategorinin mevcut kategoriler arasında olup olmadığını kontrol et
      final editCategory = widget.expenseToEdit!['kategori'] as String?;
      if (editCategory != null && _categoryIcons.containsKey(editCategory)) {
        _selectedCategory = editCategory;
      }
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

    final double? amount = AmountInputFormatter.parseFormattedAmount(
      _amountController.text,
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
    final isEditing = widget.expenseToEdit != null;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEditing ? "Harcamayı Düzenle" : "Harcama Ekle",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // Kaydet butonu AppBar'da
          TextButton(
            onPressed: _save,
            child: Text(
              "Kaydet",
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Harcama adı
              TextFormField(
                controller: _nameController,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                autofocus: !isEditing,
                validator: (value) =>
                    Validators.validateItemName(value, itemType: 'Harcama'),
                decoration: InputDecoration(
                  labelText: "Harcama Adı",
                  labelStyle: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  hintText: "Ne aldın? (Örn: Kahve)",
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
              const SizedBox(height: 16),

              // Tutar
              TextFormField(
                controller: _amountController,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [AmountInputFormatter()],
                validator: (value) => AmountInputFormatter.validateAmount(
                  value,
                  maxAmount: 1000000,
                ),
                decoration: InputDecoration(
                  labelText: "Tutar",
                  labelStyle: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  hintText: "Tutar (Örn: 1.250)",
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
              const SizedBox(height: 16),

              // Tarih seçici
              Text(
                "Tarih",
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.7),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
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
                      const SizedBox(width: 12),
                      Text(
                        "${_selectedDate.day} ${_months[_selectedDate.month - 1]} ${_selectedDate.year}",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 16,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.5),
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Kategori seçici
              Text(
                "Kategori",
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.7),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
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
                const SizedBox(height: 16),
                Text(
                  "Ödeme Yöntemi",
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
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

              const SizedBox(height: 32),

              // Alt kaydet butonu
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  onPressed: _save,
                  child: Text(
                    isEditing ? "Güncelle" : "Harcama Ekle",
                    style: const TextStyle(
                      fontSize: 18,
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
