import 'package:farmtec/core/themes/app_theme_colors.dart';
import 'package:farmtec/core/themes/app_fonts.dart';
import 'package:flutter/material.dart';

class ProfileLangTile extends StatelessWidget {
  final String label;
  final String code;
  final bool isDark;
  final bool isActive;
  final Color textColor;
  final VoidCallback onTap;

  const ProfileLangTile({
    super.key,
    required this.label,
    required this.code,
    required this.isDark,
    required this.textColor,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: (isActive ? colors.textPrimary : colors.textHint)
                    .withAlpha(15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  code.toUpperCase(),
                  style: AppFonts.font(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: isActive ? colors.textPrimary : colors.textHint,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: AppFonts.font(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isActive ? colors.textPrimary : colors.textTertiary,
                  width: 2,
                ),
                color: isActive ? colors.textPrimary : Colors.transparent,
              ),
              child:
                  isActive
                      ? const Icon(
                        Icons.circle,
                        size: 8,
                        color: Colors.white,
                      )
                      : null,
            ),
          ],
        ),
      ),
    );
  }
}
