import 'package:flutter/material.dart';

/// Bottom bar öğesi modeli
class BottomBarItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const BottomBarItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}

/// Yeniden kullanılabilir floating bottom navigation bar
/// expenses_page, incomes_page ve assets_page'de ortak kullanılır
class AppFloatingBottomBar extends StatelessWidget {
  /// Sol ve sağ taraftaki navigation butonları
  final List<BottomBarItem> items;

  /// Ortadaki ana buton (opsiyonel)
  /// Varsayılan olarak yuvarlak add butonu
  final Widget? centerButton;

  /// Ortadaki butonun rengi (centerButton null ise kullanılır)
  final Color? centerButtonColor;

  /// Ortadaki butona tıklama callback'i (centerButton null ise kullanılır)
  final VoidCallback? onCenterButtonTap;

  /// Ortadaki butonun ikonu (centerButton null ise kullanılır)
  final IconData centerButtonIcon;

  /// Ortadaki butonun etiketi (opsiyonel, null ise sadece ikon gösterilir)
  final String? centerButtonLabel;

  const AppFloatingBottomBar({
    super.key,
    required this.items,
    this.centerButton,
    this.centerButtonColor,
    this.onCenterButtonTap,
    this.centerButtonIcon = Icons.add,
    this.centerButtonLabel,
  });

  @override
  Widget build(BuildContext context) {
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
          children: _buildChildren(context),
        ),
      ),
    );
  }

  List<Widget> _buildChildren(BuildContext context) {
    final List<Widget> children = [];

    // Sol taraftaki öğeler (ilk yarı)
    final leftItems = items.take((items.length / 2).ceil()).toList();
    for (final item in leftItems) {
      children.add(_buildNavButton(context, item));
    }

    // Ortadaki buton
    if (centerButton != null) {
      children.add(centerButton!);
    } else if (onCenterButtonTap != null) {
      children.add(_buildCenterButton(context));
    }

    // Sağ taraftaki öğeler (ikinci yarı)
    final rightItems = items.skip((items.length / 2).ceil()).toList();
    for (final item in rightItems) {
      children.add(_buildNavButton(context, item));
    }

    return children;
  }

  Widget _buildNavButton(BuildContext context, BottomBarItem item) {
    return GestureDetector(
      onTap: item.onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              item.icon,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              item.label,
              style: TextStyle(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.5),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterButton(BuildContext context) {
    final color = centerButtonColor ?? Theme.of(context).colorScheme.primary;

    // Etiketli buton (assets_page tarzı)
    if (centerButtonLabel != null) {
      return GestureDetector(
        onTap: onCenterButtonTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(centerButtonIcon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                centerButtonLabel!,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Yuvarlak buton (expenses_page tarzı)
    return GestureDetector(
      onTap: onCenterButtonTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(centerButtonIcon, color: Colors.white, size: 28),
      ),
    );
  }
}
