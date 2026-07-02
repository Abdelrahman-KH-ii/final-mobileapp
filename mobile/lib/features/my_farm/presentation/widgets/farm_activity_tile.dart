import 'package:farmtec/core/l10n/app_localizations.dart';
import 'package:farmtec/core/themes/app_fonts.dart';
import 'package:farmtec/core/services/farm_history_service.dart';
import 'package:flutter/material.dart';

class FarmActivityTile extends StatelessWidget {
  final FarmOperation op;
  final bool isDark;
  final Color textColor;
  final Color subColor;
  final bool showDivider;

  const FarmActivityTile({
    super.key,
    required this.op,
    required this.isDark,
    required this.textColor,
    required this.subColor,
    this.showDivider = true,
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

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Icon(
                Icons.chevron_left_rounded,
                size: 18,
                color: subColor.withAlpha(160),
                textDirection: TextDirection.ltr,
              ),
              const SizedBox(width: 4),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: op.color.withAlpha(25),
                  shape: BoxShape.circle,
                ),
                child: Icon(op.icon, color: op.color, size: 17),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      op.displayTitle(l),
                      style: AppFonts.font(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                    if (op.description.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        op.description,
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
                _timeAgo(op.timestamp, l),
                style: AppFonts.font(fontSize: 10, color: subColor),
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            thickness: 1,
            indent: 14,
            endIndent: 14,
            color:
                isDark
                    ? Colors.white.withAlpha(15)
                    : const Color(0xFFE5E7EB),
          ),
      ],
    );
  }
}
