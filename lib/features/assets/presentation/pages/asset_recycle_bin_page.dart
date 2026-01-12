import 'package:flutter/material.dart';
import '../../data/models/asset_model.dart';
import '../../../settings/presentation/state/recycle_bin_states.dart';

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

class _AssetRecycleBinPageState extends State<AssetRecycleBinPage> {
  late final AssetRecycleBinState _binState;

  List<Asset> get _deletedAssets => _binState.deletedAssets;

  @override
  void initState() {
    super.initState();
    _binState = AssetRecycleBinState();
    _binState.init(widget.deletedAssets);
    _binState.addListener(_onStateChanged);
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _binState.removeListener(_onStateChanged);
    _binState.dispose();
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
          "Tümünü Geri Yükle",
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
        content: Text(
          "${widget.deletedAssets.length} varlık geri yüklenecek. Onaylıyor musun?",
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
              "İptal",
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
            child: const Text(
              "Evet, Geri Yükle",
              style: TextStyle(color: Colors.white),
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
        title: const Text("Varlık Çöp Kutusu"),
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
              tooltip: "Tümünü Geri Yükle",
              onPressed: _confirmRestoreAll,
            ),
          IconButton(
            icon: Icon(
              Icons.delete_sweep,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            tooltip: "Çöpü Boşalt",
            onPressed: () {
              if (_deletedAssets.isEmpty) return;
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  title: Text(
                    "Çöpü Boşalt",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  content: Text(
                    "Tüm silinen varlıklar kalıcı olarak yok edilecek. Emin misin?",
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
                        "İptal",
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
                      child: const Text(
                        "Evet, Sil",
                        style: TextStyle(color: Colors.white),
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
                    "Çöp kutusu boş.",
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
              padding: const EdgeInsets.all(16),
              itemCount: _deletedAssets.length,
              itemBuilder: (context, index) {
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
                          tooltip: "Geri Yükle",
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
                          tooltip: "Kalıcı Sil",
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
