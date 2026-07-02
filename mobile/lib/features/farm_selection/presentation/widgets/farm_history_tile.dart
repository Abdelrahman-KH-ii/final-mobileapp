import 'package:farmtec/core/l10n/app_localizations.dart';
import 'package:farmtec/core/themes/app_fonts.dart';
import 'package:farmtec/core/services/farm_history_service.dart';
import 'package:farmtec/core/themes/pallete.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FarmHistoryTile extends StatelessWidget {
  final FarmOperation operation;
  final String farmName;
  final bool isDark;
  final Color cardColor;
  final Color textColor;
  final Color subColor;

  const FarmHistoryTile({
    super.key,
    required this.operation,
    required this.farmName,
    required this.isDark,
    required this.cardColor,
    required this.textColor,
    required this.subColor,
  });

  String _timeAgo(DateTime dt, AppLocalizations l) {
    final d = DateTime.now().difference(dt);
    if (d.inMinutes < 60) {
      return l.convertNumbers(
        l.trParams('time_ago_minutes', {'n': d.inMinutes.toString()}),
      );
    }
    if (d.inHours < 24) {
      return l.convertNumbers(
        l.trParams('time_ago_hours', {'h': d.inHours.toString()}),
      );
    }
    return l.convertNumbers(
      l.trParams('time_ago_days', {'d': d.inDays.toString()}),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 20 : 8),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: operation.color.withAlpha(25),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(operation.icon, color: operation.color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  operation.displayTitle(l),
                  style: AppFonts.font(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Pallete.primary.withAlpha(isDark ? 35 : 18),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.agriculture_rounded,
                        size: 12,
                        color: isDark ? Pallete.chartGreen : Pallete.primary,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          l.trParams('activity_on_farm', {'farm': farmName}),
                          style: AppFonts.font(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Pallete.chartGreen : Pallete.primary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                if (operation.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    operation.description,
                    style: AppFonts.font(fontSize: 11, color: subColor),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _timeAgo(operation.timestamp, l),
            style: AppFonts.font(fontSize: 10, color: subColor),
          ),
        ],
      ),
    );
  }
}
