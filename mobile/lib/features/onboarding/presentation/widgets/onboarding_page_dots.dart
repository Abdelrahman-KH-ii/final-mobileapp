import 'package:farmtec/core/themes/app_theme_colors.dart';
import 'package:flutter/material.dart';

class OnboardingPageDots extends StatelessWidget {
  const OnboardingPageDots({
    super.key,
    required this.currentPage,
    required this.total,
  });

  final int currentPage;
  final int total;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isDark = context.isDarkTheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (index) {
        final isActive = index == currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 28 : 8,
          height: 8,
          decoration: BoxDecoration(
            color:
                isActive
                    ? colors.iconAccent
                    : colors.outline.withAlpha(isDark ? 120 : 180),
            borderRadius: BorderRadius.circular(100),
          ),
        );
      }),
    );
  }
}
