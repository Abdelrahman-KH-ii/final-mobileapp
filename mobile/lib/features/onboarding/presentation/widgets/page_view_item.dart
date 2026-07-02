import 'package:farmtec/core/l10n/app_localizations.dart';
import 'package:farmtec/core/themes/app_fonts.dart';
import 'package:farmtec/core/themes/app_theme_colors.dart';
import 'package:farmtec/core/themes/pallete.dart';
import 'package:farmtec/core/themes/text_styles.dart';
import 'package:farmtec/features/onboarding/data/onboarding_page_model.dart';
import 'package:farmtec/features/onboarding/presentation/widgets/onboarding_feature_row.dart';
import 'package:farmtec/features/onboarding/presentation/widgets/onboarding_image_card.dart';
import 'package:farmtec/features/onboarding/presentation/widgets/onboarding_tag_chip.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PageViewItem extends StatelessWidget {
  const PageViewItem({super.key, required this.model});

  final OnboardingPageModel model;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colors = context.appColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        OnboardingImageCard(model: model),
        const SizedBox(height: 28),
        if (model.tagLabel != null) ...[
          OnboardingTagChip(label: l.tr(model.tagLabel!)),
          const SizedBox(height: 14),
        ],
        Text(
          l.tr(model.title),
          textAlign: TextAlign.center,
          style: AppFonts.font(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            color: colors.textPrimary,
            height: 1.2,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Text(
            l.tr(model.subtitle),
            textAlign: TextAlign.center,
            style: TextStyles.bodyMedium.copyWith(
              fontSize: 15,
              height: 1.6,
              color: colors.textTertiary,
            ),
          ),
        ),
        if (model.featureItem != null) ...[
          const SizedBox(height: 20),
          OnboardingFeatureRow(feature: model.featureItem!),
        ],
      ],
    );
  }
}
