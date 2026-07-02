import 'package:flutter/material.dart';
import 'package:farmtec/core/themes/app_fonts.dart';
import 'package:google_fonts/google_fonts.dart';

class FieldLabel extends StatelessWidget {
  final String text;
  final Color color;

  const FieldLabel({super.key, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppFonts.font(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: color,
      ),
    );
  }
}
