import 'package:flutter/material.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/utils/error_handler.dart';
import '../../../../core/utils/amount_input_formatter.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/form/form_widgets.dart';
import '../../../../core/constants/color_constants.dart';
import '../../../payment_methods/data/models/payment_method_model.dart';
import '../controllers/incomes_controller.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/services/currency_service.dart';

import 'package:cashly/core/extensions/l10n_extensions.dart';

/// Gelir ekleme/düzenleme sayfası
/// Modern ve sade tasarım - Gelir temasına uygun (yeşil)
class AddIncomePage extends StatefulWidget {
  final Map<String, dynamic>? incomeToEdit;
  final Function(
    String name,
    double amount,
    String category,
    DateTime date,
    String? paymentMethodId,
    String paraBirimi,
  )
  onSave;
  final Map<String, IconData> categories;
  final List<PaymentMethod> paymentMethods;
  final IncomesController? controller;
  final DateTime? initialDate;

  const AddIncomePage({
    super.key,
    this.incomeToEdit,
    required this.onSave,
    required this.categories,
    this.paymentMethods = const [],
    this.controller,
    this.initialDate,
  });

  @override
  State<AddIncomePage> createState() => _AddIncomePageState();
}

class _AddIncomePageState extends State<AddIncomePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  late Map<String, IconData> _categoryIcons;

  // Controller veya yerel state
  IncomesController? _controller;
  DateTime _localSelectedDate = DateTime.now();
  String _localSelectedCategory = '';
  String? _localSelectedPaymentMethodId;
  String _localSelectedCurrency = 'TRY';

  // Getter'lar
  String get _selectedCategory =>
      _controller?.formSelectedCategory ?? _localSelectedCategory;
  DateTime get _selectedDate =>
      _controller?.formSelectedDate ?? _localSelectedDate;
  String? get _selectedPaymentMethodId =>
      _controller?.formSelectedPaymentMethodId ?? _localSelectedPaymentMethodId;

  // Gelir teması rengi (yeşil)
  static const Color _accentColor = ColorConstants.yesil;

  @override
  void initState() {
    super.initState();
    _categoryIcons = widget.categories;
    _controller = widget.controller;
    _controller?.addListener(_onFormStateChanged);

    final defaultCategory = _categoryIcons.keys.first;

    if (widget.incomeToEdit != null) {
      _nameController.text = widget.incomeToEdit!['name'] ?? '';
      final rawAmount = (widget.incomeToEdit!['amount'] as num).toDouble();
      final pb = widget.incomeToEdit!['paraBirimi']?.toString() ?? 'TRY';
      final cur = getIt<CurrencyService>();
      final convertedAmount = cur.convert(rawAmount, pb, cur.currentCurrency);
      _amountController.text = convertedAmount.toStringAsFixed(2);
      _localSelectedCurrency =
          widget.incomeToEdit!['paraBirimi']?.toString() ??
          getIt<CurrencyService>().currentCurrency;
      final editCategory = widget.incomeToEdit!['category'] as String?;
      final categoryToUse =
          (editCategory != null && _categoryIcons.containsKey(editCategory))
          ? editCategory
          : defaultCategory;
      final editDate =
          DateTime.tryParse(widget.incomeToEdit!['date'].toString()) ??
          DateTime.now();
      final editPaymentMethodId = widget.incomeToEdit!['paymentMethodId'];

      if (_controller != null) {
        _controller!.initializeFormState(
          defaultCategory: categoryToUse,
          editDate: editDate,
          editCategory: categoryToUse,
          editPaymentMethodId: editPaymentMethodId,
        );
      } else {
        _localSelectedCategory = categoryToUse;
        _localSelectedDate = editDate;
        _localSelectedPaymentMethodId = editPaymentMethodId;
      }
    } else {
      _localSelectedCurrency = getIt<CurrencyService>().currentCurrency;
      final nakitHesap = widget.paymentMethods
          .where((pm) => pm.type == 'nakit')
          .firstOrNull;
      final defaultPmId = nakitHesap?.id;

      if (_controller != null) {
        _controller!.initializeFormState(
          defaultCategory: defaultCategory,
          defaultPaymentMethodId: defaultPmId,
          editDate: widget.initialDate,
        );
      } else {
        _localSelectedCategory = defaultCategory;
        _localSelectedPaymentMethodId = defaultPmId;
        if (widget.initialDate != null) {
          _localSelectedDate = widget.initialDate!;
        }
      }
    }
  }

  void _onFormStateChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller?.removeListener(_onFormStateChanged);
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final double? amount = AmountInputFormatter.parseFormattedAmount(
      _amountController.text,
    );

    if (amount == null) {
      ErrorHandler.showErrorSnackBar(context, context.l10n.validAmountRequired);
      return;
    }

    widget.onSave(
      _nameController.text.trim(),
      amount,
      _selectedCategory,
      _selectedDate,
      _selectedPaymentMethodId,
      _localSelectedCurrency,
    );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.incomeToEdit != null;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEditing ? context.l10n.editIncome : context.l10n.addIncome,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            // Tutar alanı - Büyük ve merkezi
            _buildAmountSection(),
            const SizedBox(height: 32),

            // Diğer alanlar
            _buildTextField(
              controller: _nameController,
              label: context.l10n.incomeNameLabel,
              hint: context.l10n.incomeNameHint,
              icon: Icons.attach_money,
              validator: (value) => Validators.validateItemName(
                value,
                itemType: context.l10n.income,
              ),
            ),
            const SizedBox(height: 16),

            _buildDateSelector(),
            const SizedBox(height: 16),

            _buildCategorySelector(),
            const SizedBox(height: 16),

            if (widget.paymentMethods.isNotEmpty) ...[
              _buildPaymentMethodSelector(),
              const SizedBox(height: 16),
            ],

            const SizedBox(height: 24),
            _buildSaveButton(isEditing),
          ],
        ),
      ),
    );
  }

  // Tutar alanı
  Widget _buildAmountSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: FormField<String>(
        initialValue: _amountController.text,
        validator: (value) => AmountInputFormatter.validateAmount(
          _amountController.text,
          maxAmount: 10000000,
        ),
        builder: (FormFieldState<String> state) {
          return Column(
            children: [
              Text(
                context.l10n.incomeAmount,
                style: const TextStyle(color: Colors.white54, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _localSelectedCurrency,
                      icon: const Icon(
                        Icons.arrow_drop_down,
                        color: Colors.white38,
                      ),
                      dropdownColor: Colors.grey[900],
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _localSelectedCurrency = newValue;
                          });
                        }
                      },
                      items: CurrencyService.supportedCurrencies.keys
                          .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                CurrencyService.supportedCurrencies[value]!,
                                style: const TextStyle(
                                  color: Colors.white38,
                                  fontSize: 36,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            );
                          })
                          .toList(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IntrinsicWidth(
                    child: TextField(
                      controller: _amountController,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.w300,
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [AmountInputFormatter()],
                      textAlign: TextAlign.center,
                      onChanged: (value) => state.didChange(value),
                      decoration: const InputDecoration(
                        hintText: "0",
                        hintStyle: TextStyle(
                          color: Colors.white24,
                          fontSize: 48,
                          fontWeight: FontWeight.w300,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ),
              // Hata mesajı - ayrı label olarak
              if (state.hasError) ...[
                const SizedBox(height: 8),
                Text(
                  state.errorText!,
                  style: const TextStyle(color: _accentColor, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  // Ortak text field builder
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 13),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white24),
            prefixIcon: Icon(icon, color: _accentColor, size: 22),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: _accentColor.withValues(alpha: 0.5),
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _accentColor),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }

  // Tarih seçici - DatePickerField.income kullanılıyor
  Widget _buildDateSelector() {
    return DatePickerField.income(
      selectedDate: _selectedDate,
      onDateChanged: (picked) {
        if (_controller != null) {
          _controller!.setFormDate(picked);
        } else {
          _localSelectedDate = picked;
          setState(() {});
        }
      },
      labelText: context.l10n.incomeDate,
    );
  }

  // Kategori seçici - CategorySelector.income kullanılıyor
  Widget _buildCategorySelector() {
    return CategorySelector.income(
      selectedCategory: _selectedCategory,
      categoryIcons: _categoryIcons,
      onChanged: (newValue) {
        if (_controller != null) {
          _controller!.setFormCategory(newValue!);
        } else {
          _localSelectedCategory = newValue!;
          setState(() {});
        }
      },
    );
  }

  // Ödeme yöntemi seçici
  Widget _buildPaymentMethodSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.incomePaymentMethod,
          style: const TextStyle(color: Colors.white54, fontSize: 13),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String?>(
              value: _selectedPaymentMethodId,
              dropdownColor: const Color(0xFF1E1E1E),
              style: const TextStyle(color: Colors.white, fontSize: 16),
              isExpanded: true,
              icon: const Icon(Icons.expand_more, color: Colors.white38),
              hint: Row(
                children: [
                  const Icon(
                    Icons.account_balance_wallet_outlined,
                    color: _accentColor,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    context.l10n.selectAccount,
                    style: const TextStyle(color: Colors.white38),
                  ),
                ],
              ),
              items: widget.paymentMethods.map((pm) {
                IconData icon = pm.type == 'nakit'
                    ? Icons.wallet
                    : pm.type == 'kredi'
                    ? Icons.credit_card
                    : Icons.account_balance;
                return DropdownMenuItem<String?>(
                  value: pm.id,
                  child: Row(
                    children: [
                      Icon(icon, color: _accentColor, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: context.translateDbName(pm.name),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                              if (pm.lastFourDigits != null) ...[
                                TextSpan(
                                  text: ' - ****${pm.lastFourDigits}',
                                  style: const TextStyle(
                                    color: Colors.white38,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        () {
                          final cur = getIt<CurrencyService>();
                          return CurrencyFormatter.format(
                            cur.convert(
                              pm.balance,
                              pm.paraBirimi,
                              cur.currentCurrency,
                            ),
                          );
                        }(),
                        style: TextStyle(
                          color: _accentColor.withValues(alpha: 0.8),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (newValue) {
                if (_controller != null) {
                  _controller!.setFormPaymentMethod(newValue);
                } else {
                  _localSelectedPaymentMethodId = newValue;
                  setState(() {});
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  // Kaydet butonu
  Widget _buildSaveButton(bool isEditing) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: _accentColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _save,
          borderRadius: BorderRadius.circular(20),
          child: Center(
            child: Text(
              isEditing ? context.l10n.updateButton : context.l10n.addIncome,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
