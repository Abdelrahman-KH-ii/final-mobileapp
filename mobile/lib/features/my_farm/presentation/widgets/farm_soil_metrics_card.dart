import 'package:farmtec/core/l10n/app_localizations.dart';
import 'package:farmtec/core/services/soil_health_service.dart';
import 'package:farmtec/core/themes/app_fonts.dart';
import 'package:farmtec/core/themes/pallete.dart';
import 'package:farmtec/features/farm/presentation/providers/farm_provider.dart';
import 'package:farmtec/features/my_farm/presentation/widgets/my_farm_card_style.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class _SoilDetail {
  final IconData icon;
  final String labelKey;
  final String value;
  final String? statusKey;
  final Color color;

  const _SoilDetail({
    required this.icon,
    required this.labelKey,
    required this.value,
    this.statusKey,
    required this.color,
  });
}

class FarmSoilMetricsCard extends StatelessWidget {
  final bool isDark;
  final Color cardColor;
  final Color textColor;
  final Color subColor;

  const FarmSoilMetricsCard({
    super.key,
    required this.isDark,
    required this.cardColor,
    required this.textColor,
    required this.subColor,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final farm = Provider.of<FarmProvider>(context, listen: false).selectedFarm;
    final soilHealthService = Provider.of<SoilHealthService>(context, listen: false);
    final scoreFuture = farm != null
        ? soilHealthService.getScoreForLocation(lat: farm.lat, lng: farm.lng)
        : Future.value(0.0);
    final details = [
      _SoilDetail(
        icon: Icons.thermostat_rounded,
        labelKey: 'ph_level',
        value: farm?.ph != null ? l.convertNumbers(farm!.ph!.toStringAsFixed(1)) : l.convertNumbers('6.8'),
        statusKey: farm?.ph != null && farm!.ph! >= 6.0 && farm!.ph! <= 7.5 ? 'optimal' : null,
        color: const Color(0xFF7CB342),
      ),
      _SoilDetail(
        icon: Icons.grass_rounded,
        labelKey: 'organic_matter',
        value: farm?.soilMoisture != null ? '${l.convertNumbers(farm!.soilMoisture!.toStringAsFixed(1))}%' : l.convertNumbers('2.9%'),
        color: const Color(0xFF4CAF50),
      ),
      _SoilDetail(
        icon: Icons.eco_rounded,
        labelKey: 'nitrogen',
        value: farm?.nitrogen != null ? '${l.convertNumbers(farm!.nitrogen!.toStringAsFixed(0))} ppm' : l.tr('medium'),
        color: const Color(0xFF26A69A),
      ),
      _SoilDetail(
        icon: Icons.layers_rounded,
        labelKey: 'texture',
        value: farm != null && farm.soilType.isNotEmpty ? farm.soilType : 'Loam',
        color: const Color(0xFF42A5F5),
      ),
    ];

    return FutureBuilder<double>(
      future: scoreFuture,
      builder: (context, snapshot) {
        final score = snapshot.data ?? 0.0;
        final progress = (score / 100).clamp(0.0, 1.0);
        final scoreText = '${l.convertNumbers(score.toStringAsFixed(0))}%';

        return Container(
          decoration: myFarmCardDecoration(isDark, cardColor),
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l.tr('soil_analysis_score'),
                style: AppFonts.font(fontSize: 12, color: subColor),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          scoreText,
                          style: AppFonts.font(
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          l.tr('overall_soil_health'),
                          style: AppFonts.font(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: subColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 72,
                    height: 72,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 8,
                          valueColor: AlwaysStoppedAnimation(
                            isDark ? Colors.greenAccent : const Color(0xFF4CAF50),
                          ),
                          backgroundColor: isDark
                              ? Colors.white.withOpacity(0.08)
                              : const Color(0xFFE8F5E9),
                        ),
                        Center(
                          child: Text(
                            scoreText,
                            style: AppFonts.font(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: textColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _soilDetailTile(l, details[0], textColor, subColor),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _soilDetailTile(l, details[1], textColor, subColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _soilDetailTile(l, details[2], textColor, subColor),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _soilDetailTile(l, details[3], textColor, subColor),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _soilDetailTile(
    AppLocalizations l,
    _SoilDetail detail,
    Color textColor,
    Color subColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.03) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: detail.color.withOpacity(0.16),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(detail.icon, size: 18, color: detail.color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.tr(detail.labelKey),
                  style: AppFonts.font(fontSize: 12, color: subColor),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      detail.value,
                      style: AppFonts.font(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                    if (detail.statusKey != null) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: detail.color.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          l.tr(detail.statusKey!),
                          style: AppFonts.font(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: detail.color,
                          ),
                        ),
                      ),
                    ]
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
