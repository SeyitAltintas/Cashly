import 'package:flutter/material.dart';
import 'package:cashly/core/constants/color_constants.dart';
import 'package:cashly/core/utils/currency_formatter.dart';

import '../../data/models/asset_model.dart';
import '../widgets/add_asset_sheet.dart';
import 'asset_recycle_bin_page.dart';
import 'asset_detail_page.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../services/haptic_service.dart';
import '../../../../core/widgets/app_floating_bottom_bar.dart';
import '../../../../core/mixins/lazy_loading_mixin.dart';

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

class _AssetsPageState extends State<AssetsPage> with LazyLoadingMixin {
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
    initLazyLoading();
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
    disposeLazyLoading();
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
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
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
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
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
      body: Column(
        children: [
          // Toplam Varlık Kartı - Harcamalarım tarzı tasarım (mavi tema)
          if (!_aramaModu)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.blue.shade600.withValues(alpha: 0.25),
                    Colors.blue.shade600.withValues(alpha: 0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.blue.shade600.withValues(alpha: 0.4),
                ),
              ),
              child: Column(
                children: [
                  // Toplam varlık satırı
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Toplam Varlık",
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.7),
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            CurrencyFormatter.format(totalAssets),
                            style: TextStyle(
                              color: Colors.blue.shade400,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade600.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Icon(
                          Icons.diamond_outlined,
                          color: Colors.blue.shade400,
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Varlık sayısı bilgisi
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.account_balance_wallet_outlined,
                          color: Colors.blue.shade400,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Toplam ${_filtrelenmisVarliklar.length} adet varlık kaydı",
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.8),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          // Liste veya EmptyState (ekranın kalan kısmının ortasında)
          Expanded(child: _buildAssetList()),
        ],
      ),
      // Modern floating bottom navigation bar - Ortak widget kullanımı
      bottomNavigationBar: AppFloatingBottomBar(
        items: [
          BottomBarItem(
            icon: Icons.delete_outline,
            label: "Çöp Kutusu",
            onTap: () {
              HapticService.selectionClick();
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
        ],
        centerButtonColor: Colors.blue.shade600,
        centerButtonLabel: "Varlık Ekle",
        onCenterButtonTap: () {
          HapticService.lightImpact();
          _showAddAssetSheet();
        },
      ),
    );
  }

  void _showAddAssetSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddAssetSheet(
        onSave:
            (
              name,
              amount,
              quantity,
              category,
              type,
              purchaseDate,
              purchasePrice,
            ) {
              final newAsset = Asset(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                name: name,
                amount: amount,
                quantity: quantity,
                category: category,
                type: type,
                lastUpdated: DateTime.now(),
                purchaseDate: purchaseDate,
                purchasePrice: purchasePrice,
                isDeleted: false,
              );
              setState(() {
                _assets.add(newAsset);
                _filtrele();
              });
              widget.onAdd(name, amount, quantity, category, type);
            },
      ),
    );
  }

  Widget _buildAssetList() {
    if (_filtrelenmisVarliklar.isEmpty) {
      return _aramaModu && _aramaController.text.isNotEmpty
          ? const EmptyStateWidget(
              icon: Icons.search_off,
              title: 'Sonuç bulunamadı',
              subtitle: 'Farklı bir arama terimi deneyin',
            )
          : EmptyStateWidget.noAssets(
              onAdd: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => AddAssetSheet(
                    onSave:
                        (
                          name,
                          amount,
                          quantity,
                          category,
                          type,
                          purchaseDate,
                          purchasePrice,
                        ) {
                          final newAsset = Asset(
                            id: DateTime.now().millisecondsSinceEpoch
                                .toString(),
                            name: name,
                            amount: amount,
                            quantity: quantity,
                            category: category,
                            type: type,
                            lastUpdated: DateTime.now(),
                            purchaseDate: purchaseDate,
                            purchasePrice: purchasePrice,
                            isDeleted: false,
                          );
                          setState(() {
                            _assets.add(newAsset);
                            _filtrele();
                          });
                          widget.onAdd(name, amount, quantity, category, type);
                        },
                  ),
                );
              },
            );
    }
    return ListView.builder(
      controller: lazyScrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _filtrelenmisVarliklar.length + (hasMoreItems ? 1 : 0),
      itemBuilder: (context, index) {
        // Son item ise ve daha fazla veri varsa loading göster
        if (index >= _filtrelenmisVarliklar.length) {
          return buildLoadingIndicator();
        }

        final asset = _filtrelenmisVarliklar[index];
        // RepaintBoundary ile render izolasyonu - performans optimizasyonu
        return RepaintBoundary(
          child: Dismissible(
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
              HapticService.delete(); // Silme haptic feedback
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
                  // Tek tıkla detay sayfasına git
                  HapticService.selectionClick();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AssetDetailPage(
                        asset: asset,
                        onEdit: (updatedAsset) {
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
                          widget.onEdit(updatedAsset);
                        },
                        onDelete: (deletedAsset) {
                          setState(() {
                            _assets.removeWhere((a) => a.id == deletedAsset.id);
                            deletedAsset.isDeleted = true;
                            _deletedAssets.add(deletedAsset);
                            _filtrele();
                          });
                          widget.onDelete(deletedAsset);
                        },
                      ),
                    ),
                  );
                },
                onLongPress: () {
                  // Basılı tutunca düzenleme sheet'i aç
                  HapticService.mediumImpact();
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => AddAssetSheet(
                      asset: asset,
                      onSave:
                          (
                            name,
                            amount,
                            quantity,
                            category,
                            type,
                            purchaseDate,
                            purchasePrice,
                          ) {
                            // Güncel varlığı oluştur (alış bilgileri de güncellenebilir)
                            final updatedAsset = asset.copyWith(
                              name: name,
                              amount: amount,
                              quantity: quantity,
                              category: category,
                              type: type,
                              lastUpdated: DateTime.now(),
                              purchaseDate: purchaseDate,
                              purchasePrice: purchasePrice,
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
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  "${asset.category}${asset.type != null ? ' • ${asset.type}' : ''}",
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.38),
                    fontSize: 12,
                  ),
                ),
                trailing: Text(
                  CurrencyFormatter.format(asset.amount),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
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
