import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cashly/core/extensions/l10n_extensions.dart';
import '../controllers/expenses_controller.dart';

class ExpensesAppBar extends StatelessWidget implements PreferredSizeWidget {
  final TextEditingController searchController;
  final VoidCallback onSearchChanged;
  final VoidCallback onClearSearch;
  final VoidCallback onGoToToday;

  const ExpensesAppBar({
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
    final aramaModuContext = context.select(
      (ExpensesController c) => c.aramaModu,
    );
    final secilenAyContext = context.select(
      (ExpensesController c) => c.secilenAy,
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
      title: aramaModuContext
          ? TextField(
              controller: searchController,
              autofocus: true,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
              decoration: InputDecoration(
                hintText: context.l10n.searchExpense,
                border: InputBorder.none,
                hintStyle: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.54),
                ),
              ),
              onChanged: (val) => onSearchChanged(),
            )
          : Text(context.l10n.myExpensesTitle),
      actions: [
        if (!aramaModuContext && !buAyMi)
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
            aramaModuContext ? Icons.close : Icons.search,
            color: Colors.white,
          ),
          onPressed: () {
            context.read<ExpensesController>().aramaModu = !aramaModuContext;
            if (!aramaModuContext) {
              onClearSearch();
            }
          },
        ),
      ],
    );
  }
}
