import 'package:farmtec/core/themes/pallete.dart';
import 'package:farmtec/core/themes/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract class TextStyles {
  // Large Titles (e.g., Dashboard "Field Alpha is thriving")
  static TextStyle displayLarge = AppFonts.font(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    color: Pallete.primaryColor,
    letterSpacing: -0.5,
  );

  // Screen Headers (e.g., "AI Models", "Market Prices")
  static TextStyle headlineMedium = AppFonts.font(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: Pallete.primaryColor,
    letterSpacing: -0.2,
  );

  // Section Headers (e.g., "Soil Metrics", "Quick Tools")
  static TextStyle titleLarge = AppFonts.font(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: Pallete.secondaryColor,
  );

  // Card Subheaders / Metric Labels
  static TextStyle titleMedium = AppFonts.font(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Pallete.secondaryColor,
  );

  // Tiny Labels (e.g., Nav bar labels, Overline)
  static TextStyle labelSmall = AppFonts.font(
    fontSize: 11,
    fontWeight: FontWeight.w800,
    letterSpacing: 1.2,
    color: Pallete.primaryColor.withOpacity(0.7),
  );

  static const TextStyle manropeRegular = TextStyle(
    fontFamily: 'Manrope',
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  static const TextStyle manropeMedium = TextStyle(
    fontFamily: 'Manrope',
    fontWeight: FontWeight.w500,
    height: 1.4,
  );

  static const TextStyle manropeSemiBold = TextStyle(
    fontFamily: 'Manrope',
    fontWeight: FontWeight.w600,
    height: 1.33,
  );

  static const TextStyle manropeBold = TextStyle(
    fontFamily: 'Manrope',
    fontWeight: FontWeight.w700,
    height: 1.2,
  );

  static const TextStyle manropeExtraBold = TextStyle(
    fontFamily: 'Manrope',
    fontWeight: FontWeight.w800,
    height: 1.1,
  );

  static const TextStyle interRegular = TextStyle(
    fontFamily: 'Inter',
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const TextStyle interMedium = TextStyle(
    fontFamily: 'Inter',
    fontWeight: FontWeight.w500,
    height: 1.5,
  );

  static const TextStyle interSemiBold = TextStyle(
    fontFamily: 'Inter',
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  static const TextStyle interBold = TextStyle(
    fontFamily: 'Inter',
    fontWeight: FontWeight.w700,
    height: 1.33,
  );

  static final TextStyle h1 =
      manropeBold.copyWith(fontSize: 48.0, letterSpacing: -1.2);

  static final TextStyle h2 =
      manropeBold.copyWith(fontSize: 36.0, letterSpacing: -0.9);

  static final TextStyle h3 =
      manropeBold.copyWith(fontSize: 30.0, letterSpacing: -0.75);

  static final TextStyle subtitle =
      manropeSemiBold.copyWith(fontSize: 20.0, letterSpacing: -0.5);

  static final TextStyle bodyLarge = interRegular.copyWith(fontSize: 16.0);

  static final TextStyle bodyMedium = interRegular.copyWith(fontSize: 14.0);

  static final TextStyle bodySmall = interRegular.copyWith(fontSize: 12.0);

  static final TextStyle caption =
      interMedium.copyWith(fontSize: 10.0, letterSpacing: 0.25);

  static final TextStyle label =
      interBold.copyWith(fontSize: 12.0, letterSpacing: 1.2);
}
