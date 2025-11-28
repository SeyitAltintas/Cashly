import 'package:flutter/material.dart';
import '../../data/models/asset_model.dart';
import '../../../../core/services/price_service.dart';

class AddAssetSheet extends StatefulWidget {
  final Function(
    String name,
    double amount,
    double quantity,
    String category,
    String? type,
  )
  onSave;
  final Asset? asset;

  const AddAssetSheet({super.key, required this.onSave, this.asset});

  @override
  State<AddAssetSheet> createState() => _AddAssetSheetState();
}

class _AddAssetSheetState extends State<AddAssetSheet> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  String _selectedCategory = 'Altın';
  String? _selectedType;

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
  final PriceService _priceService = PriceService();

  @override
  void initState() {
    super.initState();
    if (widget.asset != null) {
      _nameController.text = widget.asset!.name;
      _amountController.text = widget.asset!.amount.toString();
      _quantityController.text = widget.asset!.quantity.toString();
      _selectedCategory = widget.asset!.category;
      _selectedType = widget.asset!.type;
    } else {
      _quantityController.text = "1";
    }
  }

  Future<void> _fetchLivePrice() async {
    setState(() {
      _isLoading = true;
    });

    double? unitPrice;

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
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Fiyat çekilemedi, lütfen manuel giriniz."),
            ),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
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
              widget.asset != null ? "Varlık Düzenle" : "Varlık Ekle",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // 1. Varlık Adı
            TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Varlık Adı",
                labelStyle: const TextStyle(color: Colors.white70),
                hintText: "Örn: Gram Altın",
                hintStyle: const TextStyle(color: Colors.white24),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.edit, color: Color(0xFF9D00FF)),
              ),
            ),
            const SizedBox(height: 16),

            // 2. Kategori
            const Text(
              "Kategori",
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
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
                  selectedColor: const Color(0xFF9D00FF),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.white70,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
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

            // 3. Tür
            if (_types.containsKey(_selectedCategory)) ...[
              const SizedBox(height: 16),
              Text(
                _selectedCategory == 'Banka' ? "Banka Adı" : "Tür",
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedType,
                    hint: const Text(
                      "Seçiniz",
                      style: TextStyle(color: Colors.white54),
                    ),
                    dropdownColor: const Color(0xFF2C2C2C),
                    style: const TextStyle(color: Colors.white),
                    isExpanded: true,
                    items: _types[_selectedCategory]!.map((String type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedType = value;
                      });
                    },
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),

            // 4. Adet
            if (_selectedCategory != 'Banka' &&
                _selectedCategory != 'Döviz') ...[
              TextField(
                controller: _quantityController,
                style: const TextStyle(color: Colors.white),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: "Adet",
                  labelStyle: const TextStyle(color: Colors.white70),
                  hintText: "Örn: 1.0",
                  hintStyle: const TextStyle(color: Colors.white24),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(
                    Icons.numbers,
                    color: Color(0xFF9D00FF),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // 5. Miktar (TL) + Güncel Butonu
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _amountController,
                    style: const TextStyle(color: Colors.white),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: "Miktar (TL)",
                      labelStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.05),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(
                        Icons.currency_lira,
                        color: Color(0xFF9D00FF),
                      ),
                    ),
                  ),
                ),
                if (_selectedCategory != 'Banka') ...[
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: _isLoading ? null : _fetchLivePrice,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF9D00FF).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF9D00FF).withValues(alpha: 0.3),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFF9D00FF),
                              ),
                            )
                          : const Text(
                              "Güncel",
                              style: TextStyle(
                                color: Color(0xFF9D00FF),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  if (_nameController.text.isNotEmpty &&
                      _amountController.text.isNotEmpty) {
                    widget.onSave(
                      _nameController.text,
                      double.tryParse(_amountController.text) ?? 0.0,
                      double.tryParse(_quantityController.text) ?? 1.0,
                      _selectedCategory,
                      _selectedType,
                    );
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9D00FF),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  "Kaydet",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
