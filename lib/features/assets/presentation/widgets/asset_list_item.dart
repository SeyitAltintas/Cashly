import 'package:flutter/material.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../data/models/asset_model.dart';
import '../../../../core/services/haptic_service.dart';
import '../../../../core/constants/color_constants.dart';
import '../../../../core/widgets/amount_text.dart';
import '../../../../core/extensions/l10n_extensions.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/services/currency_service.dart';

class AssetListItem extends StatelessWidget {
  final Asset asset;
  final VoidCallback onDelete;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final bool isFirst;
  final bool isLast;

  const AssetListItem({
    super.key,
    required this.asset,
    required this.onDelete,
    required this.onTap,
    required this.onLongPress,
    this.isFirst = false,
    this.isLast = false,
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
          margin: EdgeInsets.zero,
          decoration: BoxDecoration(
            color: ColorConstants.koyuKirmizi,
            borderRadius: BorderRadius.vertical(
              top: isFirst ? const Radius.circular(16) : Radius.zero,
              bottom: isLast ? const Radius.circular(16) : Radius.zero,
            ),
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
          child: Container(
            margin: EdgeInsets.zero,
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.light
                  ? const Color(0xFFF8F9FA)
                  : Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.vertical(
                top: isFirst ? const Radius.circular(16) : Radius.zero,
                bottom: isLast ? const Radius.circular(16) : Radius.zero,
              ),
              border: Border(
                top: isFirst
                    ? BorderSide(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.06))
                    : BorderSide.none,
                bottom: BorderSide(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.06)),
                left: BorderSide(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.06)),
                right: BorderSide(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.06)),
              ),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 4,
              ),
              leading: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Tarih Alanı (Alış Tarihi)
                  SizedBox(
                    width: 40,
                    child: MediaQuery(
                      data: MediaQuery.of(
                        context,
                      ).copyWith(textScaler: TextScaler.noScaling),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _getDay(asset.purchaseDate),
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                          ),
                          Text(
                            context.getShortMonthName(asset.purchaseDate.month),
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.7),
                              fontSize: 10,
                              height: 1.2,
                            ),
                          ),
                          Text(
                            _getYear(asset.purchaseDate),
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.5),
                              fontSize: 10,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Dikey Ayrac
                  Container(
                    width: 1,
                    height: 35,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.2),
                  ),
                  const SizedBox(width: 12),
                  // Kategori İkonu
                  _buildCategoryIcon(context, asset.category),
                ],
              ),
              title: Text(
                asset.name,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
              ),
              trailing: Builder(
                builder: (context) {
                  final cur = getIt<CurrencyService>();
                  final converted = cur.convert(
                    asset.amount,
                    asset.paraBirimi,
                    cur.currentCurrency,
                  );
                  return AmountText(
                    CurrencyFormatter.format(
                      converted,
                      currency: cur.currentCurrency,
                    ),
                    style: const TextStyle(
                      color: ColorConstants.maviVurgu,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  );
                },
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

  String _getYear(DateTime date) {
    return date.year.toString();
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
        return ColorConstants.amber;
      case 'döviz':
        return ColorConstants.yesil;
      case 'kripto':
        return ColorConstants.turuncuVurgu;
      case 'banka':
        return ColorConstants.maviVurgu;
      case 'gümüş':
        return ColorConstants.maviGri;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }
}
