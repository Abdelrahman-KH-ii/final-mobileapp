import 'package:farmtec/core/themes/pallete.dart';
import 'package:farmtec/core/themes/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextField extends StatelessWidget {
  final String hint;
  final TextInputType type;
  final bool obscure;
  final bool isRequired;
  final Widget? suffix;
  final Widget? prefix;
  final TextEditingController? controller;
  final Color fillColor;
  final Color borderColor;
  final Color textColor;

  const AppTextField({
    super.key,
    required this.hint,
    required this.type,
    this.obscure = false,
    this.isRequired = true,
    this.suffix,
    this.prefix,
    this.controller,
    required this.fillColor,
    required this.borderColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: type,
      style: AppFonts.font(fontSize: 14, color: textColor),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppFonts.font(fontSize: 14, color: Pallete.textHint),
        filled: true,
        fillColor: fillColor,
        suffixIcon: suffix,
        prefixIcon: prefix,
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Pallete.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Pallete.error, width: 1.5),
        ),
      ),
      validator: isRequired
          ? (v) => (v == null || v.isEmpty) ? 'Required' : null
          : null,
    );
  }
}
