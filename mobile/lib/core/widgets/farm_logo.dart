import 'package:farmtec/core/themes/app_theme_colors.dart';
import 'package:farmtec/core/themes/pallete.dart';
import 'package:farmtec/core/themes/app_fonts.dart';
import 'package:flutter/material.dart';

class FarmLogo extends StatelessWidget {
  const FarmLogo({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: colors.iconAccent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.eco_rounded, color: Colors.white, size: 18),
        ),
        const SizedBox(width: 8),
        Text(
          'FarmTech',
          style: AppFonts.font(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: colors.textPrimary,
          ),
        ),
      ],
    );
  }
}
