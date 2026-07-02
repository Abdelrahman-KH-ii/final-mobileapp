import 'package:farmtec/core/l10n/app_localizations.dart';
import 'package:farmtec/core/themes/app_fonts.dart';
import 'package:farmtec/core/themes/pallete.dart';
import 'package:farmtec/features/dashboard/presentation/widgets/moisture_circle_painter.dart';
import 'package:flutter/material.dart';

class MoistureGauge extends StatelessWidget {
  final bool isDark;
  final Color textColor;
  final double progress;
  final String value;
  final String label;

  const MoistureGauge({
    super.key,
    required this.isDark,
    required this.textColor,
    required this.progress,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 78,
      child: Column(
        children: [
          SizedBox(
            width: 68,
            height: 68,
            child: CustomPaint(
              painter: MoistureCirclePainter(progress, isDark),
              child: Center(
                child: Text(
                  value,
                  style: AppFonts.font(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppFonts.font(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: isDark ? Pallete.darkTextSecondary : Pallete.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}
