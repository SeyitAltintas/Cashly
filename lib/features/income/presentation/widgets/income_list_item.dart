import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/color_constants.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../data/models/income_model.dart';
import '../../../../core/extensions/l10n_extensions.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/services/currency_service.dart';
import '../../../../core/widgets/amount_text.dart';

class IncomeListItem extends StatelessWidget {
  final Income income;
  final IconData? categoryIcon;
  final int itemIndex;
  final bool isFirst;
  final bool isLast;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const IncomeListItem({
    super.key,
    required this.income,
    required this.categoryIcon,
    required this.itemIndex,
    this.isFirst = false,
    this.isLast = false,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Dismissible(
        key: Key(income.id),
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
        onDismissed: (direction) => onDelete(),
        child: GestureDetector(
          onTap: onTap,
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
                  // Tarih Alanı
                  SizedBox(
                    width: 40,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _getDay(income.date),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _getMonth(context, income.date),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
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
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
                  ),
                  const SizedBox(width: 12),
                  // Kategori İkonu
                  _buildCategoryIcon(context),
                ],
              ),
              title: Text(
                context.translateDbName(income.name),
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
                    income.amount,
                    income.paraBirimi,
                    cur.currentCurrency,
                  );
                  return AmountText(
                    CurrencyFormatter.formatSigned(converted, showPlus: true),
                    style: const TextStyle(
                      color: ColorConstants.yesil,
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
        categoryIcon ?? Icons.attach_money,
        color: PageThemeColors.getIconColor(itemIndex),
        size: 20,
      ),
    );
  }

  String _getDay(DateTime date) {
    return date.day.toString();
  }

  String _getMonth(BuildContext context, DateTime date) {
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
