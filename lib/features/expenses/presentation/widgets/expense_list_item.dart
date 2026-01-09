import 'package:flutter/material.dart';
import 'package:cashly/core/theme/app_theme.dart';
import 'package:cashly/core/constants/color_constants.dart';
import 'package:cashly/core/utils/currency_formatter.dart';
import 'package:cashly/features/payment_methods/data/models/payment_method_model.dart';

/// Tek bir harcama satırı widget'ı
/// Dismissible (kaydırarak silme) ve ödeme yöntemi gösterimi içerir
class ExpenseListItem extends StatelessWidget {
  final Map<String, dynamic> harcama;
  final IconData? categoryIcon;
  final List<PaymentMethod> paymentMethods;
  final int itemIndex;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const ExpenseListItem({
    super.key,
    required this.harcama,
    required this.categoryIcon,
    required this.paymentMethods,
    required this.itemIndex,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // RepaintBoundary: Bu liste öğesinin repaint'ini izole eder
    return RepaintBoundary(
      child: Dismissible(
        key: ValueKey(harcama),
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
        onDismissed: (direction) => onDelete(),
        child: GestureDetector(
          onTap: onTap,
          child: Card(
            color: Theme.of(context).colorScheme.surface,
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
                vertical: 2,
              ),
              leading: _buildCategoryIcon(context),
              title: Text(
                harcama['isim'],
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              trailing: Text(
                "-${CurrencyFormatter.formatWithoutSymbol((harcama['tutar'] as num).toDouble())} ₺",
                style: const TextStyle(
                  color: Colors.red,
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

  Widget _buildCategoryIcon(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        categoryIcon ?? Icons.help,
        color: PageThemeColors.getIconColor(itemIndex),
        size: 20,
      ),
    );
  }
}
