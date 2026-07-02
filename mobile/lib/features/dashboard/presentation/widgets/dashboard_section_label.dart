import 'package:flutter/material.dart';
import 'package:farmtec/core/themes/app_fonts.dart';
import 'package:google_fonts/google_fonts.dart';

class DashboardSectionLabel extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;

  const DashboardSectionLabel({
    super.key,
    required this.icon,
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
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
