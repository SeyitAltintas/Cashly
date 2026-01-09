import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/asset_model.dart';
import '../../../../core/services/price_service.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/utils/error_handler.dart';
import '../../../../core/utils/amount_input_formatter.dart';
import '../../../../core/widgets/app_date_picker.dart';

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

  const AddAssetPage({super.key, required this.onSave, this.asset});

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

  String _selectedCategory = 'Altın';
  String? _selectedType;
  DateTime _purchaseDate = DateTime.now();

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
    ],
    'Kripto': ['BTC', 'ETH', 'SOL', 'AVAX', 'XRP', 'USDT'],
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

  bool _isLoading = false;
  String? _errorMessage;
  final PriceService _priceService = PriceService();

  @override
  void initState() {
    super.initState();
    if (widget.asset != null) {
      _nameController.text = widget.asset!.name;
      _amountController.text = widget.asset!.amount.toString();
      _quantityController.text = widget.asset!.quantity.toString();
      _selectedCategory = widget.asset!.category;

      final typeFromAsset = widget.asset!.type;
      if (typeFromAsset != null &&
          _types.containsKey(_selectedCategory) &&
          _types[_selectedCategory]!.contains(typeFromAsset)) {
        _selectedType = typeFromAsset;
      } else {
        _selectedType = null;
      }

      _purchaseDate = widget.asset!.purchaseDate;
      _purchasePriceController.text = widget.asset!.purchasePrice.toString();
    } else {
      _quantityController.text = "1";
      _purchaseDate = DateTime.now();
    }
  }

  Future<void> _fetchLivePrice() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

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
        setState(() {
          _isLoading = false;
          if (unitPrice != null) {
            double quantity = double.tryParse(_quantityController.text) ?? 1.0;
            double totalAmount = unitPrice * quantity;
            _amountController.text = totalAmount.toStringAsFixed(2);
            _errorMessage = null;
          } else {
            _errorMessage = 'Fiyat çekilemedi, lütfen manuel giriniz.';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Fiyat alınırken hata oluştu. Lütfen manuel giriniz.';
        });
      }
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    if (_nameController.text.trim().isNotEmpty &&
        _amountController.text.isNotEmpty) {
      final purchasePrice = _purchasePriceController.text.isNotEmpty
          ? double.tryParse(_purchasePriceController.text) ??
                (double.tryParse(_amountController.text) ?? 0.0)
          : double.tryParse(_amountController.text) ?? 0.0;

      widget.onSave(
        _nameController.text.trim(),
        double.tryParse(_amountController.text) ?? 0.0,
        double.tryParse(_quantityController.text) ?? 1.0,
        _selectedCategory,
        _selectedType,
        _purchaseDate,
        purchasePrice,
      );
      if (mounted) Navigator.pop(context);
    } else {
      ErrorHandler.showErrorSnackBar(
        context,
        'Lütfen tüm gerekli alanları doldurun',
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
          isEditing ? "Varlık Düzenle" : "Varlık Ekle",
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
              label: "Varlık Adı",
              hint: "Örn: Gram Altın",
              icon: Icons.diamond_outlined,
              validator: (value) =>
                  Validators.validateItemName(value, itemType: 'Varlık'),
            ),
            const SizedBox(height: 16),

            // Kategori
            _buildCategorySelector(),
            const SizedBox(height: 16),

            // Tür
            if (_types.containsKey(_selectedCategory)) ...[
              _buildTypeSelector(),
              const SizedBox(height: 16),
            ],

            // Adet
            if (_selectedCategory != 'Banka' &&
                _selectedCategory != 'Döviz') ...[
              _buildTextField(
                controller: _quantityController,
                label: "Adet",
                hint: "Örn: 1.0",
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
        const Text(
          "Kategori",
          style: TextStyle(color: Colors.white54, fontSize: 13),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _categories.map((category) {
            final isSelected = _selectedCategory == category;
            return ChoiceChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = category;
                  _selectedType = null;
                  if (_selectedCategory == 'Banka') {
                    _quantityController.text = "1";
                  }
                });
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
          _selectedCategory == 'Banka' ? "Banka Adı" : "Tür",
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
              hint: const Text(
                "Seçiniz",
                style: TextStyle(color: Colors.white38),
              ),
              dropdownColor: const Color(0xFF1E1E1E),
              style: const TextStyle(color: Colors.white, fontSize: 16),
              isExpanded: true,
              icon: const Icon(Icons.expand_more, color: Colors.white38),
              items: _types[_selectedCategory]!.map((String type) {
                return DropdownMenuItem<String>(value: type, child: Text(type));
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedType = value);
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
        const Text(
          "Miktar (TL)",
          style: TextStyle(color: Colors.white54, fontSize: 13),
        ),
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
            if (_selectedCategory != 'Banka') ...[
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
                          "Güncel",
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
                "Alış Bilgileri",
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
                setState(() => _purchaseDate = picked);
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
                      DateFormat('dd MMMM yyyy', 'tr_TR').format(_purchaseDate),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  const Icon(Icons.edit, color: Colors.white38, size: 18),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Alış Fiyatı
          TextFormField(
            controller: _purchasePriceController,
            style: const TextStyle(color: Colors.white),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: "Alış Fiyatı (TL)",
              labelStyle: TextStyle(color: Colors.amber.shade700),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.05),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              prefixIcon: Icon(
                Icons.shopping_cart,
                color: Colors.amber.shade600,
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
              isEditing ? "Güncelle" : "Varlık Ekle",
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
