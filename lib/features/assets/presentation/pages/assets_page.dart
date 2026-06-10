// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cashly/core/extensions/l10n_extensions.dart';
import '../../../../core/constants/color_constants.dart';

import '../../data/models/asset_model.dart';
import 'add_asset_page.dart';
import 'asset_recycle_bin_page.dart';
import 'asset_detail_page.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/services/haptic_service.dart';
import '../../../../core/widgets/app_floating_bottom_bar.dart';
import '../../../../core/mixins/lazy_loading_mixin.dart';
import '../../../../core/utils/debouncer.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../widgets/asset_summary_card.dart';
import '../widgets/asset_list_item.dart';
import '../../../../core/di/injection_container.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../../core/services/currency_service.dart';

import '../controllers/assets_controller.dart';
import '../../../../core/utils/error_handler.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../../../core/widgets/app_snackbar.dart';

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
  final DateTime? initialDate;

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
    this.initialDate,
  });

  @override
  State<AssetsPage> createState() => _AssetsPageState();
}

class _AssetsPageState extends State<AssetsPage> with LazyLoadingMixin {
  final TextEditingController _aramaController = TextEditingController();
  // Debouncer - arama performansı için
  final Debouncer _searchDebouncer = Debouncer(
    delay: const Duration(milliseconds: 300),
  );
  // Controller - DI'dan alınır
  late final AssetsController _controller;

  List<Asset> get _deletedAssets => _controller.deletedAssets;

