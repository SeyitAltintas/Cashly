import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/constants/color_constants.dart';
import '../../../../core/services/haptic_service.dart';
import '../../../payment_methods/data/models/payment_method_model.dart';
import 'add_expense_page.dart';

/// Harcama detay sayfası - Harcama bilgilerini gösterir ve düzenleme imkanı sunar
class ExpenseDetailPage extends StatelessWidget {
  final Map<String, dynamic> harcama;
  final IconData? categoryIcon;
  final List<PaymentMethod> paymentMethods;
  final Map<String, IconData> kategoriIkonlari;
  final Function(Map<String, dynamic>) onEdit;
  final Function(Map<String, dynamic>) onDelete;

  const ExpenseDetailPage({
    super.key,
    required this.harcama,
    this.categoryIcon,
    required this.paymentMethods,
    required this.kategoriIkonlari,
    required this.onEdit,
    required this.onDelete,
  });

  // Harcama teması rengi (kırmızı)
  static const Color _accentColor = ColorConstants.kirmiziVurgu;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd MMMM yyyy', 'tr_TR');
    final tarih =
        DateTime.tryParse(harcama['tarih'].toString()) ?? DateTime.now();

    // Ödeme yöntemini bul
    PaymentMethod? pm;
    final paymentMethodId = harcama['odemeYontemiId'];
    if (paymentMethodId != null) {
      pm = paymentMethods.where((p) => p.id == paymentMethodId).firstOrNull;
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Harcama Detayı'),
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
            // Harcama Başlık Kartı
            _buildHeaderCard(context, theme),
            const SizedBox(height: 16),

            // Harcama Bilgileri Kartı
            _buildInfoCard(
              context: context,
              theme: theme,
              title: 'Harcama Bilgileri',
              icon: Icons.receipt_long,
              iconColor: _accentColor,
              children: [
                _buildInfoRow(
                  context,
                  'Tarih',
                  dateFormat.format(tarih),
                  Icons.calendar_today,
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  context,
                  'Kategori',
                  harcama['kategori'] ?? 'Belirtilmemiş',
                  categoryIcon ?? Icons.category,
                ),
                if (pm != null) ...[
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    context,
                    'Ödeme Yöntemi',
                    pm.lastFourDigits != null
                        ? '${pm.name} ****${pm.lastFourDigits}'
                        : pm.name,
                    pm.type == 'nakit'
                        ? Icons.wallet
                        : pm.type == 'kredi'
                        ? Icons.credit_card
                        : Icons.account_balance,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),

            // Tutar Kartı
            _buildAmountCard(context, theme),
            const SizedBox(height: 24),

            // Aksiyon Butonları
            _buildActionButtons(context, theme, pm),
          ],
        ),
      ),
    );
  }

  /// Harcama başlık kartı
  Widget _buildHeaderCard(BuildContext context, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _accentColor.withValues(alpha: 0.25),
            _accentColor.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _accentColor.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: _accentColor.withValues(alpha: 0.2),
            child: Icon(
              categoryIcon ?? Icons.shopping_bag,
              color: _accentColor,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  harcama['isim'] ?? 'Harcama',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  harcama['kategori'] ?? '',
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

  /// Tutar kartı
  Widget _buildAmountCard(BuildContext context, ThemeData theme) {
    final tutar = (harcama['tutar'] as num?)?.toDouble() ?? 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.red.withValues(alpha: 0.2),
            Colors.red.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.payments, color: Colors.red, size: 24),
              const SizedBox(width: 8),
              Text(
                'Harcanan Tutar',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '-${CurrencyFormatter.format(tutar)}',
            style: TextStyle(
              color: Colors.red,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// Aksiyon butonları
  Widget _buildActionButtons(
    BuildContext context,
    ThemeData theme,
    PaymentMethod? pm,
  ) {
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
                  builder: (ctx) => AddExpensePage(
                    expenseToEdit: harcama,
                    categories: kategoriIkonlari,
                    paymentMethods: paymentMethods,
                    onSave: (isim, tutar, kategori, tarih, odemeYontemiId) {
                      // Güncellenmiş harcamayı oluştur
                      final updatedHarcama = Map<String, dynamic>.from(harcama);
                      updatedHarcama['isim'] = isim;
                      updatedHarcama['tutar'] = tutar;
                      updatedHarcama['kategori'] = kategori;
                      updatedHarcama['tarih'] = tarih.toIso8601String();
                      updatedHarcama['odemeYontemiId'] = odemeYontemiId;
                      onEdit(updatedHarcama);
                      Navigator.pop(context); // Detay sayfasını kapat
                    },
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _accentColor,
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
        title: const Text('Harcamayı Sil'),
        content: Text(
          '"${harcama['isim']}" harcamasını silmek istediğinize emin misiniz?',
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
              onDelete(harcama);
              Navigator.pop(context); // Detay sayfasını kapat
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }
}
