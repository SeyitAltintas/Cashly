import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cashly/core/theme/theme_manager.dart';
import 'package:cashly/core/constants/color_constants.dart';

import '../../data/models/asset_model.dart';
import '../widgets/add_asset_sheet.dart';
import 'asset_recycle_bin_page.dart';

class AssetsPage extends StatefulWidget {
  final List<Asset> assets;
  final List<Asset> deletedAssets;
  final Function(Asset) onDelete;
  final Function(Asset) onEdit;
  final Function(Asset) onRestore;
  final Function(Asset) onPermanentDelete;
  final VoidCallback onEmptyBin;
  final Function(
    String name,
    double amount,
    double quantity,
    String category,
    String? type,
  )
  onAdd;

  const AssetsPage({
    super.key,
    required this.assets,
    required this.deletedAssets,
    required this.onDelete,
    required this.onEdit,
    required this.onRestore,
    required this.onPermanentDelete,
    required this.onEmptyBin,
    required this.onAdd,
  });

  @override
  State<AssetsPage> createState() => _AssetsPageState();
}

class _AssetsPageState extends State<AssetsPage> {
  bool _aramaModu = false;
  final TextEditingController _aramaController = TextEditingController();
  List<Asset> _assets = [];
  List<Asset> _deletedAssets = [];
  List<Asset> _filtrelenmisVarliklar = [];

  @override
  void initState() {
    super.initState();
    _assets = List.from(widget.assets);
    _deletedAssets = List.from(widget.deletedAssets);
    _filtrelenmisVarliklar = _assets;
  }

