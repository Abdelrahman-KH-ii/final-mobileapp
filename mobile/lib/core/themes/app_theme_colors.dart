import 'package:farmtec/core/themes/pallete.dart';
import 'package:flutter/material.dart';

/// Semantic colors for FarmTec UI — use via [Theme.of(context).extension].
@immutable
class AppThemeColors extends ThemeExtension<AppThemeColors> {
  final Color background;
  final Color card;
  final Color surfaceVariant;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color textHint;
  final Color iconAccent;
  final Color outline;
  final Color chipBg;
  final Color elevatedSurface;
  final Color marketUpBg;
  final Color marketDownBg;
  final Color marketUpText;
  final Color marketDownText;
  final Color statGreenTint;
  final Color statCreamTint;
  final Color statPurpleTint;
  final Color statBlueTint;
  final Color shadow;
  final Color divider;

  const AppThemeColors({
    required this.background,
    required this.card,
    required this.surfaceVariant,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.textHint,
    required this.iconAccent,
    required this.outline,
    required this.chipBg,
    required this.elevatedSurface,
    required this.marketUpBg,
    required this.marketDownBg,
    required this.marketUpText,
    required this.marketDownText,
    required this.statGreenTint,
    required this.statCreamTint,
    required this.statPurpleTint,
    required this.statBlueTint,
    required this.shadow,
    required this.divider,
  });

  static const light = AppThemeColors(
    background: Pallete.background,
    card: Pallete.surface,
    surfaceVariant: Pallete.surfaceVariant,
    textPrimary: Pallete.primary,
    textSecondary: Pallete.textSecondary,
    textTertiary: Pallete.textTertiary,
    textHint: Pallete.textHint,
    iconAccent: Pallete.primary,
    outline: Pallete.outline,
    chipBg: Color(0xFFF4F5F2),
    elevatedSurface: Pallete.surface,
    marketUpBg: Pallete.marketUpBg,
    marketDownBg: Pallete.marketDownBg,
    marketUpText: Pallete.marketUp,
    marketDownText: Pallete.marketDown,
    statGreenTint: Color(0xFFEEF6F0),
    statCreamTint: Color(0xFFFFF6ED),
    statPurpleTint: Color(0xFFF4EFF8),
    statBlueTint: Color(0xFFEEF3F7),
    shadow: Color(0x14000000),
    divider: Color(0xFFE8EBE4),
  );

  static const dark = AppThemeColors(
    background: Pallete.darkBackground,
    card: Pallete.darkCard,
    surfaceVariant: Pallete.darkSurfaceVariant,
    textPrimary: Pallete.darkTextPrimary,
    textSecondary: Pallete.darkTextSecondary,
    textTertiary: Pallete.darkTextTertiary,
    textHint: Pallete.darkTextHint,
    iconAccent: Pallete.chartGreen,
    outline: Pallete.darkOutline,
    chipBg: Pallete.darkSurfaceVariant,
    elevatedSurface: Pallete.darkSurface,
    marketUpBg: Color(0xFF14532D),
    marketDownBg: Color(0xFF450A0A),
    marketUpText: Color(0xFF4ADE80),
    marketDownText: Color(0xFFF87171),
    statGreenTint: Color(0xFF1A2E22),
    statCreamTint: Color(0xFF2E2418),
    statPurpleTint: Color(0xFF261E2E),
    statBlueTint: Color(0xFF1A2428),
    shadow: Color(0x40000000),
    divider: Pallete.darkOutline,
  );

  @override
  AppThemeColors copyWith({
    Color? background,
    Color? card,
    Color? surfaceVariant,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? textHint,
    Color? iconAccent,
    Color? outline,
    Color? chipBg,
    Color? elevatedSurface,
    Color? marketUpBg,
    Color? marketDownBg,
    Color? marketUpText,
    Color? marketDownText,
    Color? statGreenTint,
    Color? statCreamTint,
    Color? statPurpleTint,
    Color? statBlueTint,
    Color? shadow,
    Color? divider,
  }) {
    return AppThemeColors(
      background: background ?? this.background,
      card: card ?? this.card,
      surfaceVariant: surfaceVariant ?? this.surfaceVariant,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      textHint: textHint ?? this.textHint,
      iconAccent: iconAccent ?? this.iconAccent,
      outline: outline ?? this.outline,
      chipBg: chipBg ?? this.chipBg,
      elevatedSurface: elevatedSurface ?? this.elevatedSurface,
      marketUpBg: marketUpBg ?? this.marketUpBg,
      marketDownBg: marketDownBg ?? this.marketDownBg,
      marketUpText: marketUpText ?? this.marketUpText,
      marketDownText: marketDownText ?? this.marketDownText,
      statGreenTint: statGreenTint ?? this.statGreenTint,
      statCreamTint: statCreamTint ?? this.statCreamTint,
      statPurpleTint: statPurpleTint ?? this.statPurpleTint,
      statBlueTint: statBlueTint ?? this.statBlueTint,
      shadow: shadow ?? this.shadow,
      divider: divider ?? this.divider,
    );
  }

  @override
  AppThemeColors lerp(ThemeExtension<AppThemeColors>? other, double t) {
    if (other is! AppThemeColors) return this;
    return AppThemeColors(
      background: Color.lerp(background, other.background, t)!,
      card: Color.lerp(card, other.card, t)!,
      surfaceVariant: Color.lerp(surfaceVariant, other.surfaceVariant, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      textHint: Color.lerp(textHint, other.textHint, t)!,
      iconAccent: Color.lerp(iconAccent, other.iconAccent, t)!,
      outline: Color.lerp(outline, other.outline, t)!,
      chipBg: Color.lerp(chipBg, other.chipBg, t)!,
      elevatedSurface: Color.lerp(elevatedSurface, other.elevatedSurface, t)!,
      marketUpBg: Color.lerp(marketUpBg, other.marketUpBg, t)!,
      marketDownBg: Color.lerp(marketDownBg, other.marketDownBg, t)!,
      marketUpText: Color.lerp(marketUpText, other.marketUpText, t)!,
      marketDownText: Color.lerp(marketDownText, other.marketDownText, t)!,
      statGreenTint: Color.lerp(statGreenTint, other.statGreenTint, t)!,
      statCreamTint: Color.lerp(statCreamTint, other.statCreamTint, t)!,
      statPurpleTint: Color.lerp(statPurpleTint, other.statPurpleTint, t)!,
      statBlueTint: Color.lerp(statBlueTint, other.statBlueTint, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
    );
  }
}

extension AppThemeColorsX on BuildContext {
  AppThemeColors get appColors =>
      Theme.of(this).extension<AppThemeColors>() ?? AppThemeColors.light;

  bool get isDarkTheme => Theme.of(this).brightness == Brightness.dark;

  /// Hero screen titles: green in light mode, white in dark mode.
  Color get screenHeaderTitle =>
      isDarkTheme ? Pallete.darkTextPrimary : Pallete.primary;

  /// Subtitle below hero screen titles.
  Color get screenHeaderSubtitle =>
      isDarkTheme
          ? Pallete.darkTextPrimary.withAlpha(210)
          : appColors.textSecondary;
}