  @override
  void initState() {
    super.initState();

    final authController = getIt<AuthController>();
    final userId = authController.currentUser?.id ?? '';
    _controller = getIt<AssetsController>(param1: userId);

    // Widget prop'larından veriyi controller'a yükle
    _controller.setAssetsFromWidget(widget.assets, widget.deletedAssets);
    initLazyLoading();

    // Kısa bir gecikme ile loading state'i kapat (skeleton gösterimi için)
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _controller.stopLoading();
    });
  }

  // setState kaldırıldı, yerine ListenableBuilder kullanılıyor

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
    _controller.dispose();
    disposeLazyLoading();
    _aramaController.dispose();
    _searchDebouncer.dispose();
    super.dispose();
  }

  double get totalAssets {
    final cur = getIt<CurrencyService>();
    return _controller.filtrelenmisVarliklar.fold(
      0.0,
      (sum, asset) =>
          sum +
          cur.convert(asset.amount, asset.paraBirimi, cur.currentCurrency),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AssetsController>.value(
      value: _controller,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Builder(
            builder: (context) {
              final aramaModuContext = context.select(
                (AssetsController c) => c.aramaModu,
              );

              return AppBar(
                title: aramaModuContext
                    ? TextField(
                        controller: _aramaController,
                        onChanged: (value) =>
                            _searchDebouncer.run(() => _filtrele()),
                        autofocus: true,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        decoration: InputDecoration(
                          hintText: context.l10n.searchAsset,
                          border: InputBorder.none,
                          hintStyle: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                      )
                    : Text(context.l10n.myAssets),
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
                      aramaModuContext ? Icons.close : Icons.search,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    onPressed: () {
                      _controller.aramaModu = !aramaModuContext;
                      if (!aramaModuContext) {
                        _aramaController.clear();
                        _controller.filtrele('');
                      }
                    },
                  ),
                ],
              );
            },
          ),
        ),
        body: Builder(
          builder: (context) {
            final isLoadingContext = context.select(
              (AssetsController c) => c.isLoading,
            );
            final aramaModuContext = context.select(
              (AssetsController c) => c.aramaModu,
            );
            final filtrelenmisVarliklarContext = context.select(
              (AssetsController c) => c.filtrelenmisVarliklar,
            );

            return isLoadingContext
                ? const AssetsPageSkeleton()
                : Column(
                    children: [
                      // Toplam Varlık Kartı - Harcamalarım tarzı tasarım (mavi tema)
                      if (!aramaModuContext)
                        AssetSummaryCard(
                          totalAssets: totalAssets,
                          assetCount: filtrelenmisVarliklarContext.length,
                        ),
                      // Liste veya EmptyState (ekranın kalan kısmının ortasında)
                      Expanded(
                        child: _buildAssetList(
                          filtrelenmisVarliklarContext,
                          aramaModuContext,
                        ),
                      ),
                    ],
                  );
          },
        ),
        // Modern floating bottom navigation bar - Ortak widget kullanımı
        bottomNavigationBar: AppFloatingBottomBar(
          items: [
            BottomBarItem(
              icon: Icons.delete_outline,
              label: context.l10n.trashBin,
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
                ).then((_) {});
              },
            ),
          ],
          centerButtonColor: ColorConstants.maviVurgu,
          centerButtonLabel: context.l10n.addAsset,
          onCenterButtonTap: () {
            HapticService.lightImpact();
            _showAddAssetSheet();
          },
        ),
      ),
    );
  }

  void _showAddAssetSheet() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddAssetPage(
          initialDate: widget.initialDate,
          onSave:
              (
                name,
                amount,
                quantity,
                category,
                type,
                purchaseDate,
                purchasePrice,
                paraBirimi,
              ) async {
                try {
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
                    paraBirimi: paraBirimi,
                  );
                  _controller.addAsset(newAsset);
                  widget.onAdd(name, amount, quantity, category, type);
                } catch (e) {
                  if (!mounted) return;
                  if (e is AppException) {
                    ErrorHandler.handleAppException(context, e);
                  }
                }
              },
        ),
      ),
    );
  }

  Widget _buildAssetList(List<Asset> filtrelenmisVarliklar, bool aramaModu) {
    if (filtrelenmisVarliklar.isEmpty) {
      return aramaModu && _aramaController.text.isNotEmpty
          ? EmptyStateWidget(
              icon: Icons.search_off,
              title: context.l10n.noResultsFound,
              subtitle: context.l10n.tryDifferentSearchTerm,
            )
          : EmptyStateWidget.noAssets(context);
    }
    return RefreshIndicator(
      onRefresh: () async {
        // Verileri sunucudan yeniden çek (Pull to refresh)
        await _controller.loadData(isRefresh: true);
        _filtrele();
      },
      color: ColorConstants.maviVurgu,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        controller: lazyScrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        // cacheExtent: Görünür alan dışında önbelleğe alınacak piksel
        // 500px = yaklaşık 4-5 liste öğesi önden yüklenir
        cacheExtent: 500,
        // itemExtent: Sabit yükseklik → O(1) scroll offset hesabı
        // Asset item 3 satır tarih içerdiğinden 82px kullanılıyor
        itemExtent: 82,
        itemCount: filtrelenmisVarliklar.length + (hasMoreItems ? 1 : 0),
        itemBuilder: (context, index) {
          // Son item ise ve daha fazla veri varsa loading göster
          if (index >= filtrelenmisVarliklar.length) {
            return buildLoadingIndicator();
          }

          final asset = filtrelenmisVarliklar[index];
          // RepaintBoundary ile render izolasyonu - performans optimizasyonu
          return AssetListItem(
            asset: asset,
            onDelete: () {
              _controller.deleteAsset(asset);
              widget.onDelete(asset);

              if (!mounted) return;
              AppSnackBar.deleted(
                context,
                '${asset.name} ${context.l10n.movedToTrash} 🗑️',
                onUndo: () {
                  if (!mounted) return;
                  _controller.restoreAsset(asset);
                  widget.onRestore(asset);
                  AppSnackBar.success(
                    context,
                    '${asset.name} ${context.l10n.restored} ✅',
                  );
                },
              );
            },
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AssetDetailPage(
                    asset: asset,
                    onEdit: (updatedAsset) {
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
                          paraBirimi,
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
                            paraBirimi: paraBirimi,
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
