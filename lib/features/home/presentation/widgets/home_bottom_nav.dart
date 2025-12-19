import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/theme_manager.dart';

/// Segment tarzı alt navigasyon çubuğu
/// Ana sayfada kullanılır
class HomeBottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onPageChanged;

  const HomeBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDefaultTheme = context.watch<ThemeManager>().isDefaultTheme;
    final primaryColor = isDefaultTheme
        ? const Color(0xFF6C63FF)
        : Theme.of(context).colorScheme.primary;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.surface.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _NavItem(
                  icon: Icons.apps_rounded,
                  label: "Araçlar",
                  index: 0,
                  isSelected: selectedIndex == 0,
                  primaryColor: primaryColor,
                  onTap: onPageChanged,
                ),
                _NavItem(
                  icon: Icons.home_rounded,
                  label: "Ana Sayfa",
                  index: 1,
                  isSelected: selectedIndex == 1,
                  primaryColor: primaryColor,
                  onTap: onPageChanged,
                ),
                _NavItem(
                  icon: Icons.person_rounded,
                  label: "Profil",
                  index: 2,
                  isSelected: selectedIndex == 2,
                  primaryColor: primaryColor,
                  onTap: onPageChanged,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Navigasyon öğesi widget'ı
class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final bool isSelected;
  final Color primaryColor;
  final ValueChanged<int> onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.isSelected,
    required this.primaryColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? primaryColor.withValues(alpha: 0.2)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? primaryColor : Colors.white38,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? primaryColor : Colors.white38,
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
