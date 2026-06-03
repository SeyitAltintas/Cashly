import 'package:flutter/material.dart';

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
      child: CustomScrollView(
        controller: scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        cacheExtent: 500,
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
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
                childCount: gelirler.length + (hasMoreItems ? 1 : 0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
