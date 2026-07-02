import 'package:farmtec/core/themes/pallete.dart';
import 'package:farmtec/core/themes/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DashboardActionChip extends StatelessWidget {
  final String label;
  final bool filled;

  const DashboardActionChip({
    super.key,
    required this.label,
    required this.filled,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: filled ? Pallete.primary : Colors.transparent,
        border: filled ? null : Border.all(color: Pallete.primary, width: 1.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppFonts.font(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: filled ? Colors.white : Pallete.primary,
        ),
      ),
    );
  }
}
