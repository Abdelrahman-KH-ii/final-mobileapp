import 'package:farmtec/core/themes/pallete.dart';
import 'package:farmtec/core/themes/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileSheetField extends StatelessWidget {
  final String label;
  final String initial;
  final IconData icon;
  final bool obscure;
  final bool isDark;
  final TextEditingController? controller;
  final bool readOnly;

  const ProfileSheetField(
    this.label,
    this.initial,
    this.icon, {
    super.key,
    this.obscure = false,
    required this.isDark,
    this.controller,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      readOnly: readOnly,
      style: AppFonts.font(
        fontSize: 14,
        color: isDark ? Pallete.darkTextPrimary : Pallete.primary,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppFonts.font(
          fontSize: 13,
          color: isDark ? Pallete.darkTextSecondary : const Color(0xFF9CA3AF),
        ),
        prefixIcon: Icon(
          icon,
          size: 18,
          color: isDark ? Pallete.darkTextPrimary : Pallete.primary,
        ),
        filled: true,
        fillColor:
            isDark ? Pallete.darkSurfaceVariant : const Color(0xFFF3F4ED),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Pallete.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }
}
