import 'package:farmtec/core/l10n/app_localizations.dart';
import 'package:farmtec/core/themes/app_theme_colors.dart';
import 'package:farmtec/core/themes/pallete.dart';
import 'package:farmtec/features/home/presentation/widgets/nav_button.dart';
import 'package:farmtec/features/home/presentation/widgets/nav_item.dart';
import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onIndexChanged,
    this.onChatPressed,
  });

  final int currentIndex;
  final ValueChanged<int> onIndexChanged;
  final VoidCallback? onChatPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isDark = context.isDarkTheme;
    final l = AppLocalizations.of(context);
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final barBg = colors.card;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, bottomPad + 12),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 68,
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
              decoration: BoxDecoration(
                color: barBg,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(isDark ? 50 : 18),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: List.generate(navItems.length, (i) {
                  final item = navItems[i];
                  return Expanded(
                    child: NavButton(
                      item: item,
                      label: l.tr(item.key),
                      isActive: i == currentIndex,
                      isDark: isDark,
                      onTap: () => onIndexChanged(i),
                    ),
                  );
                }),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: onChatPressed,
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: isDark ? Pallete.chartGreen : Pallete.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Pallete.primary.withAlpha(60),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
