import 'package:farmtec/core/themes/app_theme_colors.dart';
import 'package:farmtec/core/themes/app_fonts.dart';
import 'package:flutter/material.dart';

class OnboardingTagChip extends StatelessWidget {
  const OnboardingTagChip({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isDark = context.isDarkTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? colors.marketUpBg : colors.marketUpBg,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: colors.iconAccent.withAlpha(isDark ? 80 : 120),
        ),
      ),
      child: Text(
        label,
        style: AppFonts.font(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          color: isDark ? colors.marketUpText : colors.iconAccent,
        ),
      ),
    );
  }
}
