import 'package:flutter/material.dart';
import 'package:cashly/core/extensions/l10n_extensions.dart';
import '../../../../core/constants/color_constants.dart';
import '../../../../core/constants/icon_constants.dart';
import '../../../../core/services/haptic_service.dart';
import '../pages/expense_detail_page.dart';
import 'expense_list_item.dart';
import '../../../payment_methods/data/models/payment_method_model.dart';

class ExpensesListView extends StatelessWidget {
  final Map<String, List<Map<String, dynamic>>> gruplar;
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
    required this.gruplar,
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
      child: ListView.builder(
        controller: scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        cacheExtent: 500,
        itemCount: gruplar.keys.length + (hasMoreItems ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= gruplar.keys.length) {
            return buildLoadingIndicator();
          }

          String gunBasligi = gruplar.keys.elementAt(index);
          List<Map<String, dynamic>> harcamalar = gruplar[gunBasligi]!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...harcamalar.map((harcama) {
                return ExpenseListItem(
                  harcama: harcama,
                  categoryIcon: kategoriIkonlari[harcama['kategori']] ??
                      IconConstants.getIconFromCategoryName(harcama['kategori']),
                  paymentMethods: tumOdemeYontemleri,
                  itemIndex: gosterilenHarcamalar.indexOf(harcama),
                  onDelete: () => onDelete(harcama),
                  onTap: () {
                    HapticService.selectionClick();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (ctx) => ExpenseDetailPage(
                          harcama: harcama,
                          categoryIcon: kategoriIkonlari[harcama['kategori']] ??
                              IconConstants.getIconFromCategoryName(harcama['kategori']),
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
              }),
            ],
          );
        },
      ),
    );
  }
}
