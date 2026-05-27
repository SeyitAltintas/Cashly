import 'package:flutter/material.dart';
import 'package:cashly/core/extensions/l10n_extensions.dart';
import '../../../../core/services/haptic_service.dart';
import '../../data/models/income_model.dart';
import 'income_list_item.dart';

class IncomesListView extends StatelessWidget {
  final List<Income> gelirler;
  final bool hasMoreItems;
  final ScrollController scrollController;
  final Future<void> Function() onRefresh;
  final Widget Function() buildLoadingIndicator;
  final Function(Income) onDelete;
  final Function(Income) onEdit;
  final Map<String, IconData> kategoriIkonlari;

  const IncomesListView({
    super.key,
    required this.gelirler,
    required this.hasMoreItems,
    required this.scrollController,
    required this.onRefresh,
    required this.buildLoadingIndicator,
    required this.onDelete,
    required this.onEdit,
    required this.kategoriIkonlari,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: Colors.green,
      child: ListView.builder(
        controller: scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        cacheExtent: 500,
        itemCount: gelirler.length + (hasMoreItems ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= gelirler.length) {
            return buildLoadingIndicator();
          }

          final gelir = gelirler[index];
          return IncomeListItem(
            income: gelir,
            categoryIcon: kategoriIkonlari[gelir.category],
            itemIndex: index,
            onDelete: () => onDelete(gelir),
            onTap: () => onEdit(gelir),
          );
        },
      ),
    );
  }
}
