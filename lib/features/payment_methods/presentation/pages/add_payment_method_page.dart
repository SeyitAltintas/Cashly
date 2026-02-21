import 'package:flutter/material.dart';
import 'package:cashly/core/extensions/l10n_extensions.dart';
import 'package:flutter/services.dart';
import '../../data/models/payment_method_model.dart';
import '../../../../core/utils/amount_input_formatter.dart';
import '../../../../core/utils/error_handler.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../../../core/constants/card_color_constants.dart';
import '../controllers/payment_methods_controller.dart';

/// Ödeme Yöntemi Ekleme/Düzenleme Sayfası
/// Modern tam sayfa tasarım - Koyu tema ile uyumlu
class AddPaymentMethodPage extends StatefulWidget {
  final PaymentMethod? paymentMethod;
  final Function(
    String name,
    String type,
    String? lastFourDigits,
    double balance,
    double? limit,
    int colorIndex,
  )
  onSave;
  final PaymentMethodsController? controller;

  const AddPaymentMethodPage({
    super.key,
    this.paymentMethod,
    required this.onSave,
    this.controller,
  });

  @override
  State<AddPaymentMethodPage> createState() => _AddPaymentMethodPageState();
}

class _AddPaymentMethodPageState extends State<AddPaymentMethodPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _lastFourController;
  late TextEditingController _balanceController;
  late TextEditingController _limitController;

  // Controller veya yerel state
  PaymentMethodsController? _controller;
  String _localSelectedType = 'banka';
  int _localSelectedColorIndex = 0;

  // Getter'lar
  String get _selectedType =>
      _controller?.formSelectedType ?? _localSelectedType;
  int get _selectedColorIndex =>
      _controller?.formSelectedColorIndex ?? _localSelectedColorIndex;

  final List<String> _types = ['banka', 'kredi', 'nakit'];
  final List<String> _typeLabels = ['Banka Kartı', 'Kredi Kartı', 'Nakit'];

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
    _controller?.addListener(_onFormStateChanged);

    _nameController = TextEditingController(
      text: widget.paymentMethod?.name ?? '',
    );
    _lastFourController = TextEditingController(
      text: widget.paymentMethod?.lastFourDigits ?? '',
    );
    _balanceController = TextEditingController(
      text: widget.paymentMethod != null
          ? AmountInputFormatter.formatInitialValue(
              widget.paymentMethod!.balance,
            )
          : '',
    );
    _limitController = TextEditingController(
      text: widget.paymentMethod?.limit != null
          ? AmountInputFormatter.formatInitialValue(
              widget.paymentMethod!.limit!,
            )
          : '',
    );

    final editType = widget.paymentMethod?.type ?? 'banka';
    final editColorIndex = widget.paymentMethod?.colorIndex ?? 0;

    if (_controller != null) {
      _controller!.initializeFormState(
        editType: editType,
        editColorIndex: editColorIndex,
      );
    } else {
      _localSelectedType = editType;
      _localSelectedColorIndex = editColorIndex;
    }
  }

  void _onFormStateChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller?.removeListener(_onFormStateChanged);
    _nameController.dispose();
    _lastFourController.dispose();
    _balanceController.dispose();
    _limitController.dispose();
    super.dispose();
  }

  void _save() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Türk formatından parse et (1.234,56 -> 1234.56)
        final balance =
            AmountInputFormatter.parseFormattedAmount(
              _balanceController.text,
            ) ??
            0.0;
        final limit = _selectedType == 'kredi'
            ? AmountInputFormatter.parseFormattedAmount(_limitController.text)
            : null;

        await widget.onSave(
          _nameController.text.trim(),
          _selectedType,
          _selectedType != 'nakit' && _lastFourController.text.isNotEmpty
              ? _lastFourController.text.trim()
              : null,
          balance,
          limit,
          _selectedColorIndex,
        );
        if (!mounted) return;
        Navigator.pop(context);
      } catch (e) {
        if (!mounted) return;
        if (e is AppException) {
          ErrorHandler.handleAppException(context, e);
        } else {
          ErrorHandler.showErrorSnackBar(
            context,
            'Kaydetme sırasında bir hata oluştu',
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.paymentMethod != null;

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
          isEditing ? 'Ödeme Yöntemi Düzenle' : 'Yeni Ödeme Yöntemi',
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
            // Kart Önizleme
            _buildCardPreview(),
            const SizedBox(height: 28),

            // Tip Seçimi
            _buildTypeSelector(),
            const SizedBox(height: 24),

            // İsim
            _buildNameField(),
            const SizedBox(height: 16),

            // Son 4 Hane (sadece banka ve kredi kartları için)
            if (_selectedType != 'nakit') ...[
              _buildLastFourField(),
              const SizedBox(height: 16),
            ],

            // Bakiye/Borç
            _buildBalanceField(),
            const SizedBox(height: 16),

            // Limit (sadece kredi kartları için)
            if (_selectedType == 'kredi') ...[
              _buildLimitField(),
              const SizedBox(height: 16),
            ],

            // Renk Seçimi
            _buildColorSelector(),
            const SizedBox(height: 32),

            // Alt kaydet butonu
            _buildSaveButton(isEditing),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildCardPreview() {
    final name = _nameController.text.isEmpty
        ? (_selectedType == 'nakit' ? 'Nakit' : 'Kart Adı')
        : _nameController.text;
    final lastFour = _lastFourController.text.isEmpty
        ? '••••'
        : _lastFourController.text;
    // Türk formatından parse et (1.234,56 -> 1234.56)
    final balance =
        AmountInputFormatter.parseFormattedAmount(_balanceController.text) ??
        0.0;
    final limit = AmountInputFormatter.parseFormattedAmount(
      _limitController.text,
    );

    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: CardColorConstants.gradients[_selectedColorIndex],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: CardColorConstants.gradients[_selectedColorIndex][0]
                .withValues(alpha: 0.5),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Üst kısım - Tip ve İkon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _typeLabels[_types.indexOf(_selectedType)],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(
                _selectedType == 'nakit'
                    ? Icons.wallet
                    : _selectedType == 'kredi'
                    ? Icons.credit_card
                    : Icons.account_balance,
                color: Colors.white.withValues(alpha: 0.8),
                size: 36,
              ),
            ],
          ),
          // Orta kısım - Kart numarası
          if (_selectedType != 'nakit')
            Text(
              '•••• •••• •••• $lastFour',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                letterSpacing: 3,
                fontWeight: FontWeight.w500,
              ),
            ),
          // Alt kısım - İsim ve bakiye
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name.toUpperCase(),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 14,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (_selectedType == 'kredi' && limit != null)
                      Text(
                        'Limit: ${AmountInputFormatter.formatInitialValue(limit).replaceAll(',00', '')} ₺',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 11,
                        ),
                      ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _selectedType == 'kredi' ? 'Borç' : 'Bakiye',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 11,
                    ),
                  ),
                  Text(
                    '${AmountInputFormatter.formatInitialValue(balance)} ₺',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Kart Tipi',
          style: TextStyle(
            color: Colors.white54,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Row(
            children: List.generate(_types.length, (index) {
              final isSelected = _selectedType == _types[index];
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (_controller != null) {
                      _controller!.setFormType(_types[index]);
                    } else {
                      _localSelectedType = _types[index];
                      setState(() {});
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context).colorScheme.secondary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      _typeLabels[index],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isSelected ? Colors.black : Colors.white60,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _selectedType == 'nakit' ? 'İsim' : 'Banka/Kart Adı',
          style: const TextStyle(color: Colors.white54, fontSize: 13),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _nameController,
          maxLength: 30,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          inputFormatters: [
            FilteringTextInputFormatter.allow(
              RegExp(r'[a-zA-ZğüşıöçĞÜŞİÖÇ0-9\s]'),
            ),
          ],
          decoration: InputDecoration(
            hintText: _selectedType == 'nakit'
                ? 'Örn: Cüzdan'
                : 'Örn: Ziraat Bankası',
            hintStyle: const TextStyle(color: Colors.white24),
            counterText: '',
            prefixIcon: Icon(
              _selectedType == 'nakit' ? Icons.wallet : Icons.credit_card,
              color: Theme.of(context).colorScheme.secondary,
              size: 22,
            ),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.secondary,
                width: 2,
              ),
            ),
            floatingLabelStyle: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red.shade400),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Lütfen bir isim girin';
            }
            final trimmed = value.trim();
            if (trimmed.length < 2) {
              return 'İsim en az 2 karakter olmalı';
            }
            if (RegExp(r'^[\s0-9]+$').hasMatch(trimmed)) {
              return 'İsim en az bir harf içermeli';
            }
            return null;
          },
          onChanged: (_) => setState(() {}),
        ),
      ],
    );
  }

  Widget _buildLastFourField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Son 4 Hane (Opsiyonel)',
          style: TextStyle(color: Colors.white54, fontSize: 13),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _lastFourController,
          keyboardType: TextInputType.number,
          maxLength: 4,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            hintText: '1234',
            hintStyle: const TextStyle(color: Colors.white24),
            counterText: '',
            prefixIcon: Icon(
              Icons.dialpad,
              color: Theme.of(context).colorScheme.secondary,
              size: 22,
            ),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.secondary,
                width: 2,
              ),
            ),
            floatingLabelStyle: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return null;
            }
            if (value.isNotEmpty && value.length < 4) {
              return 'Tam 4 rakam girmelisiniz';
            }
            if (RegExp(r'^(.)\1{3}$').hasMatch(value)) {
              return 'Geçersiz kart numarası';
            }
            return null;
          },
          onChanged: (_) => setState(() {}),
        ),
      ],
    );
  }

  Widget _buildBalanceField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _selectedType == 'kredi' ? 'Mevcut Borç' : 'Bakiye',
          style: const TextStyle(color: Colors.white54, fontSize: 13),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _balanceController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: const TextStyle(color: Colors.white, fontSize: 16),
          inputFormatters: [
            AmountInputFormatter(), // Türk para formatı: 1.000,00
          ],
          decoration: InputDecoration(
            hintText: _selectedType == 'kredi' ? '0,00' : '1.000,00',
            hintStyle: const TextStyle(color: Colors.white24),
            prefixIcon: Icon(
              _selectedType == 'kredi'
                  ? Icons.money_off
                  : Icons.account_balance_wallet,
              color: Theme.of(context).colorScheme.secondary,
              size: 22,
            ),
            suffixText: '₺',
            suffixStyle: const TextStyle(color: Colors.white54),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.secondary,
                width: 2,
              ),
            ),
            floatingLabelStyle: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red.shade400),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return _selectedType == 'kredi'
                  ? 'Lütfen borç tutarını girin (0 olabilir)'
                  : 'Lütfen bakiye girin';
            }
            // Türk formatından parse et (1.234,56 -> 1234.56)
            final amount = AmountInputFormatter.parseFormattedAmount(value);
            if (amount == null) {
              return 'Geçersiz tutar formatı';
            }
            if (amount < 0) {
              return 'Tutar negatif olamaz';
            }
            if (amount > 100000000) {
              return 'Maksimum tutar 100 milyon ₺ olabilir';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildLimitField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Kart Limiti',
          style: TextStyle(color: Colors.white54, fontSize: 13),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _limitController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: const TextStyle(color: Colors.white, fontSize: 16),
          inputFormatters: [
            AmountInputFormatter(), // Türk para formatı: 10.000,00
          ],
          decoration: InputDecoration(
            hintText: '10.000,00',
            hintStyle: const TextStyle(color: Colors.white24),
            prefixIcon: Icon(
              Icons.trending_up,
              color: Theme.of(context).colorScheme.secondary,
              size: 22,
            ),
            suffixText: '₺',
            suffixStyle: const TextStyle(color: Colors.white54),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.secondary,
                width: 2,
              ),
            ),
            floatingLabelStyle: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.red.shade400),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return null;
            }
            // Türk formatından parse et (10.000,00 -> 10000.00)
            final limit = AmountInputFormatter.parseFormattedAmount(value);
            if (limit == null) {
              return 'Geçersiz tutar formatı';
            }
            if (limit <= 0) {
              return 'Limit 0\'dan büyük olmalı';
            }
            // Mevcut borç değerini parse et
            final debt =
                AmountInputFormatter.parseFormattedAmount(
                  _balanceController.text,
                ) ??
                0;
            if (limit < debt) {
              return 'Limit mevcut borçtan küçük olamaz';
            }
            if (limit > 1000000000) {
              return 'Maksimum limit 1 milyar ₺ olabilir';
            }
            if (limit < 100) {
              return 'Minimum limit 100 ₺ olmalı';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildColorSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Kart Rengi',
          style: TextStyle(color: Colors.white54, fontSize: 13),
        ),
        const SizedBox(height: 4),
        Text(
          'Daha fazla renk için sağa kaydırın →',
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withValues(alpha: 0.4),
          ),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: List.generate(CardColorConstants.count, (index) {
              final isSelected = _selectedColorIndex == index;
              return Padding(
                padding: EdgeInsets.only(
                  right: index < CardColorConstants.count - 1 ? 12 : 0,
                ),
                child: GestureDetector(
                  onTap: () {
                    if (_controller != null) {
                      _controller!.setFormColorIndex(index);
                    } else {
                      _localSelectedColorIndex = index;
                      setState(() {});
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: CardColorConstants.gradients[index],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: isSelected
                          ? Border.all(
                              color: Theme.of(context).colorScheme.secondary,
                              width: 3,
                            )
                          : Border.all(
                              color: Colors.white.withValues(alpha: 0.15),
                              width: 1,
                            ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: CardColorConstants.gradients[index][0]
                                    .withValues(alpha: 0.6),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 22)
                        : null,
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton(bool isEditing) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(
              context,
            ).colorScheme.secondary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _save,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: Text(
              isEditing ? context.l10n.update : context.l10n.save,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
