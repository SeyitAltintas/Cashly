import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/asset_model.dart';
import '../../../../core/services/price_service.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/utils/error_handler.dart';
import '../../../../core/utils/amount_input_formatter.dart';
import '../../../../core/widgets/app_date_picker.dart';
import '../../../../core/extensions/l10n_extensions.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/services/currency_service.dart';
import '../controllers/assets_controller.dart';

/// Varlık ekleme/düzenleme sayfası
/// Modern ve sade tasarım - Varlık temasına uygun (mor)
class AddAssetPage extends StatefulWidget {
  final Function(
    String name,
    double amount,
    double quantity,
    String category,
    String? type,
    DateTime purchaseDate,
    double purchasePrice,
  )
  onSave;
  final Asset? asset;
  final AssetsController? controller;

  const AddAssetPage({
    super.key,
    required this.onSave,
    this.asset,
    this.controller,
  });

  @override
  State<AddAssetPage> createState() => _AddAssetPageState();
}

class _AddAssetPageState extends State<AddAssetPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _purchasePriceController =
      TextEditingController();

  // Özel isim inputları için controller'lar
  final TextEditingController _customCurrencyNameController =
      TextEditingController();
  final TextEditingController _customCryptoNameController =
      TextEditingController();
  final TextEditingController _customBankNameController =
      TextEditingController();
  final TextEditingController _stockNameController = TextEditingController();
  final TextEditingController _customCategoryNameController =
      TextEditingController();

  // Controller veya yerel state
  AssetsController? _controller;
  String _localSelectedCategory = 'Döviz';
  String? _localSelectedType;
  DateTime? _localPurchaseDate;
  bool _localIsLoading = false;
  String? _localErrorMessage;

  // Getter'lar - controller varsa onu kullan
  String get _selectedCategory =>
      _controller?.formSelectedCategory ?? _localSelectedCategory;
  String? get _selectedType =>
      _controller?.formSelectedType ?? _localSelectedType;
  DateTime get _purchaseDate =>
      _controller?.formPurchaseDate ?? _localPurchaseDate ?? DateTime.now();
  bool get _isLoading => _controller?.formIsLoading ?? _localIsLoading;
  String? get _errorMessage =>
      _controller?.formErrorMessage ?? _localErrorMessage;

  // Varlık teması rengi (mavi - Varlıklarım sayfası ile uyumlu)
  static Color get _accentColor => Colors.blue.shade600;

  final List<String> _categories = [
    'Altın',
    'Gümüş',
    'Döviz',
    'Kripto',
    'Banka',
    'Hisse Senedi',
    'Diğer',
  ];

  final Map<String, List<String>> _types = {
    'Altın': ['Gram', 'Çeyrek', 'Yarım', 'Tam', 'Cumhuriyet', 'Ata', 'Ons'],
    'Gümüş': ['Gram', 'Ons'],
    'Döviz': [
      'Amerikan Doları (USD)',
      'Euro (EUR)',
      'İngiliz Sterlini (GBP)',
      'İsviçre Frangı (CHF)',
      'Japon Yeni (JPY)',
      'Kanada Doları (CAD)',
      'Diğer',
    ],
    'Kripto': ['BTC', 'ETH', 'SOL', 'AVAX', 'XRP', 'USDT', 'Diğer'],
    'Hisse Senedi': ['Diğer'],
    'Banka': [
      'Ziraat Bankası',
      'İş Bankası',
      'Garanti BBVA',
      'Akbank',
      'Yapı Kredi',
      'Halkbank',
      'VakıfBank',
      'QNB Finansbank',
      'DenizBank',
      'TEB',
      'Kuveyt Türk',
      'Enpara.com',
      'Papara',
      'Diğer',
    ],
  };

  final PriceService _priceService = PriceService();

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
    _controller?.addListener(_onFormStateChanged);

    if (widget.asset != null) {
      _nameController.text = widget.asset!.name;
      final cur = getIt<CurrencyService>();
      final convertedAmount = cur.convert(
        widget.asset!.amount,
        widget.asset!.paraBirimi,
        cur.currentCurrency,
      );
      _amountController.text = AmountInputFormatter.formatInitialValue(
        convertedAmount,
      );
      _quantityController.text = widget.asset!.quantity.toString();

      final editCategory = widget.asset!.category;
      String? editType;

      final typeFromAsset = widget.asset!.type;
      if (typeFromAsset != null &&
          _types.containsKey(editCategory) &&
          _types[editCategory]!.contains(typeFromAsset)) {
        editType = typeFromAsset;
      } else if (typeFromAsset != null && _types.containsKey(editCategory)) {
        editType = 'Diğer';
        _populateCustomFieldFromType(editCategory, typeFromAsset);
      }

      if (_controller != null) {
        _controller!.initializeFormState(
          editCategory: editCategory,
          editType: editType,
          editPurchaseDate: widget.asset!.purchaseDate,
        );
      } else {
        _localSelectedCategory = editCategory;
        _localSelectedType = editType;
        _localPurchaseDate = widget.asset!.purchaseDate;
      }

      if (editCategory == 'Hisse Senedi') {
        _stockNameController.text = widget.asset!.name;
      }
      if (editCategory == 'Diğer') {
        _customCategoryNameController.text = widget.asset!.name;
      }
      final convertedPurchasePrice = cur.convert(
        widget.asset!.purchasePrice,
        widget.asset!.paraBirimi,
        cur.currentCurrency,
      );
      _purchasePriceController.text = AmountInputFormatter.formatInitialValue(
        convertedPurchasePrice,
      );
    } else {
      _quantityController.text = "1";
      if (_controller != null) {
        _controller!.initializeFormState(editPurchaseDate: DateTime.now());
      } else {
        _localPurchaseDate = DateTime.now();
      }
    }
  }

  void _onFormStateChanged() {
    if (mounted) setState(() {});
  }

  /// Özel tür alanlarını doldurur (düzenleme modunda)
  void _populateCustomFieldFromType(String category, String typeValue) {
    switch (category) {
      case 'Döviz':
        _customCurrencyNameController.text = typeValue;
        break;
      case 'Kripto':
        _customCryptoNameController.text = typeValue;
        break;
      case 'Banka':
        _customBankNameController.text = typeValue;
        break;
    }
  }

  @override
  void dispose() {
    _controller?.removeListener(_onFormStateChanged);
    _nameController.dispose();
    _amountController.dispose();
    _quantityController.dispose();
    _purchasePriceController.dispose();
    _customCurrencyNameController.dispose();
    _customCryptoNameController.dispose();
    _customBankNameController.dispose();
    _stockNameController.dispose();
    _customCategoryNameController.dispose();
    super.dispose();
  }

  Future<void> _fetchLivePrice() async {
    if (_controller != null) {
      _controller!.setFormLoading(true);
      _controller!.clearFormError();
    } else {
      _localIsLoading = true;
      _localErrorMessage = null;
      setState(() {});
    }

    double? unitPrice;

    try {
      if (_selectedCategory == 'Altın') {
        unitPrice = await _priceService.getGoldPrice(_selectedType ?? 'Gram');
      } else if (_selectedCategory == 'Döviz') {
        String currencyCode = 'USD';
        if (_selectedType != null && _selectedType!.contains('(')) {
          currencyCode = _selectedType!.split('(').last.replaceAll(')', '');
        }
        unitPrice = await _priceService.getCurrencyPrice(currencyCode);
      } else if (_selectedCategory == 'Kripto') {
        String cryptoId = 'bitcoin';
        switch (_selectedType) {
          case 'BTC':
            cryptoId = 'bitcoin';
            break;
          case 'ETH':
            cryptoId = 'ethereum';
            break;
          case 'SOL':
            cryptoId = 'solana';
            break;
          case 'AVAX':
            cryptoId = 'avalanche-2';
            break;
          case 'XRP':
            cryptoId = 'ripple';
            break;
          case 'USDT':
            cryptoId = 'tether';
            break;
        }
        unitPrice = await _priceService.getCryptoPrice(cryptoId);
      } else if (_selectedCategory == 'Gümüş') {
        unitPrice = await _priceService.getSilverPrice(_selectedType ?? 'Gram');
      }

      if (mounted) {
        if (_controller != null) {
          _controller!.setFormLoading(false);
          if (unitPrice != null) {
            double quantity = double.tryParse(_quantityController.text) ?? 1.0;
            double totalAmount = unitPrice * quantity;
            _amountController.text = AmountInputFormatter.formatInitialValue(
              totalAmount,
            );
            _controller!.clearFormError();
          } else {
            _controller!.setFormError(context.l10n.priceFetchFailed);
          }
        } else {
          _localIsLoading = false;
          if (unitPrice != null) {
            double quantity = double.tryParse(_quantityController.text) ?? 1.0;
            double totalAmount = unitPrice * quantity;
            _amountController.text = AmountInputFormatter.formatInitialValue(
              totalAmount,
            );
            _localErrorMessage = null;
          } else {
            _localErrorMessage = context.l10n.priceFetchFailed;
          }
          setState(() {});
        }
      }
    } catch (e) {
      if (mounted) {
        if (_controller != null) {
          _controller!.setFormLoading(false);
          _controller!.setFormError(context.l10n.priceFetchError);
        } else {
          _localIsLoading = false;
          _localErrorMessage = context.l10n.priceFetchError;
          setState(() {});
        }
      }
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    if (_nameController.text.trim().isNotEmpty &&
        _amountController.text.isNotEmpty) {
      // Türkçe format desteği için parseFormattedAmount kullan
      final amount =
          AmountInputFormatter.parseFormattedAmount(_amountController.text) ??
          0.0;
      final purchasePrice = _purchasePriceController.text.isNotEmpty
          ? AmountInputFormatter.parseFormattedAmount(
                  _purchasePriceController.text,
                ) ??
                amount
          : amount;

      // "Diğer" seçilmişse özel isim alanındaki değeri type olarak kullan
      String? effectiveType = _selectedType;
      if (_selectedType == 'Diğer') {
        switch (_selectedCategory) {
          case 'Döviz':
            if (_customCurrencyNameController.text.trim().isNotEmpty) {
              effectiveType = _customCurrencyNameController.text.trim();
            }
            break;
          case 'Kripto':
            if (_customCryptoNameController.text.trim().isNotEmpty) {
              effectiveType = _customCryptoNameController.text.trim();
            }
            break;
          case 'Banka':
            if (_customBankNameController.text.trim().isNotEmpty) {
              effectiveType = _customBankNameController.text.trim();
            }
            break;
        }
      }

      widget.onSave(
        _nameController.text.trim(),
        amount,
        double.tryParse(_quantityController.text) ?? 1.0,
        _selectedCategory,
        effectiveType,
        _purchaseDate,
        purchasePrice,
      );
      if (mounted) Navigator.pop(context);
    } else {
      ErrorHandler.showErrorSnackBar(
        context,
        context.l10n.pleaseFillRequiredFields,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.asset != null;

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
          isEditing ? context.l10n.editAsset : context.l10n.addAsset,
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
            // Varlık Adı
            _buildTextField(
              controller: _nameController,
              label: context.l10n.assetName,
              hint: 'e.g. Gold Gram',
              icon: Icons.diamond_outlined,
              validator: (value) => Validators.validateItemName(
                value,
                itemType: context.l10n.assetNameField,
              ),
            ),
            const SizedBox(height: 16),

            // Kategori
            _buildCategorySelector(),
            const SizedBox(height: 16),

            // Tür
            // Tür Seçici - Hisse Senedi ve Diğer kategorilerinde görünmesin
            if (_types.containsKey(_selectedCategory) &&
                _selectedCategory != 'Hisse Senedi' &&
                _selectedCategory != 'Diğer') ...[
              _buildTypeSelector(),
              const SizedBox(height: 16),
            ],

            // Kategori "Diğer" seçildiğinde özel isim alanı
            if (_selectedCategory == 'Diğer') ...[
              _buildTextField(
                controller: _customCategoryNameController,
                label: context.l10n.assetNameField,
                hint: 'e.g. Antique Watch',
                icon: Icons.edit_outlined,
                validator: (value) => Validators.validateItemName(
                  value,
                  itemType: context.l10n.assetNameField,
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Hisse Senedi seçildiğinde hisse adı alanı
            if (_selectedCategory == 'Hisse Senedi') ...[
              _buildTextField(
                controller: _stockNameController,
                label: context.l10n.stockNameLabel,
                hint: 'e.g. THYAO, SASA',
                icon: Icons.trending_up,
                validator: (value) => Validators.validateItemName(
                  value,
                  itemType: context.l10n.stockNameLabel,
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Döviz "Diğer" seçildiğinde özel döviz ismi alanı
            if (_selectedCategory == 'Döviz' && _selectedType == 'Diğer') ...[
              _buildTextField(
                controller: _customCurrencyNameController,
                label: context.l10n.currencyNameLabel,
                hint: 'e.g. SEK, NOK',
                icon: Icons.attach_money,
                validator: (value) => Validators.validateItemName(
                  value,
                  itemType: context.l10n.currencyNameLabel,
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Kripto "Diğer" seçildiğinde özel kripto ismi alanı
            if (_selectedCategory == 'Kripto' && _selectedType == 'Diğer') ...[
              _buildTextField(
                controller: _customCryptoNameController,
                label: context.l10n.cryptoNameLabel,
                hint: 'e.g. DOGE, SHIB',
                icon: Icons.currency_bitcoin,
                validator: (value) => Validators.validateItemName(
                  value,
                  itemType: context.l10n.cryptoNameLabel,
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Banka "Diğer" seçildiğinde özel banka adı alanı
            if (_selectedCategory == 'Banka' && _selectedType == 'Diğer') ...[
              _buildTextField(
                controller: _customBankNameController,
                label: context.l10n.bankNameLabel,
                hint: 'e.g. N26, Revolut',
                icon: Icons.account_balance,
                validator: (value) => Validators.validateItemName(
                  value,
                  itemType: context.l10n.bankNameLabel,
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Adet
            if (_selectedCategory != 'Banka' &&
                _selectedCategory != 'Döviz') ...[
              _buildTextField(
                controller: _quantityController,
                label: context.l10n.quantityLabel,
                hint: 'e.g. 1.0',
                icon: Icons.numbers,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: Validators.validateQuantity,
              ),
              const SizedBox(height: 16),
            ],

            // Miktar + Güncel Butonu
            _buildAmountSection(),

            // Hata mesajı
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              _buildErrorMessage(),
            ],

            // Alış Bilgileri (düzenleme modunda)
            if (widget.asset != null) ...[
              const SizedBox(height: 24),
              _buildPurchaseInfoSection(),
            ],

            const SizedBox(height: 32),
            _buildSaveButton(isEditing),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
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
          keyboardType: keyboardType,
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
              borderSide: BorderSide(color: _accentColor),
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

  Widget _buildCategorySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.category,
          style: const TextStyle(color: Colors.white54, fontSize: 13),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _categories.map((category) {
            final isSelected = _selectedCategory == category;
            return ChoiceChip(
              label: Text(context.translateDbName(category)),
              selected: isSelected,
              onSelected: (selected) {
                if (_controller != null) {
                  _controller!.setFormCategory(category);
                } else {
                  _localSelectedCategory = category;
                  _localSelectedType = null;
                  setState(() {});
                }
                if (category == 'Banka') {
                  _quantityController.text = "1";
                }
              },
              backgroundColor: Colors.white.withValues(alpha: 0.05),
              selectedColor: _accentColor,
              labelStyle: TextStyle(
                color: isSelected ? Colors.black : Colors.white70,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected
                      ? Colors.transparent
                      : Colors.white.withValues(alpha: 0.1),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _selectedCategory == 'Banka'
              ? context.l10n.bankNameLabel
              : context.l10n.category,
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
            child: DropdownButton<String>(
              value: _selectedType,
              hint: Text(
                context.l10n.notSpecified,
                style: const TextStyle(color: Colors.white38),
              ),
              dropdownColor: const Color(0xFF1E1E1E),
              style: const TextStyle(color: Colors.white, fontSize: 16),
              isExpanded: true,
              icon: const Icon(Icons.expand_more, color: Colors.white38),
              items: _types[_selectedCategory]!.map((String type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(context.translateDbName(type)),
                );
              }).toList(),
              onChanged: (value) {
                if (_controller != null) {
                  _controller!.setFormType(value);
                } else {
                  _localSelectedType = value;
                  setState(() {});
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAmountSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        () {
          final sym = getIt<CurrencyService>().currentSymbol;
          return Text(
            '${context.l10n.amount} ($sym)',
            style: const TextStyle(color: Colors.white54, fontSize: 13),
          );
        }(),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _amountController,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                keyboardType: TextInputType.number,
                inputFormatters: [AmountInputFormatter()],
                validator: (value) => AmountInputFormatter.validateAmount(
                  value,
                  maxAmount: 100000000,
                ),
                decoration: InputDecoration(
                  hintText: "0",
                  hintStyle: const TextStyle(color: Colors.white24),
                  prefixIcon: Icon(
                    Icons.currency_lira,
                    color: _accentColor,
                    size: 22,
                  ),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
            ),
            // Güncel butonu - Banka, Hisse Senedi, Diğer ve özel türler için görünmesin
            if (_selectedCategory != 'Banka' &&
                _selectedCategory != 'Hisse Senedi' &&
                _selectedCategory != 'Diğer' &&
                !(_selectedCategory == 'Döviz' && _selectedType == 'Diğer') &&
                !(_selectedCategory == 'Kripto' &&
                    _selectedType == 'Diğer')) ...[
              const SizedBox(width: 12),
              GestureDetector(
                onTap: _isLoading ? null : _fetchLivePrice,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: _accentColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _accentColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: _isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: _accentColor,
                          ),
                        )
                      : Text(
                          context.l10n.currentPriceButton,
                          style: TextStyle(
                            color: _accentColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPurchaseInfoSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.history, color: Colors.amber.shade700, size: 20),
              const SizedBox(width: 8),
              Text(
                context.l10n.purchaseInfo,
                style: TextStyle(
                  color: Colors.amber.shade700,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Alış Tarihi
          GestureDetector(
            onTap: () async {
              final picked = await AppDatePicker.show(
                context: context,
                initialDate: _purchaseDate,
                firstDate: DateTime(2000),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                if (_controller != null) {
                  _controller!.setFormPurchaseDate(picked);
                } else {
                  _localPurchaseDate = picked;
                  setState(() {});
                }
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    color: Colors.amber.shade600,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      DateFormat(
                        'dd MMMM yyyy',
                        Localizations.localeOf(context).languageCode == 'tr'
                            ? 'tr_TR'
                            : 'en_US',
                      ).format(_purchaseDate),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  const Icon(Icons.edit, color: Colors.white38, size: 18),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Alış Fiyatı - Edge case kontrolleri ile
          TextFormField(
            controller: _purchasePriceController,
            style: const TextStyle(color: Colors.white),
            keyboardType: TextInputType.number,
            inputFormatters: [AmountInputFormatter()],
            validator: (value) {
              // Edge Case 1: Boş değer - opsiyonel olduğu için geçerli
              if (value == null || value.trim().isEmpty) {
                return null; // Boş bırakılabilir, mevcut değer kullanılacak
              }

              // AmountInputFormatter kullanarak parse et
              final amount = AmountInputFormatter.parseFormattedAmount(value);

              // Edge Case 2: Geçersiz sayı formatı
              if (amount == null) {
                return context.l10n.enterValidPrice;
              }

              // Edge Case 3: Negatif değer
              if (amount < 0) {
                return context.l10n.purchasePriceNegative;
              }

              // Edge Case 4: Sıfır değer
              if (amount == 0) {
                return context.l10n.purchasePriceMustBePositive;
              }

              // Edge Case 5: Çok küçük değer (pratik olmayan)
              if (amount < 0.01) {
                return context.l10n.minPurchasePrice;
              }

              // Edge Case 6: Aşırı yüksek değer (100 milyon TL)
              if (amount > 100000000) {
                return context.l10n.maxPurchasePrice;
              }

              return null;
            },
            decoration: InputDecoration(
              labelText:
                  '${context.l10n.assetPurchasePrice} (${getIt<CurrencyService>().currentSymbol})',
              labelStyle: TextStyle(color: Colors.amber.shade700),
              hintText: 'e.g. 1,250.00',
              hintStyle: const TextStyle(color: Colors.white24),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.05),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Colors.amber.withValues(alpha: 0.5),
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.red.shade400),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
              ),
              prefixIcon: Icon(
                Icons.shopping_cart,
                color: Colors.amber.shade600,
              ),
              suffixIcon: const Icon(
                Icons.edit,
                color: Colors.white38,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

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
              isEditing ? context.l10n.save : context.l10n.addAsset,
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
