import 'package:flutter/material.dart';

import '../../../../core/constants/color_constants.dart';
import '../../../../core/constants/icon_constants.dart';
import '../../../../core/services/haptic_service.dart';
import '../pages/expense_detail_page.dart';
import 'expense_list_item.dart';
import '../../../payment_methods/data/models/payment_method_model.dart';

class ExpensesListView extends StatelessWidget {
  final bool hasMoreItems;
  final ScrollController scrollController;
  final Future<void> Function() onRefresh;
  final Widget Function() buildLoadingIndicator;
  final Function(Map<String, dynamic>) onDelete;
  final Function(Map<String, dynamic>, Map<String, dynamic>) onEdit;
  final Map<String, IconData> kategoriIkonlari;
  final List<PaymentMethod> tumOdemeYontemleri;
  final List<Map<String, dynamic>> gosterilenHarcamalar;

  const ExpensesListView({
    super.key,
    required this.hasMoreItems,
    required this.scrollController,
    required this.onRefresh,
    required this.buildLoadingIndicator,
    required this.onDelete,
    required this.onEdit,
    required this.kategoriIkonlari,
    required this.tumOdemeYontemleri,
    required this.gosterilenHarcamalar,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: ColorConstants.kirmiziVurgu,
      child: CustomScrollView(
        controller: scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        cacheExtent: 500,
        slivers: [
          // Normal expense items — sabit yükseklik ile O(1) scroll offset hesabı
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            sliver: SliverFixedExtentList(
              itemExtent: 72, // Card + ListTile(vertical:4) + margin(bottom:6)
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index >= gosterilenHarcamalar.length) return null;

                  final harcama = gosterilenHarcamalar[index];

                  return ExpenseListItem(
                    harcama: harcama,
                    categoryIcon:
                        kategoriIkonlari[harcama['kategori']] ??
                        IconConstants.getIconFromCategoryName(
                          harcama['kategori'],
                        ),
                    paymentMethods: tumOdemeYontemleri,
                    itemIndex: index,
                    onDelete: () => onDelete(harcama),
                    onTap: () {
                      HapticService.selectionClick();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (ctx) => ExpenseDetailPage(
                            harcama: harcama,
                            categoryIcon:
                                kategoriIkonlari[harcama['kategori']] ??
                                IconConstants.getIconFromCategoryName(
                                  harcama['kategori'],
                                ),
                            paymentMethods: tumOdemeYontemleri,
                            kategoriIkonlari: kategoriIkonlari,
                            onEdit: (updatedHarcama) {
                              onEdit(harcama, updatedHarcama);
                            },
                            onDelete: (deletedHarcama) {
                              onDelete(deletedHarcama);
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
                childCount: gosterilenHarcamalar.length,
              ),
            ),
          ),
          // Lazy loading indikatörü (farklı yükseklikte olduğu için ayrı sliver)
          if (hasMoreItems)
            SliverToBoxAdapter(child: buildLoadingIndicator()),
        ],
      ),
    );
  }
}
