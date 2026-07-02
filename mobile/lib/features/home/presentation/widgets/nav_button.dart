import 'package:farmtec/core/themes/pallete.dart';
import 'package:farmtec/core/themes/app_fonts.dart';
import 'package:farmtec/features/home/presentation/widgets/nav_item.dart';
import 'package:flutter/material.dart';

class NavButton extends StatelessWidget {
  final NavItem item;
  final String label;
  final bool isActive;
  final bool isDark;
  final VoidCallback onTap;

  const NavButton({
    super.key,
    required this.item,
    required this.label,
    required this.isActive,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = isDark ? Pallete.chartGreen : Pallete.primary;
    final inactiveColor =
        isDark ? Pallete.darkTextSecondary : Pallete.textSecondary;
    final color = isActive ? activeColor : inactiveColor;
    final highlightBg =
        isDark
            ? Pallete.primary.withAlpha(35)
            : const Color(0xFFE8F5E9);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? highlightBg : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? item.activeIcon : item.icon,
              size: 21,
              color: color,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppFonts.font(
                fontSize: 8,
                fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                color: color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
