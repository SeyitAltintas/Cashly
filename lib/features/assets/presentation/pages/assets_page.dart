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
import '../../../../core/di/injection_container.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import 'package:provider/provider.dart';
import '../controllers/assets_controller.dart';

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
  final TextEditingController _aramaController = TextEditingController();
  // Controller - DI'dan alınır
  late final AssetsController _controller;

  // Getter'lar
  bool get _aramaModu => _controller.aramaModu;
  List<Asset> get _deletedAssets => _controller.deletedAssets;
  List<Asset> get _filtrelenmisVarliklar => _controller.filtrelenmisVarliklar;

  @override
  void initState() {
    super.initState();

    final authController = Provider.of<AuthController>(context, listen: false);
    final userId = authController.currentUser?.id ?? '';
    _controller = getIt<AssetsController>(param1: userId);
    _controller.addListener(_onStateChanged);

    // Widget prop'larından veriyi controller'a yükle
    _controller.setAssetsFromWidget(widget.assets, widget.deletedAssets);
    initLazyLoading();
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  @override
  void didUpdateWidget(covariant AssetsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.assets != oldWidget.assets) {
      _controller.assets = List.from(widget.assets);
      _controller.filtrele(_aramaController.text);
    }
  }

  void _filtrele() {
    _controller.filtrele(_aramaController.text);
  }

  @override
  void dispose() {
    _controller.removeListener(_onStateChanged);
    _controller.dispose();
    disposeLazyLoading();
    _aramaController.dispose();
    super.dispose();
  }

  double get totalAssets {
    return _controller.filtrelenmisVarliklar.fold(
      0.0,
      (sum, asset) => sum + asset.amount,
    );
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
              _controller.aramaModu = !_aramaModu;
              if (!_controller.aramaModu) {
                _aramaController.clear();
                _controller.filtrele('');
              }
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
                      _controller.restoreAsset(asset);
                      widget.onRestore(asset);
                    },
                    onPermanentDelete: (asset) {
                      _controller.permanentDeleteAsset(asset);
                      widget.onPermanentDelete(asset);
                    },
                    onEmptyBin: () {
                      _controller.emptyBin();
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
                _controller.addAsset(newAsset);
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
              _controller.deleteAsset(asset);
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
                      _controller.updateAsset(updatedAsset);
                      widget.onEdit(updatedAsset);
                    },
                    onDelete: (deletedAsset) {
                      _controller.deleteAsset(deletedAsset);
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
                          _controller.updateAsset(updatedAsset);
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
