import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cashly/core/extensions/l10n_extensions.dart';
import '../controllers/incomes_controller.dart';

class IncomesAppBar extends StatelessWidget implements PreferredSizeWidget {
  final TextEditingController searchController;
  final VoidCallback onSearchChanged;
  final VoidCallback onClearSearch;
  final VoidCallback onGoToToday;

  const IncomesAppBar({
    super.key,
    required this.searchController,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.onGoToToday,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final gelirAramaModuContext = context.select(
      (IncomesController c) => c.aramaModu,
    );
    final secilenAyContext = context.select(
      (IncomesController c) => c.secilenAy,
    );
    DateTime simdi = DateTime.now();
    bool buAyMi =
        (secilenAyContext.year == simdi.year &&
        secilenAyContext.month == simdi.month);

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface),
        onPressed: () => Navigator.pop(context),
      ),
      title: gelirAramaModuContext
          ? TextField(
              controller: searchController,
              autofocus: true,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
              decoration: InputDecoration(
                hintText: context.l10n.searchIncome,
                border: InputBorder.none,
                hintStyle: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.54),
                ),
              ),
              onChanged: (val) => onSearchChanged(),
            )
          : Text(context.l10n.myIncomesTitle),
      actions: [
        if (!gelirAramaModuContext && !buAyMi)
          TextButton(
            onPressed: onGoToToday,
            child: Text(
              context.l10n.goToToday,
              style: TextStyle(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
                fontSize: 14,
              ),
            ),
          ),
        IconButton(
          icon: Icon(
            gelirAramaModuContext ? Icons.close : Icons.search,
            color: Colors.white,
          ),
          onPressed: () {
            context.read<IncomesController>().aramaModu =
                !gelirAramaModuContext;
            if (!gelirAramaModuContext) {
              onClearSearch();
            }
          },
        ),
      ],
    );
  }
}
