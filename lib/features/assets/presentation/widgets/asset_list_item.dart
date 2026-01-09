import 'package:flutter/material.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../data/models/asset_model.dart';
import '../../../../core/services/haptic_service.dart';
import '../../../../core/constants/color_constants.dart';

class AssetListItem extends StatelessWidget {
  final Asset asset;
  final VoidCallback onDelete;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const AssetListItem({
    super.key,
    required this.asset,
    required this.onDelete,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Dismissible(
        key: Key(asset.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: ColorConstants.koyuKirmizi,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.delete, color: Colors.white),
        ),
        onDismissed: (direction) {
          HapticService.delete();
          onDelete();
        },
        child: GestureDetector(
          onLongPress: onLongPress,
          onTap: () {
            HapticService.selectionClick();
            onTap();
          },
          child: Card(
            color: const Color.fromARGB(255, 6, 6, 6),
            elevation: 0,
            margin: const EdgeInsets.only(bottom: 6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.05),
              ),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 4,
              ),
              leading: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Tarih Alanı (Alış Tarihi)
                  SizedBox(
                    width: 40,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _getDay(asset.purchaseDate),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _getMonth(asset.purchaseDate),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Dikey Ayrac
                  Container(
                    width: 1,
                    height: 35,
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                  const SizedBox(width: 12),
                  // Kategori İkonu
                  _buildCategoryIcon(context, asset.category),
                ],
              ),
              title: Text(
                asset.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
              ),
              trailing: Text(
                CurrencyFormatter.format(asset.amount),
                style: const TextStyle(
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryIcon(BuildContext context, String category) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: _getColorForCategory(context, category).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        _getIconForCategory(category),
        color: _getColorForCategory(context, category),
        size: 20,
      ),
    );
  }

  String _getDay(DateTime date) {
    return date.day.toString();
  }

  String _getMonth(DateTime date) {
    const months = [
      "OCA",
      "ŞUB",
      "MAR",
      "NİS",
      "MAY",
      "HAZ",
      "TEM",
      "AĞU",
      "EYL",
      "EKİ",
      "KAS",
      "ARA",
    ];
    return months[date.month - 1];
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

  Color _getColorForCategory(BuildContext context, String category) {
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
