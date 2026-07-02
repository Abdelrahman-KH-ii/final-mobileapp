import 'package:farmtec/core/themes/pallete.dart';
import 'package:farmtec/core/themes/app_fonts.dart';
import 'package:flutter/material.dart';

class ProfileSettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? trailing;
  final VoidCallback onTap;
  final bool isDark;
  final Color textColor;
  final bool showDivider;

  const ProfileSettingsTile({
    super.key,
    required this.icon,
    required this.label,
    this.trailing,
    required this.onTap,
    required this.isDark,
    required this.textColor,
    this.showDivider = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (showDivider)
          Divider(
            height: 1,
            color: isDark ? Pallete.darkOutline : Pallete.neutral200,
          ),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: Pallete.primary.withAlpha(15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: Pallete.primary, size: 17),
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
                if (trailing != null)
                  Text(
                    trailing!,
                    style: AppFonts.font(
                      fontSize: 12,
                      color:
                          isDark
                              ? Pallete.darkTextSecondary
                              : Pallete.textSecondary,
                    ),
                  )
                else
                  Icon(
                    Icons.chevron_right_rounded,
                    color:
                        isDark
                            ? Pallete.darkTextTertiary
                            : Pallete.neutral400,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
