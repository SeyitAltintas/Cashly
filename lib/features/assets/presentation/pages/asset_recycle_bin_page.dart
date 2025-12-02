import 'package:flutter/material.dart';
import '../../data/models/asset_model.dart';

class AssetRecycleBinPage extends StatefulWidget {
  final List<Asset> deletedAssets;
  final Function(Asset) onRestore;
  final Function(Asset) onPermanentDelete;
  final VoidCallback onEmptyBin;

  const AssetRecycleBinPage({
    super.key,
    required this.deletedAssets,
    required this.onRestore,
    required this.onPermanentDelete,
    required this.onEmptyBin,
  });

  @override
  State<AssetRecycleBinPage> createState() => _AssetRecycleBinPageState();
}

class _AssetRecycleBinPageState extends State<AssetRecycleBinPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Varlık Çöp Kutusu"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep, color: Colors.white),
            tooltip: "Çöpü Boşalt",
            onPressed: () {
              if (widget.deletedAssets.isEmpty) return;
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: const Color(0xFF1E1E1E),
                  title: const Text(
                    "Çöpü Boşalt",
                    style: TextStyle(color: Colors.white),
                  ),
                  content: const Text(
                    "Tüm silinen varlıklar kalıcı olarak yok edilecek. Emin misin?",
                    style: TextStyle(color: Colors.white70),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text(
                        "İptal",
                        style: TextStyle(color: Colors.white54),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      onPressed: () {
                        widget.onEmptyBin();
                        setState(() {
                          widget.deletedAssets.clear();
                        });
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
      body: widget.deletedAssets.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.delete_outline, size: 64, color: Colors.white24),
                  SizedBox(height: 16),
                  Text(
                    "Çöp kutusu boş.",
                    style: TextStyle(color: Colors.white54),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: widget.deletedAssets.length,
              itemBuilder: (context, index) {
                final asset = widget.deletedAssets[index];
                return Card(
                  color: const Color(0xFF1E1E1E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: Colors.white.withValues(alpha: 0.05),
                    ),
                  ),
                  child: ListTile(
                    leading: const Icon(
                      Icons.monetization_on_outlined,
                      color: Colors.redAccent,
                    ),
                    title: Text(
                      asset.name,
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      "${asset.amount} ₺ • ${asset.category}",
                      style: const TextStyle(color: Colors.white54),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.restore,
                            color: Color(0xFFBB86FC),
                          ),
                          onPressed: () {
                            widget.onRestore(asset);
                            setState(() {
                              widget.deletedAssets.remove(asset);
                            });
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
                            setState(() {
                              widget.deletedAssets.remove(asset);
                            });
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
