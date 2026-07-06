import 'package:flutter/material.dart';
import 'package:farmtec/core/l10n/app_localizations.dart';
import 'package:farmtec/features/ai_models/presentation/widgets/model_results/ai_model_result_card_shell.dart';
import 'package:farmtec/features/ai_models/presentation/widgets/model_results/model_results_helpers.dart';

class YieldPredictionResultsCard extends StatelessWidget {
  final dynamic data;
  final AppLocalizations l;
  final Color cardColor;
  final Color textColor;
  final Color accentGreen;

  const YieldPredictionResultsCard({
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
    final yieldValue = payload['predicted_yield'] ?? payload['yield'] ?? payload['prediction'];
    final yieldStr = yieldValue is num ? yieldValue.toStringAsFixed(2) : yieldValue?.toString() ?? l.tr('model_result_unknown');
    final unit = payload['unit']?.toString() ?? 't/ha';

    return AiModelResultCardShell(
      cardColor: cardColor,
      textColor: textColor,
      accentGreen: accentGreen,
      topAccentColor: const Color(0xFF0EA5E9),
      icon: Icons.show_chart,
      iconColor: const Color(0xFF0284C7),
      backgroundGradient: const LinearGradient(
        colors: [Color(0xFFE0F2FE), Color(0xFFD0EAFA)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderColor: const Color(0xFF7DD3FC),
      title: l.trParams('yield_predicted', {'yield': yieldStr, 'unit': unit}),
      children: [
        AiModelResultSection(
          title: l.tr('model_result_section_prediction_details'),
          textColor: textColor,
          accentGreen: accentGreen,
          sectionColor: cardColor.withOpacity(0.88),
          sectionBorderColor: accentGreen.withOpacity(0.16),
          children: [
            AiModelResultField(
              label: l.tr('model_result_field_yield'),
              value: yieldStr,
              bulletColor: accentGreen,
              textColor: textColor,
            ),
            const SizedBox(height: 10),
            AiModelResultField(
              label: l.tr('model_result_field_unit'),
              value: unit,
              bulletColor: accentGreen,
              textColor: textColor,
            ),
          ],
        ),
      ],
    );
  }
}
