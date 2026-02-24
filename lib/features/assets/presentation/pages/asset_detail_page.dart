import 'package:flutter/material.dart';
import 'package:cashly/core/extensions/l10n_extensions.dart';
import 'package:intl/intl.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../data/models/asset_model.dart';
import 'add_asset_page.dart';
import '../../../../core/services/haptic_service.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/services/currency_service.dart';

/// Varlık detay sayfası - Varlığın alış bilgileri ve güncel değerini gösterir
class AssetDetailPage extends StatelessWidget {
  final Asset asset;
  final Function(Asset) onEdit;
  final Function(Asset) onDelete;

  const AssetDetailPage({
    super.key,
    required this.asset,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appLocale = Localizations.localeOf(context).languageCode == 'tr'
        ? 'tr_TR'
        : 'en_US';
    final dateFormat = DateFormat('dd MMMM yyyy', appLocale);
    final isProfit = asset.profitLoss >= 0;
    final cur = getIt<CurrencyService>();
    final targetCurrency = cur.currentCurrency;

    // Kur dönüşümlü tutarlar
    final convertedPurchasePrice = cur.convert(
      asset.purchasePrice,
      asset.paraBirimi,
      targetCurrency,
    );
    final convertedUnitPurchasePrice = cur.convert(
      asset.unitPurchasePrice,
      asset.paraBirimi,
      targetCurrency,
    );
    final convertedAmount = cur.convert(
      asset.amount,
      asset.paraBirimi,
      targetCurrency,
    );
    final convertedUnitCurrentPrice = cur.convert(
      asset.unitCurrentPrice,
      asset.paraBirimi,
      targetCurrency,
    );
    final convertedProfitLoss = cur.convert(
      asset.profitLoss,
      asset.paraBirimi,
      targetCurrency,
    );

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(context.l10n.assetDetail),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Varlık Başlık Kartı
            _buildHeaderCard(context, theme),
            const SizedBox(height: 16),

            // Alış Bilgileri Kartı
            _buildInfoCard(
              context: context,
              theme: theme,
              title: context.l10n.purchaseInfo,
              icon: Icons.calendar_today,
              iconColor: Colors.blue.shade400,
              children: [
                _buildInfoRow(
                  context,
                  context.l10n.assetPurchaseDate,
                  dateFormat.format(asset.purchaseDate),
                  Icons.event,
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  context,
                  context.l10n.assetPurchasePrice,
                  CurrencyFormatter.format(convertedPurchasePrice),
                  Icons.shopping_cart,
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  context,
                  context.l10n.quantityLabel,
                  context.l10n.assetQuantityUnit(asset.quantity.toString()),
                  Icons.inventory_2,
                ),
                if (asset.quantity > 1) ...[
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    context,
                    context.l10n.assetUnitPurchasePrice,
                    CurrencyFormatter.format(convertedUnitPurchasePrice),
                    Icons.price_change,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),

            // Güncel Değer Kartı
            _buildInfoCard(
              context: context,
              theme: theme,
              title: context.l10n.assetCurrentValue,
              icon: Icons.trending_up,
              iconColor: Colors.green.shade400,
              children: [
                _buildInfoRow(
                  context,
                  context.l10n.assetCurrentValue,
                  CurrencyFormatter.format(convertedAmount),
                  Icons.account_balance_wallet,
                ),
                if (asset.quantity > 1) ...[
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    context,
                    context.l10n.assetUnitCurrentPrice,
                    CurrencyFormatter.format(convertedUnitCurrentPrice),
                    Icons.price_check,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),

            // Kar/Zarar Kartı
            _buildProfitLossCard(context, theme, isProfit, convertedProfitLoss),
            const SizedBox(height: 24),

            // Aksiyon Butonları
            _buildActionButtons(context, theme),
          ],
        ),
      ),
    );
  }

  /// Varlık başlık kartı
  Widget _buildHeaderCard(BuildContext context, ThemeData theme) {
    return Container(
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
        border: Border.all(color: Colors.blue.shade600.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: _getColorForCategory(
              asset.category,
            ).withValues(alpha: 0.2),
            child: Icon(
              _getIconForCategory(asset.category),
              color: _getColorForCategory(asset.category),
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  asset.name,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${context.translateDbName(asset.category)}${asset.type != null ? ' • ${context.translateDbName(asset.type!)}' : ''}',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Bilgi kartı oluşturur
  Widget _buildInfoCard({
    required BuildContext context,
    required ThemeData theme,
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  /// Bilgi satırı oluşturur
  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(
          icon,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
          size: 18,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              fontSize: 14,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  /// Kar/Zarar kartı
  Widget _buildProfitLossCard(
    BuildContext context,
    ThemeData theme,
    bool isProfit,
    double convertedProfitLoss,
  ) {
    final profitColor = isProfit ? Colors.green : Colors.red;
    final profitIcon = isProfit ? Icons.trending_up : Icons.trending_down;
    final profitText = isProfit
        ? context.l10n.assetProfitLabel
        : context.l10n.assetLossLabel;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            profitColor.withValues(alpha: 0.2),
            profitColor.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: profitColor.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(profitIcon, color: profitColor, size: 24),
              const SizedBox(width: 8),
              Text(
                profitText,
                style: TextStyle(
                  color: profitColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${isProfit ? '+' : ''}${CurrencyFormatter.format(convertedProfitLoss)}',
            style: TextStyle(
              color: profitColor,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '(${isProfit ? '+' : ''}%${asset.profitLossPercentage.toStringAsFixed(2)})',
            style: TextStyle(
              color: profitColor.withValues(alpha: 0.8),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          // Enflasyon disclaimer
          Text(
            context.l10n.assetInflationDisclaimer,
            style: TextStyle(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              fontSize: 11,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  /// Aksiyon butonları
  Widget _buildActionButtons(BuildContext context, ThemeData theme) {
    return Row(
      children: [
        // Düzenle Butonu
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              HapticService.lightImpact();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (ctx) => AddAssetPage(
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
                          onEdit(updatedAsset);
                          Navigator.pop(context); // Detay sayfasını kapat
                        },
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.edit),
            label: Text(context.l10n.edit),
          ),
        ),
        const SizedBox(width: 12),
        // Sil Butonu
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              HapticService.warning();
              _showDeleteConfirmation(context);
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.delete_outline),
            label: Text(context.l10n.delete),
          ),
        ),
      ],
    );
  }

  /// Silme onay dialogu
  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.deleteAsset),
        content: Text(context.l10n.deleteAssetConfirm(asset.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            style: TextButton.styleFrom(foregroundColor: Colors.white),
            child: Text(context.l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx); // Dialog'u kapat
              onDelete(asset);
              Navigator.pop(context); // Detay sayfasını kapat
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(context.l10n.delete),
          ),
        ],
      ),
    );
  }

  /// Kategori için ikon döndürür
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

  /// Kategori için renk döndürür
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
        return Colors.blue;
    }
  }
}
