import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../data/models/asset_model.dart';
import '../widgets/add_asset_sheet.dart';
import '../../../../services/haptic_service.dart';

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
    final dateFormat = DateFormat('dd MMMM yyyy', 'tr_TR');
    final isProfit = asset.profitLoss >= 0;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Varlık Detayı'),
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
              title: 'Alış Bilgileri',
              icon: Icons.calendar_today,
              iconColor: Colors.blue.shade400,
              children: [
                _buildInfoRow(
                  context,
                  'Alış Tarihi',
                  dateFormat.format(asset.purchaseDate),
                  Icons.event,
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  context,
                  'Alış Fiyatı',
                  CurrencyFormatter.format(asset.purchasePrice),
                  Icons.shopping_cart,
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  context,
                  'Miktar',
                  '${asset.quantity} adet',
                  Icons.inventory_2,
                ),
                if (asset.quantity > 1) ...[
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    context,
                    'Birim Alış Fiyatı',
                    CurrencyFormatter.format(asset.unitPurchasePrice),
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
              title: 'Güncel Değer',
              icon: Icons.trending_up,
              iconColor: Colors.green.shade400,
              children: [
                _buildInfoRow(
                  context,
                  'Şuanki Değer',
                  CurrencyFormatter.format(asset.amount),
                  Icons.account_balance_wallet,
                ),
                if (asset.quantity > 1) ...[
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    context,
                    'Birim Güncel Fiyat',
                    CurrencyFormatter.format(asset.unitCurrentPrice),
                    Icons.price_check,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),

            // Kar/Zarar Kartı
            _buildProfitLossCard(context, theme, isProfit),
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
                  '${asset.category}${asset.type != null ? ' • ${asset.type}' : ''}',
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
  ) {
    final profitColor = isProfit ? Colors.green : Colors.red;
    final profitIcon = isProfit ? Icons.trending_up : Icons.trending_down;
    final profitText = isProfit ? 'Kar' : 'Zarar';

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
            '${isProfit ? '+' : ''}${CurrencyFormatter.format(asset.profitLoss)}',
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
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (ctx) => AddAssetSheet(
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
                        // Güncellenmiş varlığı oluştur (alış bilgileri de güncellenebilir)
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
                        onEdit(updatedAsset);
                        Navigator.pop(context); // Detay sayfasını kapat
                      },
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
            label: const Text('Düzenle'),
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
            label: const Text('Sil'),
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
        title: const Text('Varlığı Sil'),
        content: Text(
          '"${asset.name}" varlığını silmek istediğinize emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            style: TextButton.styleFrom(foregroundColor: Colors.white),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx); // Dialog'u kapat
              onDelete(asset);
              Navigator.pop(context); // Detay sayfasını kapat
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sil'),
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
