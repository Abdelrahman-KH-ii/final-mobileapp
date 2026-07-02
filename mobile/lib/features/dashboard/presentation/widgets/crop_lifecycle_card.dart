import 'package:farmtec/core/l10n/app_localizations.dart';
import 'package:farmtec/core/themes/app_fonts.dart';
import 'package:farmtec/core/services/crop_lifecycle_service.dart';
import 'package:farmtec/core/themes/app_theme_colors.dart';
import 'package:farmtec/core/themes/pallete.dart';
import 'package:flutter/material.dart';

class CropLifecycleCard extends StatelessWidget {
  final bool isDark;
  final Color textColor;
  final Color subColor;
  final String crop;
  final DateTime? plantedAt;

  const CropLifecycleCard({
    super.key,
    required this.isDark,
    required this.textColor,
    required this.subColor,
    required this.crop,
    this.plantedAt,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    if (plantedAt == null) {
      return Row(
        children: [
          Icon(Icons.info_outline_rounded, color: subColor, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l.tr('set_planting_date_hint'),
              style: AppFonts.font(fontSize: 12, color: subColor),
            ),
          ),
        ],
      );
    }

    final status = CropLifecycleService.statusFor(crop, plantedAt!);
    final harvest = status.expectedHarvest;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Pallete.primary.withAlpha(isDark ? 30 : 16),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                l.convertNumbers(
                  l.trParams('day_n', {'n': status.currentDay.toString()}),
                ),
                style: AppFonts.font(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: Pallete.primary,
                ),
              ),
            ),
            _StageBadge(
              icon: status.currentStage.icon,
              isDark: isDark,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '${l.tr(CropLifecycleService.cropL10nKey(crop))} • ${_stageTitle(l, status.currentStage.name)}',
          textAlign: TextAlign.center,
          style: AppFonts.font(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: textColor,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: status.progress,
            minHeight: 7,
            backgroundColor: context.appColors.chipBg,
            valueColor: const AlwaysStoppedAnimation(Pallete.secondary),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l.tr('sowing'),
              style: AppFonts.font(fontSize: 9, color: subColor),
            ),
            Flexible(
              child: Text(
                '${l.tr('expected_harvest')}: ${l.convertNumbers('${harvest.month} / ${harvest.day}')}',
                textAlign: TextAlign.end,
                style: AppFonts.font(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: subColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _stageTitle(AppLocalizations l, String stageName) {
    final key = 'stage_${stageName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_')}';
    return l.trOr(key, stageName);
  }
}

class _StageBadge extends StatelessWidget {
  final IconData icon;
  final bool isDark;

  const _StageBadge({
    required this.icon,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors:
              isDark
                  ? [
                    Pallete.secondary.withAlpha(55),
                    Pallete.primary.withAlpha(90),
                  ]
                  : [const Color(0xFFEAF4EC), const Color(0xFFD4E8D8)],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Pallete.secondary.withAlpha(isDark ? 50 : 35),
        ),
        boxShadow: [
          BoxShadow(
            color: Pallete.primary.withAlpha(isDark ? 35 : 18),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(icon, size: 21, color: context.appColors.iconAccent),
    );
  }
}
