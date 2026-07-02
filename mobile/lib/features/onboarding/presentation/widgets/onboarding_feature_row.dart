import 'package:farmtec/core/l10n/app_localizations.dart';
import 'package:farmtec/core/themes/app_fonts.dart';
import 'package:farmtec/core/themes/app_theme_colors.dart';
import 'package:farmtec/features/onboarding/data/onboarding_page_model.dart';
import 'package:flutter/material.dart';

class OnboardingFeatureRow extends StatelessWidget {
  const OnboardingFeatureRow({super.key, required this.feature});

  final OnboardingFeature feature;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colors = context.appColors;
    final isDark = context.isDarkTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.statGreenTint,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.iconAccent.withAlpha(isDark ? 50 : 35),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colors.iconAccent.withAlpha(isDark ? 40 : 25),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                feature.emoji,
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.tr(feature.title),
                  style: AppFonts.font(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l.convertNumbers(l.tr(feature.description)),
                  style: AppFonts.font(
                    fontSize: 12,
                    color: colors.textTertiary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
