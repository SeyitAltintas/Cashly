import 'package:flutter/material.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/utils/error_handler.dart';
import '../../../../core/widgets/month_year_picker.dart';
import '../../data/models/payment_method_model.dart';
import 'package:intl/intl.dart';
import '../../../../core/services/haptic_service.dart';

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

  // Sabitlenen Ana Renk
  final Color _primaryColor = const Color(0xFF00ACC1);

  String? _fromAccountId;
  String? _toAccountId;
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _save() {
    // Haptic Feedback (Sadece titreşim, animasyon yok)
    HapticService.mediumImpact();

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

    // Hedef hesap kredi kartıysa, borç kontrolü
    final toAccount = widget.paymentMethods.firstWhere(
      (pm) => pm.id == _toAccountId,
    );

    if (toAccount.type == 'kredi') {
      final borcMiktari = toAccount.balance;
      if (amount > borcMiktari) {
        ErrorHandler.showErrorSnackBar(
          context,
          'Kredi kartı borcu ${CurrencyFormatter.format(borcMiktari)}, en fazla bu kadar gönderebilirsiniz',
        );
        return;
      }
    }

    widget.onTransfer(_fromAccountId!, _toAccountId!, amount, _selectedDate);
    Navigator.pop(context);
  }

  Future<void> _pickDate() async {
    HapticService.lightImpact();

    // MonthYearPicker kullanımı
    final DateTime? picked = await MonthYearPicker.show(
      context,
      initialDate: _selectedDate,
      accentColor: _primaryColor,
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tema renkleri
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      // Arka plan rengi değiştirilmedi (Theme default)
      appBar: AppBar(
        title: Text(
          "Para Transferi",
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 20),

              // 1. Tutar Alanı (En Üstte, Odak Noktası)
              _buildAmountField(textColor),

              const SizedBox(height: 40),

              // 2. Hesap Seçimi (Dikey Akış)
              _buildAccountSelection(textColor, isDark),

              const SizedBox(height: 40),

              // 3. Tarih Seçimi
              _buildDateSelector(textColor, isDark),

              const SizedBox(height: 50),

              // 4. Aksiyon Butonu
              _buildActionButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAmountField(Color textColor) {
    return Column(
      children: [
        Text(
          "Gönderilecek Tutar",
          style: TextStyle(
            color: textColor.withValues(alpha: 0.5),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),
        IntrinsicWidth(
          child: TextFormField(
            controller: _amountController,
            style: TextStyle(
              color: _primaryColor,
              fontSize: 40,
              fontWeight: FontWeight.bold,
              letterSpacing: -1,
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textAlign: TextAlign.center,
            validator: (value) => Validators.validateAmount(value),
            decoration: InputDecoration(
              hintText: "0.00",
              hintStyle: TextStyle(
                color: textColor.withValues(alpha: 0.2),
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
              prefixIcon: Icon(
                Icons.currency_lira,
                size: 36,
                color: _primaryColor,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAccountSelection(Color textColor, bool isDark) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Bağlantı Çizgisi
        Positioned(
          left: 24,
          top: 40,
          bottom: 40,
          child: Container(width: 2, color: textColor.withValues(alpha: 0.1)),
        ),
        Column(
          children: [
            // Gönderen
            _buildAccountTile(
              label: "GÖNDEREN",
              value: _fromAccountId,
              hint: "Hesap Seçin",
              icon: Icons.upload_rounded,
              onChanged: (val) {
                setState(() => _fromAccountId = val);
                HapticService.selectionClick();
              },
              textColor: textColor,
              isDark: isDark,
            ),
            const SizedBox(height: 24),
            // Alan
            _buildAccountTile(
              label: "ALAN",
              value: _toAccountId,
              hint: "Hesap Seçin",
              icon: Icons.download_rounded,
              onChanged: (val) {
                setState(() => _toAccountId = val);
                HapticService.selectionClick();
              },
              textColor: textColor,
              isDark: isDark,
            ),
          ],
        ),
        // Ortadaki Transfer İkonu
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            shape: BoxShape.circle,
            border: Border.all(color: textColor.withValues(alpha: 0.1)),
          ),
          child: Icon(
            Icons.arrow_downward_rounded,
            size: 16,
            color: textColor.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }

  Widget _buildAccountTile({
    required String label,
    required String? value,
    required String hint,
    required IconData icon,
    required Function(String?) onChanged,
    required Color textColor,
    required bool isDark,
  }) {
    // Seçili hesabı bul (varsa)
    final selectedAccount = value != null
        ? widget.paymentMethods.firstWhere((pm) => pm.id == value)
        : null;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: _primaryColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: _primaryColor, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                  color: textColor.withValues(alpha: 0.4),
                ),
              ),
              const SizedBox(height: 4),
              DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: value,
                  hint: Text(
                    hint,
                    style: TextStyle(
                      fontSize: 16,
                      color: textColor.withValues(alpha: 0.3),
                    ),
                  ),
                  isExpanded: true,
                  icon: const Icon(Icons.expand_more_rounded, size: 20),
                  dropdownColor: Theme.of(context).cardColor,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                    fontFamily: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.fontFamily,
                  ),
                  items: widget.paymentMethods.map((pm) {
                    return DropdownMenuItem<String>(
                      value: pm.id,
                      child: Row(
                        children: [
                          Text(pm.name),
                          const Spacer(),
                          Text(
                            CurrencyFormatter.format(pm.balance),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.normal,
                              color: textColor.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: onChanged,
                ),
              ),
              // Eğer bu ALAN hesap ise ve Kredi Kartı ise "Tümünü Öde" göster
              if (label == "ALAN" &&
                  selectedAccount != null &&
                  selectedAccount.type == 'kredi' &&
                  selectedAccount.balance > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _amountController.text = selectedAccount.balance
                            .toStringAsFixed(0);
                      });
                      HapticService.lightImpact();
                    },
                    borderRadius: BorderRadius.circular(4),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 8,
                      ),
                      child: Text(
                        "Tüm borcu öde (${CurrencyFormatter.format(selectedAccount.balance)})",
                        style: TextStyle(
                          color: _primaryColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDateSelector(Color textColor, bool isDark) {
    return Center(
      child: InkWell(
        onTap: _pickDate,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: textColor.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: textColor.withValues(alpha: 0.05)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.calendar_today_rounded,
                size: 16,
                color: textColor.withValues(alpha: 0.6),
              ),
              const SizedBox(width: 8),
              // Sadece Ay ve Yıl gösterimi
              Text(
                DateFormat('MMMM yyyy', 'tr_TR').format(_selectedDate),
                style: TextStyle(
                  color: textColor.withValues(alpha: 0.8),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        onPressed: _save,
        child: const Text(
          "Transfer Yap",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
