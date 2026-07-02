import 'package:farmtec/core/l10n/app_localizations.dart';
import 'package:farmtec/core/themes/app_fonts.dart';
import 'package:farmtec/core/themes/app_theme_colors.dart';
import 'package:farmtec/core/themes/pallete.dart';
import 'package:farmtec/core/services/app_notification_service.dart';
import 'package:flutter/material.dart';

class NotificationCard extends StatelessWidget {
  final AppNotification item;
  final VoidCallback? onTap;

  const NotificationCard({super.key, required this.item, this.onTap});

  String _title(AppLocalizations l) {
    if (item.titleKey != null) return l.tr(item.titleKey!);
    return item.title;
  }

  String _body(AppLocalizations l) {
    if (item.bodyKey != null) {
      final text = item.bodyParams != null
          ? l.trParams(item.bodyKey!, item.bodyParams!)
          : l.tr(item.bodyKey!);
      return l.convertNumbers(text);
    }
    return l.convertNumbers(item.body);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colors = context.appColors;
    final isDark = context.isDarkTheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: item.isRead ? colors.card : item.color.withAlpha(isDark ? 30 : 10),
        borderRadius: BorderRadius.circular(16),
        border: item.isRead
            ? Border.all(color: colors.outline.withAlpha(isDark ? 80 : 40))
            : Border.all(color: item.color.withAlpha(isDark ? 90 : 60), width: 1),
        boxShadow: [
          BoxShadow(
            color: colors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: item.color.withAlpha(isDark ? 40 : 25),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(_iconFor(item.type), color: item.color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        _title(l),
                        style: AppFonts.font(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: colors.textPrimary,
                        ),
                      ),
                    ),
                    if (!item.isRead)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: item.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  _body(l),
                  style: AppFonts.font(
                    fontSize: 12,
                    color: colors.textTertiary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  l.tr(item.timeKey),
                  style: AppFonts.font(
                    fontSize: 11,
                    color: colors.textHint,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }

  IconData _iconFor(NotifType type) {
    switch (type) {
      case NotifType.weather:
        return Icons.wb_cloudy_outlined;
      case NotifType.market:
        return Icons.show_chart_rounded;
      case NotifType.disease:
        return Icons.biotech_rounded;
      case NotifType.general:
        return Icons.notifications_outlined;
    }
  }
}
