import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cashly/core/theme/theme_manager.dart';
import '../../data/models/payment_method_model.dart';

class AddPaymentMethodSheet extends StatefulWidget {
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

  const AddPaymentMethodSheet({
    super.key,
    this.paymentMethod,
    required this.onSave,
  });

  @override
  State<AddPaymentMethodSheet> createState() => _AddPaymentMethodSheetState();
}

class _AddPaymentMethodSheetState extends State<AddPaymentMethodSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _lastFourController;
  late TextEditingController _balanceController;
  late TextEditingController _limitController;

  String _selectedType = 'banka';
  int _selectedColorIndex = 0;

  final List<String> _types = ['banka', 'kredi', 'nakit'];
  final List<String> _typeLabels = ['Banka Kartı', 'Kredi Kartı', 'Nakit'];

  final List<List<Color>> _cardColors = [
    [const Color(0xFF1a1a2e), const Color(0xFF16213e)], // Koyu Mavi
    [const Color(0xFF2d132c), const Color(0xFF432371)], // Mor
    [const Color(0xFF0f3460), const Color(0xFF16537e)], // Mavi
    [const Color(0xFF1e5128), const Color(0xFF4e9f3d)], // Yeşil
    [const Color(0xFF5c2018), const Color(0xFF8b3a2f)], // Kırmızı
    [const Color(0xFF3d3d3d), const Color(0xFF5a5a5a)], // Gri
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.paymentMethod?.name ?? '',
    );
    _lastFourController = TextEditingController(
      text: widget.paymentMethod?.lastFourDigits ?? '',
    );
    _balanceController = TextEditingController(
      text: widget.paymentMethod?.balance.toStringAsFixed(2) ?? '',
    );
    _limitController = TextEditingController(
      text: widget.paymentMethod?.limit?.toStringAsFixed(2) ?? '',
    );
    _selectedType = widget.paymentMethod?.type ?? 'banka';
    _selectedColorIndex = widget.paymentMethod?.colorIndex ?? 0;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lastFourController.dispose();
    _balanceController.dispose();
    _limitController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final balance =
          double.tryParse(_balanceController.text.replaceAll(',', '.')) ?? 0.0;
      final limit = _selectedType == 'kredi'
          ? double.tryParse(_limitController.text.replaceAll(',', '.'))
          : null;

      widget.onSave(
        _nameController.text.trim(),
        _selectedType,
        _selectedType != 'nakit' && _lastFourController.text.isNotEmpty
            ? _lastFourController.text.trim()
            : null,
        balance,
        limit,
        _selectedColorIndex,
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDefaultTheme = context.watch<ThemeManager>().isDefaultTheme;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[600],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                widget.paymentMethod != null
                    ? 'Ödeme Yöntemi Düzenle'
                    : 'Yeni Ödeme Yöntemi',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 24),

              // Kart Önizleme
              _buildCardPreview(),
              const SizedBox(height: 24),

              // Tip Seçimi
              Text(
                'Kart Tipi',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.1),
                  ),
                ),
                child: Row(
                  children: List.generate(_types.length, (index) {
                    final isSelected = _selectedType == _types[index];
                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedType = _types[index];
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (isDefaultTheme
                                      ? Theme.of(context).colorScheme.secondary
                                      : Theme.of(context).colorScheme.primary)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            _typeLabels[index],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isSelected
                                  ? (isDefaultTheme
                                        ? Colors.black
                                        : Colors.white)
                                  : Theme.of(context).colorScheme.onSurface
                                        .withValues(alpha: 0.6),
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 20),

              // İsim
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: _selectedType == 'nakit'
                      ? 'İsim'
                      : 'Banka/Kart Adı',
                  hintText: _selectedType == 'nakit'
                      ? 'Örn: Cüzdan'
                      : 'Örn: Ziraat Bankası',
                  prefixIcon: Icon(
                    _selectedType == 'nakit' ? Icons.wallet : Icons.credit_card,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.1),
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Lütfen bir isim girin';
                  }
                  return null;
                },
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),

              // Son 4 Hane (sadece banka ve kredi kartları için)
              if (_selectedType != 'nakit') ...[
                TextFormField(
                  controller: _lastFourController,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  decoration: InputDecoration(
                    labelText: 'Son 4 Hane (Opsiyonel)',
                    hintText: '1234',
                    prefixIcon: Icon(
                      Icons.dialpad,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    counterText: '',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.1),
                      ),
                    ),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 16),
              ],

              // Bakiye
              TextFormField(
                controller: _balanceController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: _selectedType == 'kredi'
                      ? 'Mevcut Borç'
                      : 'Bakiye',
                  hintText: '0.00',
                  prefixIcon: Icon(
                    Icons.attach_money,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  suffixText: '₺',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.1),
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen bir tutar girin';
                  }
                  if (double.tryParse(value.replaceAll(',', '.')) == null) {
                    return 'Geçersiz tutar';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Limit (sadece kredi kartları için)
              if (_selectedType == 'kredi') ...[
                TextFormField(
                  controller: _limitController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Kart Limiti',
                    hintText: '10000.00',
                    prefixIcon: Icon(
                      Icons.trending_up,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    suffixText: '₺',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.1),
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      if (double.tryParse(value.replaceAll(',', '.')) == null) {
                        return 'Geçersiz tutar';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
              ],

              // Renk Seçimi
              Text(
                'Kart Rengi',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(_cardColors.length, (index) {
                  final isSelected = _selectedColorIndex == index;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedColorIndex = index;
                      });
                    },
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: _cardColors[index],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: isSelected
                            ? Border.all(
                                color: Theme.of(context).colorScheme.secondary,
                                width: 3,
                              )
                            : null,
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: _cardColors[index][0].withValues(
                                    alpha: 0.5,
                                  ),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 20,
                            )
                          : null,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 28),

              // Kaydet Butonu
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDefaultTheme
                        ? Theme.of(context).colorScheme.secondary
                        : Theme.of(context).colorScheme.primary,
                    foregroundColor: isDefaultTheme
                        ? Colors.black
                        : Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    widget.paymentMethod != null ? 'Güncelle' : 'Kaydet',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
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
    final balance =
        double.tryParse(_balanceController.text.replaceAll(',', '.')) ?? 0.0;
    final limit = double.tryParse(_limitController.text.replaceAll(',', '.'));

    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _cardColors[_selectedColorIndex],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _cardColors[_selectedColorIndex][0].withValues(alpha: 0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
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
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _typeLabels[_types.indexOf(_selectedType)],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
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
                size: 32,
              ),
            ],
          ),
          // Orta kısım - Kart numarası
          if (_selectedType != 'nakit')
            Text(
              '•••• •••• •••• $lastFour',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                letterSpacing: 2,
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
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 12,
                        letterSpacing: 1,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (_selectedType == 'kredi' && limit != null)
                      Text(
                        'Limit: ${limit.toStringAsFixed(0)} ₺',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 10,
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
                      fontSize: 10,
                    ),
                  ),
                  Text(
                    '${balance.toStringAsFixed(2)} ₺',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
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
}
