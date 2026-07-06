import 'package:flutter/material.dart';
import 'package:farmtec/core/l10n/app_localizations.dart';
import 'package:farmtec/features/ai_models/presentation/widgets/model_results/ai_model_result_card_shell.dart';
import 'package:farmtec/features/ai_models/presentation/widgets/model_results/model_results_helpers.dart';

class SoilHealthResultsCard extends StatelessWidget {
  final dynamic data;
  final AppLocalizations l;
  final Color cardColor;
  final Color textColor;
  final Color accentGreen;

  const SoilHealthResultsCard({
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
    final soilData = payload['data'];

    if (soilData is Map<String, dynamic>) {
      final score = soilData['overall_score'];
      final rating = soilData['rating']?.toString() ?? l.tr('model_result_unknown');
      final limitingFactor = soilData['limiting_factor']?.toString() ?? l.tr('model_result_unknown');
      final scoreText = score is num ? l.convertNumbers(score.toStringAsFixed(1)) : l.convertNumbers(score?.toString() ?? l.tr('model_result_unknown'));
      // distance/nearest-data removed from UI per request

      return AiModelResultCardShell(
        cardColor: cardColor,
        textColor: textColor,
        accentGreen: accentGreen,
        topAccentColor: const Color(0xFF4D7C0F),
        icon: Icons.terrain,
        iconColor: const Color(0xFF4D7C0F),
        backgroundGradient: const LinearGradient(
          colors: [Color(0xFFF0FDF4), Color(0xFFE6F4E8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderColor: const Color(0xFF86C232),
        title: l.tr('model_result_soil_health_report'),
        children: [
          AiModelResultSection(
            title: l.tr('model_result_section_soil_health_summary'),
            textColor: textColor,
            accentGreen: accentGreen,
            sectionColor: cardColor.withOpacity(0.88),
            sectionBorderColor: accentGreen.withOpacity(0.16),
            children: [
              AiModelResultField(label: l.tr('model_result_field_score'), value: scoreText, bulletColor: accentGreen, textColor: textColor),
              const SizedBox(height: 10),
              AiModelResultField(label: l.tr('model_result_field_rating'), value: rating, bulletColor: accentGreen, textColor: textColor),
              const SizedBox(height: 10),
              AiModelResultField(label: l.tr('model_result_field_limiting_factor'), value: limitingFactor, bulletColor: accentGreen, textColor: textColor),
              const SizedBox(height: 10),
                    // recommendation and nearest-data removed intentionally
            ],
          ),
              // Render categories if present
              if (soilData is Map && soilData['categories'] is Map<String, dynamic>) ...[
                const SizedBox(height: 10),
                AiModelResultSection(
                  title: l.tr('model_result_section_soil_categories'),
                  textColor: textColor,
                  accentGreen: accentGreen,
                  sectionColor: cardColor.withOpacity(0.88),
                  sectionBorderColor: accentGreen.withOpacity(0.08),
                  children: [
                    for (final entry in (soilData['categories'] as Map<String, dynamic>).entries) ...[
                      AiModelResultField(
                        label: _localizedLabel(entry.key, l),
                        value: _formatValue(entry.value, l),
                        bulletColor: accentGreen,
                        textColor: textColor,
                      ),
                      const SizedBox(height: 8),
                    ],
                  ],
                ),
              ],
              // Render specific elements if present
              if (soilData is Map && (soilData['elements'] is Map<String, dynamic> || soilData['elements'] is List)) ...[
                const SizedBox(height: 10),
                AiModelResultSection(
                  title: l.tr('model_result_section_soil_elements'),
                  textColor: textColor,
                  accentGreen: accentGreen,
                  sectionColor: cardColor.withOpacity(0.88),
                  sectionBorderColor: accentGreen.withOpacity(0.08),
                  children: [
                    if (soilData['elements'] is Map<String, dynamic>)
                      for (final entry in (soilData['elements'] as Map<String, dynamic>).entries) ...[
                        AiModelResultField(label: _localizedLabel(entry.key, l), value: _formatValue(entry.value, l), bulletColor: accentGreen, textColor: textColor),
                        const SizedBox(height: 8),
                      ]
                    else if (soilData['elements'] is List)
                      for (final item in (soilData['elements'] as List)) ...[
                        if (item is Map && item.containsKey('name'))
                          AiModelResultField(label: _localizedLabel(item['name'].toString(), l), value: _formatValue(item['value'] ?? item['score'] ?? item['result'], l), bulletColor: accentGreen, textColor: textColor),
                        const SizedBox(height: 8),
                      ],
                  ],
                ),
              ],
        ],
      );
    }

        

    return AiModelResultCardShell(
      cardColor: cardColor,
      textColor: textColor,
      accentGreen: accentGreen,
      title: l.tr('model_result_soil_health_report'),
      children: [],
    );
  }

  String _localizedLabel(String key, AppLocalizations l) {
    final t = l.tr(key);
    if (t == key) {
      final s = key.replaceAll('_', ' ');
      return s.substring(0, 1).toUpperCase() + s.substring(1) + ':';
    }
    return '$t:';
  }

  String _formatValue(dynamic v, AppLocalizations l) {
    if (v == null) return '-';
    if (v is num) return l.convertNumbers(v.toString());
    final n = num.tryParse(v.toString());
    if (n != null) return l.convertNumbers(n.toString());
    return l.trOr(v.toString(), v.toString());
  }
}
