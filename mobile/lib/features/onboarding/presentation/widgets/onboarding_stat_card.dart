import 'package:farmtec/core/l10n/app_localizations.dart';
import 'package:farmtec/core/themes/app_fonts.dart';
import 'package:farmtec/core/themes/app_theme_colors.dart';
import 'package:farmtec/features/onboarding/data/onboarding_page_model.dart';
import 'package:flutter/material.dart';

class OnboardingStatCard extends StatelessWidget {
  const OnboardingStatCard({
    super.key,
    required this.data,
    this.highlight = false,
  });

  final OnboardingCardData data;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colors = context.appColors;
    final isDark = context.isDarkTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: colors.card.withAlpha(isDark ? 230 : 242),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.outline.withAlpha(isDark ? 60 : 30)),
        boxShadow: [
          BoxShadow(
            color: colors.shadow,
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (data.emoji.isNotEmpty) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color:
                    highlight
                        ? colors.iconAccent.withAlpha(isDark ? 50 : 25)
                        : colors.statGreenTint,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(data.emoji, style: const TextStyle(fontSize: 15)),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l.tr(data.label),
                style: AppFonts.font(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                  color: colors.textHint,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                l.convertNumbers(l.tr(data.value)),
                style: AppFonts.font(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color:
                      highlight ? colors.iconAccent : colors.textPrimary,
                ),
              ),
              if (data.subtitle != null)
                Text(
                  l.convertNumbers(l.tr(data.subtitle!)),
                  style: AppFonts.font(
                    fontSize: 10,
                    color: colors.iconAccent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
