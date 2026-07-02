import 'package:farmtec/core/l10n/app_localizations.dart';
import 'package:farmtec/core/themes/app_fonts.dart';
import 'package:farmtec/core/themes/app_theme_colors.dart';
import 'package:farmtec/core/widgets/crop_avatar.dart';
import 'package:flutter/material.dart';

class FarmStatCard extends StatelessWidget {
  final IconData? icon;
  final String? cropImage;
  final String value;
  final String label;
  final Color accentColor;
  final Color? backgroundColor;
  final bool isDark;
  final bool accentValue;
  final String? actionLabel;
  final IconData? actionIcon;
  final String? footer;
  final IconData? footerIcon;
  final VoidCallback? onAction;

  const FarmStatCard({
    super.key,
    this.icon,
    this.cropImage,
    required this.value,
    required this.label,
    required this.accentColor,
    this.backgroundColor,
    required this.isDark,
    this.accentValue = true,
    this.actionLabel,
    this.actionIcon,
    this.footer,
    this.footerIcon,
    this.onAction,
  }) : assert(icon != null || cropImage != null);

  Color _cardBg(BuildContext context) {
    if (backgroundColor != null) {
      return context.isDarkTheme
          ? accentColor.withAlpha(28)
          : backgroundColor!;
    }
    return context.appColors.card;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colors = context.appColors;
    final textColor = colors.textPrimary;
    final subColor = colors.textTertiary;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _cardBg(context),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(isDark ? 25 : 8),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _leadingVisual(),
            const SizedBox(width: 10),
            Expanded(
              child: SizedBox(
                height: 96,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: AppFonts.font(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: subColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l.convertNumbers(value),
                      style: AppFonts.font(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: accentValue ? accentColor : textColor,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    if (footer != null)
                      Align(
                        alignment: AlignmentDirectional.bottomEnd,
                        child: _pill(context, footer!, footerIcon),
                      )
                    else if (actionLabel != null)
                      Align(
                        alignment: AlignmentDirectional.bottomEnd,
                        child: GestureDetector(
                          onTap: onAction,
                          child: _pill(context, actionLabel!, actionIcon),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _leadingVisual() {
    if (cropImage != null) {
      return CropAvatar(crop: cropImage!, size: 46, isDark: isDark);
    }

    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: accentColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: Colors.white, size: 22),
    );
  }

  Widget _pill(BuildContext context, String text, IconData? pillIcon) {
    final colors = context.appColors;
    final pillBg =
        isDark ? colors.chipBg : accentColor.withAlpha(18);
    final pillFg = isDark ? colors.iconAccent : accentColor;
    final pillBorder =
        isDark
            ? colors.outline
            : accentColor.withAlpha(50);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: pillBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: pillBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (pillIcon != null) ...[
            Icon(pillIcon, size: 11, color: pillFg),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              text,
              style: AppFonts.font(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: pillFg,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
