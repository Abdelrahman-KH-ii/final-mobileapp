import 'package:flutter/material.dart';
import 'package:farmtec/core/themes/app_fonts.dart';
import 'package:google_fonts/google_fonts.dart';

class WeatherStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const WeatherStat(
    this.icon,
    this.value,
    this.label, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white60, size: 17),
        const SizedBox(height: 3),
        Text(
          value,
          style: AppFonts.font(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: AppFonts.font(fontSize: 10, color: Colors.white54),
        ),
      ],
    );
  }
}
