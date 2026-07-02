import 'package:farmtec/core/l10n/app_localizations.dart';
import 'package:farmtec/core/themes/app_fonts.dart';
import 'package:farmtec/core/themes/pallete.dart';
import 'package:farmtec/features/dashboard/data/models/dashboard_models.dart';
import 'package:farmtec/features/dashboard/presentation/widgets/moisture_gauge.dart';
import 'package:flutter/material.dart';

class SoilCard extends StatelessWidget {
  final List<SoilMetricModel> metrics;
  final bool isDark;
  final Color textColor;
  final double overallHealth;
  final String overallValue;
  final String overallLabelKey;

  const SoilCard({
    super.key,
    required this.metrics,
    required this.isDark,
    required this.textColor,
    required this.overallHealth,
    required this.overallValue,
    required this.overallLabelKey,
  });

  static const _icons = [
    Icons.thermostat_rounded,
    Icons.water_drop_rounded,
    Icons.eco_rounded,
    Icons.grain_rounded,
  ];

  static const _colors = [
    Color(0xFF7CB342),
    Color(0xFF4CAF50),
    Color(0xFF26A69A),
    Color(0xFFFF9800),
  ];

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final subColor =
        isDark ? Pallete.darkTextSecondary : Pallete.textTertiary;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          MoistureGauge(
            isDark: isDark,
            textColor: textColor,
            progress: overallHealth,
            value: overallValue,
            label: l.tr(overallLabelKey),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              children: List.generate(metrics.length, (i) {
                final metric = metrics[i];
                final valueText = l.convertNumbers(
                  metric.value.replaceAll('ppm', l.tr('ppm')),
                );

                return Padding(
                  padding: EdgeInsets.only(
                    bottom: i == metrics.length - 1 ? 0 : 10,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(_icons[i], size: 13, color: _colors[i]),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              l.tr(metric.label),
                              style: AppFonts.font(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: subColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            valueText,
                            style: AppFonts.font(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                      if (metric.progress != null) ...[
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: metric.progress,
                            minHeight: 5,
                            backgroundColor:
                                isDark
                                    ? Pallete.darkSurfaceVariant
                                    : const Color(0xFFEEF2EC),
                            valueColor: AlwaysStoppedAnimation(_colors[i]),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
