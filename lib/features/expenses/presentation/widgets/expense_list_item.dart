import 'package:flutter/material.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/services/currency_service.dart';
import 'package:cashly/core/theme/app_theme.dart';
import 'package:cashly/core/constants/color_constants.dart';
import 'package:cashly/core/utils/currency_formatter.dart';
import 'package:cashly/features/payment_methods/data/models/payment_method_model.dart';
import 'package:cashly/core/extensions/l10n_extensions.dart';

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
                vertical: 4, // Biraz dikey padding artırıldı
              ),
              leading: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Tarih Alanı
                  SizedBox(
                    width: 40, // Sabit genişlik hizalama için
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _getDay(harcama['tarih']),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _getMonth(context, harcama['tarih']),
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
                  _buildCategoryIcon(context),
                ],
              ),
              title: Text(
                context.translateDbName(harcama['isim']),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
              ),
              trailing: Builder(
                builder: (context) {
                  final cur = getIt<CurrencyService>();
                  final t = (harcama['tutar'] as num).toDouble();
                  final pb = harcama['paraBirimi']?.toString() ?? 'TRY';
                  final converted = cur.convert(t, pb, cur.currentCurrency);
                  return Text(
                    CurrencyFormatter.formatSigned(-converted),
                    style: const TextStyle(
                      color: Colors.red,
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

  String _getDay(dynamic dateStr) {
    if (dateStr == null) return "-";
    final date = DateTime.tryParse(dateStr.toString());
    if (date == null) return "-";
    return date.day.toString();
  }

  String _getMonth(BuildContext context, dynamic dateStr) {
    if (dateStr == null) return "-";
    final date = DateTime.tryParse(dateStr.toString());
    if (date == null) return "-";

    switch (date.month) {
      case 1:
        return context.l10n.january.substring(0, 3).toUpperCase();
      case 2:
        return context.l10n.february.substring(0, 3).toUpperCase();
      case 3:
        return context.l10n.march.substring(0, 3).toUpperCase();
      case 4:
        return context.l10n.april.substring(0, 3).toUpperCase();
      case 5:
        return context.l10n.may.substring(0, 3).toUpperCase();
      case 6:
        return context.l10n.june.substring(0, 3).toUpperCase();
      case 7:
        return context.l10n.july.substring(0, 3).toUpperCase();
      case 8:
        return context.l10n.august.substring(0, 3).toUpperCase();
      case 9:
        return context.l10n.september.substring(0, 3).toUpperCase();
      case 10:
        return context.l10n.october.substring(0, 3).toUpperCase();
      case 11:
        return context.l10n.november.substring(0, 3).toUpperCase();
      case 12:
        return context.l10n.december.substring(0, 3).toUpperCase();
      default:
        return "-";
    }
  }
}
