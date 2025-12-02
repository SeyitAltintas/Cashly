import 'package:flutter/material.dart';
import 'package:cashly/core/constants/color_constants.dart';

import '../../data/models/asset_model.dart';
import 'asset_recycle_bin_page.dart';

class AssetsPage extends StatefulWidget {
  final List<Asset> assets;
  final List<Asset> deletedAssets;
  final Function(Asset) onDelete;
  final Function(Asset) onEdit;
  final Function(Asset) onRestore;
  final Function(Asset) onPermanentDelete;
  final VoidCallback onEmptyBin;

  const AssetsPage({
    super.key,
    required this.assets,
    required this.deletedAssets,
    required this.onDelete,
    required this.onEdit,
    required this.onRestore,
    required this.onPermanentDelete,
    required this.onEmptyBin,
  });

  @override
  State<AssetsPage> createState() => _AssetsPageState();
}

class _AssetsPageState extends State<AssetsPage> {
  // touchedIndex and totalNetWorth removed as they were only used in the removed card

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text("Varlıklarım"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.white),
            tooltip: "Çöp Kutusu",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AssetRecycleBinPage(
                    deletedAssets: widget.deletedAssets,
                    onRestore: widget.onRestore,
                    onPermanentDelete: widget.onPermanentDelete,
                    onEmptyBin: widget.onEmptyBin,
                  ),
                ),
              ).then((_) => setState(() {}));
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // _buildNetWorthCard() removed as per request
            const SizedBox(height: 24),
            _buildAssetList(),
          ],
        ),
      ),
    );
  }

  // _buildNetWorthCard removed

  // _showingSections and _getColor removed

  Widget _buildAssetList() {
    if (widget.assets.isEmpty) {
      return Center(
        child: Text(
          "Henüz varlık eklenmedi.",
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
      itemCount: widget.assets.length,
      itemBuilder: (context, index) {
        final asset = widget.assets[index];
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
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "${asset.amount.toStringAsFixed(2)} ₺",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(
                      Icons.edit,
                      color: Colors.blueAccent,
                      size: 20,
                    ),
                    onPressed: () => widget.onEdit(asset),
                  ),
                ],
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
