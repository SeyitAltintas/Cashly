import 'package:flutter/material.dart';

import '../../data/models/asset_model.dart';
import 'add_asset_page.dart';
import 'asset_recycle_bin_page.dart';
import 'asset_detail_page.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/services/haptic_service.dart';
import '../../../../core/widgets/app_floating_bottom_bar.dart';
import '../../../../core/mixins/lazy_loading_mixin.dart';
import '../widgets/asset_summary_card.dart';
import '../widgets/asset_list_item.dart';

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
            // Toplam Varlık Kartı
            if (!_aramaModu)
              AssetSummaryCard(
                totalAssets: totalAssets,
                assetCount: _filtrelenmisVarliklar.length,
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
              ).then((_) {
                if (mounted) setState(() {});
              });
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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddAssetPage(
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
          : EmptyStateWidget.noAssets();
    }
    return RefreshIndicator(
      onRefresh: () async {
        // Verileri yeniden filtrele
        _filtrele();
      },
      color: Colors.blue.shade600,
      child: ListView.builder(
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
          return AssetListItem(
            asset: asset,
            onDelete: () {
              setState(() {
                _assets.removeWhere((a) => a.id == asset.id);
                asset.isDeleted = true;
                _deletedAssets.add(asset);
                _filtrele();
              });
              widget.onDelete(asset);
            },
            onTap: () {
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
              HapticService.mediumImpact();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddAssetPage(
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
                ),
              );
            },
          );
        },
      ),
    );
  }
}
