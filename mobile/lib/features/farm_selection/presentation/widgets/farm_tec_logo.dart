import 'package:farmtec/core/themes/pallete.dart';
import 'package:farmtec/core/themes/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FarmTecLogo extends StatelessWidget {
  final bool isDark;
  const FarmTecLogo({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Pallete.primary,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.eco_rounded, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 10),
        Text(
          'FarmTec',
          style: AppFonts.font(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: isDark ? Pallete.darkTextPrimary : Pallete.primary,
          ),
        ),
      ],
    );
  }
}
