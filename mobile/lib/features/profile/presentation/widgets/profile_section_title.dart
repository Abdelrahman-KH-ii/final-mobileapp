import 'package:farmtec/core/themes/pallete.dart';
import 'package:farmtec/core/themes/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileSectionTitle extends StatelessWidget {
  final String text;
  final bool isDark;

  const ProfileSectionTitle(this.text, {super.key, required this.isDark});

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: AppFonts.font(
      fontSize: 13,
      fontWeight: FontWeight.w700,
      color: isDark ? Pallete.darkTextTertiary : const Color(0xFF9CA3AF),
      letterSpacing: 0.5,
    ),
  );
}
