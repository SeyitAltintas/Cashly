import 'package:flutter/material.dart';

/// Alt navigasyon çubuğu widget'ı.
/// Harcamalar, Gelirler, Araçlar ve Profil sayfaları arasında geçiş sağlar.
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
              tooltip: "Harcamalarım",
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
              tooltip: "Gelirlerim",
            ),
            // Ortadaki FAB boşluğu
            const SizedBox(width: 48),
            // Araçlar
            IconButton(
              icon: Icon(
                Icons.build_outlined,
                color: selectedIndex == 2
                    ? Theme.of(context).colorScheme.secondary
                    : Colors.white24,
                size: 28,
              ),
              onPressed: () => pageController.jumpToPage(2),
              tooltip: "Araçlar",
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
              tooltip: "Profil",
            ),
          ],
        ),
      ),
    );
  }
}