  @override
  void didUpdateWidget(covariant AssetsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.assets != oldWidget.assets) {
      _assets = List.from(widget.assets);
      _filtrele();
    }
  }

  void _filtrele() {
    setState(() {
      if (_aramaModu && _aramaController.text.isNotEmpty) {
        String aranan = _aramaController.text.toLowerCase();
        _filtrelenmisVarliklar = _assets.where((asset) {
          return asset.name.toLowerCase().contains(aranan) ||
              asset.category.toLowerCase().contains(aranan) ||
              (asset.type?.toLowerCase().contains(aranan) ?? false);
        }).toList();
      } else {
        _filtrelenmisVarliklar = _assets;
      }
    });
  }

  @override
  void dispose() {
    _aramaController.dispose();
    super.dispose();
  }

  double get totalAssets {
    return _filtrelenmisVarliklar.fold(0.0, (sum, asset) => sum + asset.amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: _aramaModu
            ? TextField(
                controller: _aramaController,
                onChanged: (value) => _filtrele(),
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Varlık ara...",
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              )
            : const Text("Varlıklarım"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.white),
            tooltip: "Çöp Kutusu",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AssetRecycleBinPage(
                    deletedAssets: _deletedAssets,
                    onRestore: (asset) {
                      setState(() {
                        _deletedAssets.removeWhere((a) => a.id == asset.id);
                        asset.isDeleted = false;
                        _assets.add(asset);
                        _filtrele();
                      });
                      widget.onRestore(asset);
                    },
                    onPermanentDelete: (asset) {
                      setState(() {
                        _deletedAssets.removeWhere((a) => a.id == asset.id);
                      });
                      widget.onPermanentDelete(asset);
                    },
                    onEmptyBin: () {
                      setState(() {
                        _deletedAssets.clear();
                      });
                      widget.onEmptyBin();
                    },
                  ),
                ),
              ).then((_) => setState(() {}));
            },
          ),
          IconButton(
            icon: Icon(
              _aramaModu ? Icons.close : Icons.search,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _aramaModu = !_aramaModu;
                if (!_aramaModu) {
                  _aramaController.clear();
                  _filtrelenmisVarliklar = widget.assets;
                }
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Toplam Varlık Kartı
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.2),
                    Theme.of(
                      context,
                    ).colorScheme.secondary.withValues(alpha: 0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Toplam Varlık",
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${totalAssets.toStringAsFixed(2)} ₺",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Icon(
                          Icons.account_balance_wallet,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.account_balance_wallet_outlined,
                          color: Colors.white.withValues(alpha: 0.7),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Toplam ${_filtrelenmisVarliklar.length} adet varlık kaydı",
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            _buildAssetList(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => AddAssetSheet(
              onSave: (name, amount, quantity, category, type) {
                // Lokal listeye ekle
                final newAsset = Asset(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: name,
                  amount: amount,
                  quantity: quantity,
                  category: category,
                  type: type,
                  lastUpdated: DateTime.now(),
                  isDeleted: false,
                );
                setState(() {
                  _assets.add(newAsset);
                  _filtrele();
                });
                // Parent'a da bildir
                widget.onAdd(name, amount, quantity, category, type);
              },
            ),
          );
        },
        backgroundColor: context.watch<ThemeManager>().isDefaultTheme
            ? Theme.of(context).colorScheme.secondary
            : Theme.of(context).colorScheme.primary,
        icon: Icon(
          Icons.add,
          color: context.watch<ThemeManager>().isDefaultTheme
              ? Colors.black
              : Colors.white,
        ),
        label: Text(
          "Varlık Ekle",
          style: TextStyle(
            color: context.watch<ThemeManager>().isDefaultTheme
                ? Colors.black
                : Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildAssetList() {
    if (_filtrelenmisVarliklar.isEmpty) {
      return Center(
        child: Text(
          _aramaModu && _aramaController.text.isNotEmpty
              ? "Sonuç bulunamadı."
              : "Henüz varlık eklenmedi.",
          style: TextStyle(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.54),
          ),
        ),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _filtrelenmisVarliklar.length,
      itemBuilder: (context, index) {
        final asset = _filtrelenmisVarliklar[index];
        return Dismissible(
          key: Key(asset.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: ColorConstants.koyuKirmizi,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (direction) {
            setState(() {
              _assets.removeWhere((a) => a.id == asset.id);
              asset.isDeleted = true;
              _deletedAssets.add(asset);
              _filtrele();
            });
            widget.onDelete(asset);
          },
          child: Card(
            color: Theme.of(context).colorScheme.surface,
            elevation: 0,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.05),
              ),
            ),
            child: ListTile(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => AddAssetSheet(
                    asset: asset,
                    onSave: (name, amount, quantity, category, type) {
                      // Güncel varlığı oluştur
                      final updatedAsset = Asset(
                        id: asset.id,
                        name: name,
                        amount: amount,
                        quantity: quantity,
                        category: category,
                        type: type,
                        lastUpdated: DateTime.now(),
                        isDeleted: false,
                      );
                      // Lokal listeyi güncelle
                      setState(() {
                        final index = _assets.indexWhere(
                          (a) => a.id == asset.id,
                        );
                        if (index != -1) {
                          _assets[index] = updatedAsset;
                        }
                        _filtrele();
                      });
                      // Parent'ı bildir (modal açmadan sadece veri kaydetsin)
                      // Eski asset yerine güncel asset gönder
                      widget.onEdit(updatedAsset);
                    },
                  ),
                );
              },
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              leading: CircleAvatar(
                backgroundColor: _getColorForCategory(
                  asset.category,
                ).withValues(alpha: 0.2),
                child: Icon(
                  _getIconForCategory(asset.category),
                  color: _getColorForCategory(asset.category),
                  size: 20,
                ),
              ),
              title: Text(
                asset.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                "${asset.category}${asset.type != null ? ' • ${asset.type}' : ''}",
                style: const TextStyle(color: Colors.white38, fontSize: 12),
              ),
              trailing: Text(
                "${asset.amount.toStringAsFixed(2)} ₺",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  IconData _getIconForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'altın':
        return Icons.monetization_on;
      case 'döviz':
        return Icons.currency_exchange;
      case 'kripto':
        return Icons.currency_bitcoin;
      case 'banka':
        return Icons.account_balance;
      case 'gümüş':
        return Icons.api;
      default:
        return Icons.savings;
    }
  }

  Color _getColorForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'altın':
        return Colors.amber;
      case 'döviz':
        return Colors.green;
      case 'kripto':
        return Colors.orangeAccent;
      case 'banka':
        return Colors.blueAccent;
      case 'gümüş':
        return Colors.blueGrey;
      default:
        return Theme.of(context).colorScheme.secondary;
    }
  }
}
