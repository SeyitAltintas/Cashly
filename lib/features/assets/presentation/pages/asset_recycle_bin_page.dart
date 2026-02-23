import 'package:flutter/material.dart';
import 'package:cashly/core/extensions/l10n_extensions.dart';
import '../../data/models/asset_model.dart';
import '../../../settings/presentation/state/recycle_bin_states.dart';
import '../../../../core/mixins/lazy_loading_mixin.dart';

class AssetRecycleBinPage extends StatefulWidget {
  final List<Asset> deletedAssets;
  final Function(Asset) onRestore;
  final Function(Asset) onPermanentDelete;
  final VoidCallback onEmptyBin;
  final VoidCallback? onRestoreAll;

  const AssetRecycleBinPage({
    super.key,
    required this.deletedAssets,
    required this.onRestore,
    required this.onPermanentDelete,
    required this.onEmptyBin,
    this.onRestoreAll,
  });

  @override
  State<AssetRecycleBinPage> createState() => _AssetRecycleBinPageState();
}

class _AssetRecycleBinPageState extends State<AssetRecycleBinPage>
    with LazyLoadingMixin {
  late final AssetRecycleBinState _binState;

  List<Asset> get _deletedAssets => _binState.deletedAssets;

  @override
  void initState() {
    super.initState();
    _binState = AssetRecycleBinState();
    _binState.init(widget.deletedAssets);
    _binState.addListener(_onStateChanged);
    initLazyLoading();
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _binState.removeListener(_onStateChanged);
    _binState.dispose();
    disposeLazyLoading();
    super.dispose();
  }

  /// Tüm silinen varlıkları geri yükler
  void _confirmRestoreAll() {
    if (widget.deletedAssets.isEmpty) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          context.l10n.restoreAll,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
        content: Text(
          context.l10n.confirmRestoreAllAssets(widget.deletedAssets.length),
          style: TextStyle(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              context.l10n.cancel,
              style: TextStyle(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.54),
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade700,
            ),
            onPressed: () {
              // Tüm varlıkları tek tek geri yükle
              final assetsToRestore = List<Asset>.from(widget.deletedAssets);
              for (var asset in assetsToRestore) {
                widget.onRestore(asset);
              }
              _binState.clearBin();
              Navigator.pop(ctx);
              if (widget.onRestoreAll != null) {
                widget.onRestoreAll!();
              }
            },
            child: Text(
              context.l10n.yesRestore,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.assetRecycleBin),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.onSurface,
        ),
        actions: [
          if (_deletedAssets.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.restore, color: Colors.green),
              tooltip: context.l10n.restoreAll,
              onPressed: _confirmRestoreAll,
            ),
          IconButton(
            icon: Icon(
              Icons.delete_sweep,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            tooltip: context.l10n.emptyTrashBin,
            onPressed: () {
              if (_deletedAssets.isEmpty) return;
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  title: Text(
                    context.l10n.emptyTrashBin,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  content: Text(
                    context.l10n.confirmEmptyTrashBin,
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text(
                        context.l10n.cancel,
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.54),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade800,
                      ),
                      onPressed: () {
                        widget.onEmptyBin();
                        _binState.clearBin();
                        Navigator.pop(ctx);
                        Navigator.pop(context); // Sayfadan çık
                      },
                      child: Text(
                        context.l10n.yesDelete,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: _deletedAssets.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.delete_outline,
                    size: 64,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.24),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    context.l10n.noDeletedAssets,
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.54),
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              controller: lazyScrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _deletedAssets.length + (hasMoreItems ? 1 : 0),
              itemBuilder: (context, index) {
                // Son item ise ve daha fazla veri varsa loading göster
                if (index >= _deletedAssets.length) {
                  return buildLoadingIndicator();
                }
                final asset = _deletedAssets[index];
                return Card(
                  color: const Color(0xFF1E1E1E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.05),
                    ),
                  ),
                  child: ListTile(
                    leading: const Icon(
                      Icons.monetization_on_outlined,
                      color: Colors.redAccent,
                    ),
                    title: Text(
                      asset.name,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    subtitle: Text(
                      "${asset.amount} ₺ • ${asset.category}",
                      style: TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.54),
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.restore,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          onPressed: () {
                            widget.onRestore(asset);
                            _binState.removeAsset(asset);
                          },
                          tooltip: context.l10n.restoreItem,
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_forever,
                            color: Colors.redAccent,
                          ),
                          onPressed: () {
                            widget.onPermanentDelete(asset);
                            _binState.removeAsset(asset);
                          },
                          tooltip: context.l10n.deletePermanently,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
