import 'package:flutter/material.dart';
import 'package:farmtec/core/themes/app_fonts.dart';
import 'package:google_fonts/google_fonts.dart';

class WeatherForecastDay extends StatelessWidget {
  final String day;
  final String emoji;
  final String high;
  final String low;

  const WeatherForecastDay({
    super.key,
    required this.day,
    required this.emoji,
    required this.high,
    required this.low,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          day,
          style: AppFonts.font(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Colors.white54,
          ),
        ),
        const SizedBox(height: 6),
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 6),
        Text(
          high,
          style: AppFonts.font(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        Text(
          low,
          style: AppFonts.font(fontSize: 10, color: Colors.white54),
        ),
      ],
    );
  }
}
