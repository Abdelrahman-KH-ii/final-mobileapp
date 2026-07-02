import 'package:flutter/material.dart';
import 'package:farmtec/core/themes/app_fonts.dart';
import 'package:farmtec/core/themes/app_theme_colors.dart';

class FarmSectionLabel extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;

  const FarmSectionLabel({
    super.key,
    required this.icon,
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Row(
      children: [
        Icon(icon, size: 16, color: colors.iconAccent),
        const SizedBox(width: 7),
        Text(
          title,
          style: AppFonts.font(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}
