import 'package:flutter/material.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/utils/error_handler.dart';
import '../../data/models/payment_method_model.dart';
import 'package:intl/intl.dart';

class TransferPage extends StatefulWidget {
  final List<PaymentMethod> paymentMethods;
  final Function(String fromId, String toId, double amount, DateTime date)
  onTransfer;

  const TransferPage({
    super.key,
    required this.paymentMethods,
    required this.onTransfer,
  });

  @override
  State<TransferPage> createState() => _TransferPageState();
}

class _TransferPageState extends State<TransferPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String? _fromAccountId;
  String? _toAccountId;
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_fromAccountId == null || _toAccountId == null) {
      ErrorHandler.showErrorSnackBar(context, 'Lütfen hesapları seçin');
      return;
    }

    if (_fromAccountId == _toAccountId) {
      ErrorHandler.showErrorSnackBar(context, 'Aynı hesaba transfer yapılamaz');
      return;
    }

    final double? amount = double.tryParse(
      _amountController.text.replaceAll(',', '.'),
    );

    if (amount == null || amount <= 0) {
      ErrorHandler.showErrorSnackBar(context, 'Geçerli bir tutar girin');
      return;
    }

    // Bakiye kontrolü (Opsiyonel ama iyi olur)
    // Gönderen hesap kredi kartı değilse bakiyesi yetmeli mi?
    // Kullanıcı eksiye düşebilir, şimdilik engel koymayalım, uyarı verebiliriz ama basit tutalım.

    widget.onTransfer(_fromAccountId!, _toAccountId!, amount, _selectedDate);
    Navigator.pop(context);
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
            colorScheme: ColorScheme.dark(
              primary: Theme.of(context).colorScheme.secondary,
              onPrimary: Theme.of(context).colorScheme.onSecondary,
              surface: Theme.of(context).colorScheme.surface,
              onSurface: Theme.of(context).colorScheme.onSurface,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Para Transferi"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bilgi Kartı
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.secondary.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.swap_horiz,
                      color: Theme.of(context).colorScheme.secondary,
                      size: 32,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        "Hesaplarınız arasında para transferi yapabilir veya kredi kartı borcunuzu ödeyebilirsiniz.",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Gönderen Hesap
              Text(
                "Gönderen Hesap (Kaynak)",
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.7),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              _buildAccountDropdown(
                value: _fromAccountId,
                hint: "Hesap Seçin",
                onChanged: (val) {
                  setState(() {
                    _fromAccountId = val;
                  });
                },
              ),

              const SizedBox(height: 20),

              // Alan Hesap
              Text(
                "Alan Hesap (Hedef)",
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.7),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              _buildAccountDropdown(
                value: _toAccountId,
                hint: "Hesap Seçin",
                onChanged: (val) {
                  setState(() {
                    _toAccountId = val;
                  });
                },
              ),

              const SizedBox(height: 24),

              // Tutar
              TextFormField(
                controller: _amountController,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                textAlign: TextAlign.center,
                validator: (value) => Validators.validateAmount(value),
                decoration: InputDecoration(
                  hintText: "0.00",
                  prefixIcon: const Icon(Icons.currency_lira),
                  filled: true,
                  fillColor: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Tarih Seçimi
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
                        DateFormat(
                          'd MMMM yyyy',
                          'tr_TR',
                        ).format(_selectedDate),
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

              const SizedBox(height: 40),

              // Kaydet Butonu
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  onPressed: _save,
                  child: const Text(
                    "Transfer Yap",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountDropdown({
    required String? value,
    required String hint,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(
            hint,
            style: TextStyle(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          isExpanded: true,
          dropdownColor: Theme.of(context).colorScheme.surface,
          icon: const Icon(Icons.arrow_drop_down),
          items: widget.paymentMethods.map((pm) {
            IconData icon;
            if (pm.type == 'nakit') {
              icon = Icons.wallet;
            } else if (pm.type == 'kredi') {
              icon = Icons.credit_card;
            } else {
              icon = Icons.account_balance;
            }

            return DropdownMenuItem<String>(
              value: pm.id,
              child: Row(
                children: [
                  Icon(
                    icon,
                    color: Theme.of(context).colorScheme.secondary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      pm.lastFourDigits != null
                          ? '${pm.name} ****${pm.lastFourDigits}'
                          : pm.name,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '${pm.balance.toStringAsFixed(2)} ₺',
                    style: TextStyle(
                      color: pm.type == 'kredi' ? Colors.red : Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
