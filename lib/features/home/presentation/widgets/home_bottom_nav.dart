import 'package:flutter/material.dart';
import '../../../../services/haptic_service.dart';

/// Modern floating bottom navigation bar
/// Pill şekilli seçim göstergesi ve animasyonlar
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
    const primaryColor = Color(0xFF6C63FF);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(35),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, 5),
              spreadRadius: -5,
            ),
          ],
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.08),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _ModernNavItem(
              icon: Icons.grid_view_rounded,
              label: "İşlemler",
              isSelected: selectedIndex == 0,
              primaryColor: primaryColor,
              onTap: () {
                HapticService.selectionClick();
                onPageChanged(0);
              },
            ),
            _ModernNavItem(
              icon: Icons.home_rounded,
              label: "Ana Sayfa",
              isSelected: selectedIndex == 1,
              primaryColor: primaryColor,
              isCenter: true,
              onTap: () {
                HapticService.selectionClick();
                onPageChanged(1);
              },
            ),
            _ModernNavItem(
              icon: Icons.person_outline_rounded,
              label: "Profil",
              isSelected: selectedIndex == 2,
              primaryColor: primaryColor,
              onTap: () {
                HapticService.selectionClick();
                onPageChanged(2);
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Modern nav item with pill indicator
class _ModernNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final Color primaryColor;
  final VoidCallback onTap;
  final bool isCenter;

  const _ModernNavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.primaryColor,
    required this.onTap,
    this.isCenter = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 20 : 16,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              child: Icon(
                icon,
                color: isSelected
                    ? primaryColor
                    : Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.4),
                size: isSelected ? 26 : 24,
              ),
            ),
            // Label sadece seçili olduğunda görünür
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              child: isSelected
                  ? Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Text(
                        label,
                        style: TextStyle(
                          color: primaryColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
