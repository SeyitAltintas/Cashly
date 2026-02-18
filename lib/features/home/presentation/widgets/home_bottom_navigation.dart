import 'package:flutter/material.dart';
import 'package:cashly/core/extensions/l10n_extensions.dart';

/// Alt navigasyon çubuğu widget'ı.
/// Harcamalar, Gelirler, Tüm İşlemler ve Profil sayfaları arasında geçiş sağlar.
class HomeBottomNavigation extends StatelessWidget {
  final int selectedIndex;
  final PageController pageController;

  const HomeBottomNavigation({
    super.key,
    required this.selectedIndex,
    required this.pageController,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: Theme.of(context).colorScheme.surface,
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Harcamalarım
            IconButton(
              icon: Icon(
                Icons.receipt_long,
                color: selectedIndex == 0
                    ? Theme.of(context).colorScheme.secondary
                    : Colors.white24,
                size: 28,
              ),
              onPressed: () => pageController.jumpToPage(0),
              tooltip: context.l10n.myExpenses,
            ),
            // Gelirlerim
            IconButton(
              icon: Icon(
                Icons.trending_up,
                color: selectedIndex == 1
                    ? Theme.of(context).colorScheme.secondary
                    : Colors.white24,
                size: 28,
              ),
              onPressed: () => pageController.jumpToPage(1),
              tooltip: context.l10n.myIncomes,
            ),
            // Ortadaki FAB boşluğu
            const SizedBox(width: 48),
            // Tüm İşlemler
            IconButton(
              icon: Icon(
                Icons.apps_rounded,
                color: selectedIndex == 2
                    ? Theme.of(context).colorScheme.secondary
                    : Colors.white24,
                size: 28,
              ),
              onPressed: () => pageController.jumpToPage(2),
              tooltip: context.l10n.allTransactions,
            ),
            // Profil
            IconButton(
              icon: Icon(
                Icons.person_outline,
                color: selectedIndex == 3
                    ? Theme.of(context).colorScheme.secondary
                    : Colors.white24,
                size: 28,
              ),
              onPressed: () => pageController.jumpToPage(3),
              tooltip: context.l10n.profile,
            ),
          ],
        ),
      ),
    );
  }
}
