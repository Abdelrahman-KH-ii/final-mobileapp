import 'package:flutter/material.dart';
import 'package:farmtec/core/l10n/app_localizations.dart';
import 'package:farmtec/core/themes/app_fonts.dart';
import 'package:farmtec/features/ai_models/presentation/widgets/model_results/ai_model_result_card_shell.dart';
import 'package:farmtec/features/ai_models/presentation/widgets/model_results/model_results_helpers.dart';

class CropRecommendationResultsCard extends StatelessWidget {
  final dynamic data;
  final AppLocalizations l;
  final Color cardColor;
  final Color textColor;
  final Color accentGreen;

  const CropRecommendationResultsCard({
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
    final crop = (payload['predicted_crop'] ?? payload['prediction'] ?? data?.toString() ?? l.tr('model_result_unknown')).toString();
    final cropLabel = crop.isNotEmpty ? '${crop[0].toUpperCase()}${crop.substring(1)}' : crop;

    return AiModelResultCardShell(
      cardColor: cardColor,
      textColor: textColor,
      accentGreen: accentGreen,
      topAccentColor: const Color(0xFF16A34A),
      icon: Icons.eco,
      iconColor: const Color(0xFF16A34A),
      backgroundGradient: const LinearGradient(
        colors: [Color(0xFFF4FBF4), Color(0xFFE8F3E9)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderColor: const Color(0xFFD8E8D8),
      title: l.tr('prediction_results'),
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: accentGreen.withOpacity(0.12)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: accentGreen.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.eco,
                  color: accentGreen,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.tr('model_result_field_crop'),
                      style: AppFonts.font(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      cropLabel,
                      style: AppFonts.font(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: accentGreen,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: accentGreen,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
