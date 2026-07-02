import 'package:farmtec/core/providers/locale_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Dynamic font selection based on active app language.
/// Uses Cairo for Arabic (modern, geometric, highly legible Kufic style)
/// and Plus Jakarta Sans for English (premium, clean, geometric sans-serif).
abstract class AppFonts {
  static TextStyle font({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<Shadow>? shadows,
    List<FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    if (LocaleProvider.currentLanguageCode == 'ar') {
      return GoogleFonts.cairo(
        textStyle: textStyle,
        color: color,
        backgroundColor: backgroundColor,
        fontSize: fontSize,
        fontWeight: fontWeight,
        fontStyle: fontStyle,
        letterSpacing: letterSpacing,
        wordSpacing: wordSpacing,
        textBaseline: textBaseline,
        height: height,
        locale: locale,
        foreground: foreground,
        background: background,
        shadows: shadows,
        fontFeatures: fontFeatures,
        decoration: decoration,
        decorationColor: decorationColor,
        decorationStyle: decorationStyle,
        decorationThickness: decorationThickness,
      );
    } else {
      return GoogleFonts.plusJakartaSans(
        textStyle: textStyle,
        color: color,
        backgroundColor: backgroundColor,
        fontSize: fontSize,
        fontWeight: fontWeight,
        fontStyle: fontStyle,
        letterSpacing: letterSpacing,
        wordSpacing: wordSpacing,
        textBaseline: textBaseline,
        height: height,
        locale: locale,
        foreground: foreground,
        background: background,
        shadows: shadows,
        fontFeatures: fontFeatures,
        decoration: decoration,
        decorationColor: decorationColor,
        decorationStyle: decorationStyle,
        decorationThickness: decorationThickness,
      );
    }
  }

  /// TextTheme versions for ThemeData setup
  static TextTheme get textTheme {
    if (LocaleProvider.currentLanguageCode == 'ar') {
      return GoogleFonts.cairoTextTheme();
    } else {
      return GoogleFonts.plusJakartaSansTextTheme();
    }
  }

  static TextTheme textThemeWith(TextTheme base) {
    if (LocaleProvider.currentLanguageCode == 'ar') {
      return GoogleFonts.cairoTextTheme(base);
    } else {
      return GoogleFonts.plusJakartaSansTextTheme(base);
    }
  }
}
