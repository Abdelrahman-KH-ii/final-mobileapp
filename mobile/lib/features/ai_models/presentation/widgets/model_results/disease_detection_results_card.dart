import 'package:flutter/material.dart';
import 'package:farmtec/core/l10n/app_localizations.dart';
import 'package:farmtec/core/themes/app_fonts.dart';
import 'package:farmtec/features/ai_models/presentation/widgets/model_results/ai_model_result_card_shell.dart';
import 'package:farmtec/features/ai_models/presentation/widgets/model_results/model_results_helpers.dart';

class DiseaseDetectionResultsCard extends StatelessWidget {
  final dynamic data;
  final AppLocalizations l;
  final Color cardColor;
  final Color textColor;
  final Color accentGreen;

  const DiseaseDetectionResultsCard({
    super.key,
    required this.data,
    required this.l,
    required this.cardColor,
    required this.textColor,
    required this.accentGreen,
  });

  @override
  Widget build(BuildContext context) {
    final response = data is String ? data : data.toString();

    return AiModelResultCardShell(
      cardColor: cardColor,
      textColor: textColor,
      accentGreen: accentGreen,
      topAccentColor: const Color(0xFFEF4444),
      icon: Icons.bug_report,
      iconColor: const Color(0xFFDC2626),
      backgroundGradient: const LinearGradient(
        colors: [Color(0xFFFEE2E2), Color(0xFFFECACA)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderColor: const Color(0xFFFCA5A5),
      title: l.tr('model_result_disease_detection'),
      children: [
        AiModelResultSection(
          title: l.tr('model_result_section_analysis'),
          textColor: textColor,
          accentGreen: accentGreen,
          sectionColor: cardColor.withOpacity(0.88),
          sectionBorderColor: accentGreen.withOpacity(0.16),
          children: [
            Text(
              response,
              style: AppFonts.font(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: textColor,
                height: 1.6,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
