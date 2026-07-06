import 'package:flutter/material.dart';
import 'package:farmtec/core/l10n/app_localizations.dart';
import 'package:farmtec/features/ai_models/presentation/widgets/model_results/ai_model_result_card_shell.dart';
import 'package:farmtec/features/ai_models/presentation/widgets/model_results/model_results_helpers.dart';

class IrrigationPlannerResultsCard extends StatelessWidget {
  final dynamic data;
  final AppLocalizations l;
  final Color cardColor;
  final Color textColor;
  final Color accentGreen;

  const IrrigationPlannerResultsCard({
    super.key,
    required this.data,
    required this.l,
    required this.cardColor,
    required this.textColor,
    required this.accentGreen,
  });

  @override
  Widget build(BuildContext context) {
    final payload = stringKeyedMap(data);
    final needRaw = payload['irrigation_need_mm_season'] ?? payload['irrigation_need_mm'] ?? null;
    final need = needRaw != null ? l.convertNumbers(needRaw.toString()) : l.tr('model_result_unknown');
    final irrigationClass = payload['irrigation_class'] ?? l.tr('model_result_unknown');

    return AiModelResultCardShell(
      cardColor: cardColor,
      textColor: textColor,
      accentGreen: accentGreen,
      topAccentColor: const Color(0xFF38BDF8),
      icon: Icons.water_drop,
      iconColor: const Color(0xFF0EA5E9),
      backgroundGradient: const LinearGradient(
        colors: [Color(0xFFEBF8FF), Color(0xFFDCEEFB)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderColor: const Color(0xFF7DD3FC),
      title: l.tr('model_result_irrigation_estimate'),
      children: [
        AiModelResultSection(
          title: l.tr('model_result_section_irrigation_summary'),
          textColor: textColor,
          accentGreen: accentGreen,
          sectionColor: cardColor.withOpacity(0.88),
          sectionBorderColor: accentGreen.withOpacity(0.16),
          children: [
            AiModelResultField(label: l.tr('model_result_field_need'), value: '$need ${l.tr('mm_per_season')}', bulletColor: accentGreen, textColor: textColor),
            const SizedBox(height: 10),
            AiModelResultField(label: l.tr('model_result_field_class'), value: '$irrigationClass', bulletColor: accentGreen, textColor: textColor),
            const SizedBox(height: 10),
            
          ],
        ),
      ],
    );
  }
}
