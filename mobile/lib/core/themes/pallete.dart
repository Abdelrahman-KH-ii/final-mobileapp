import 'package:flutter/material.dart';

/// Unified FarmTec color palette — v2.0 harmonized.
abstract class Pallete {
  // ── Brand Colors ────────────────────────────────────────────────────────────
  /// Deep Forest Green — primary brand color
  static const Color primary = Color(0xFF1B4332);

  /// Leaf Green — secondary brand color
  static const Color secondary = Color(0xFF2D6A4F);

  /// Golden Amber — accent highlights
  static const Color accent = Color(0xFFFFB800);

  /// Warm Earth — tertiary / brown accent
  static const Color tertiary = Color(0xFF795548);

  // ── Legacy aliases (to avoid mass-renaming breakage) ─────────────────────
  static const Color primaryColor = primary;
  static const Color secondaryColor = secondary;
  static const Color tertiaryColor = tertiary;

  // ── Light Theme Surface Colors ──────────────────────────────────────────────
  static const Color background = Color(0xFFF3F4ED);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFE2E3DC);
  static const Color backgroudColor = background; // legacy typo alias

  // ── Dark Theme Surface Colors ──────────────────────────────────────────────
  static const Color darkBackground = Color(0xFF000000);
  static const Color darkSurface = Color(0xFF111111);
  static const Color darkCard = Color(0xFF1A1A1A);
  static const Color darkSurfaceVariant = Color(0xFF242424);

  // ── Text Colors — Light ─────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF191C18);
  static const Color textSecondary = Color(0xFF42493E);
  static const Color textTertiary = Color(0xFF6B7280);
  static const Color textHint = Color(0xFF9CA3AF);

  // ── Text Colors — Dark ──────────────────────────────────────────────────────
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFFFFFFF);
  static const Color darkTextTertiary = Color(0xFFFFFFFF);
  static const Color darkTextHint = Color(0xFFDDDDDD);

  // ── Semantic / Functional Colors ────────────────────────────────────────────
  static const Color success = Color(0xFF22C55E);

  /// Unified green for AI model actions (run buttons, stats, accents).
  static const Color aiModelGreen = success;
  static const Color error = Color(0xFFBA1A1A);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF0EA5E9);

  // ── Borders / Outlines ──────────────────────────────────────────────────────
  static const Color outline = Color(0xFFC2C9BB);
  static const Color darkOutline = Color(0xFF2E2E2E);

  // ── Container Colors (for on-primary / on-secondary) ────────────────────────
  static const Color primaryContainer = Color(0xFFBCF0AE);
  static const Color onPrimary = Color(0xFFFFFFFF);

  // ── Overlays ────────────────────────────────────────────────────────────────
  static const Color primaryOverlay = Color(0x191B4332);
  static const Color primaryOverlayMedium = Color(0x4C1B4332);

  // ── Chart / Data Viz Colors ─────────────────────────────────────────────────
  static const Color chartGreen = Color(0xFF4CAF50);
  static const Color chartBlue = Color(0xFF2196F3);
  static const Color chartOrange = Color(0xFFFF9800);
  static const Color chartPurple = Color(0xFF9C27B0);
  static const Color chartCyan = Color(0xFF00BCD4);
  static const Color chartRed = Color(0xFFF44336);

  // ── Gradient helpers ────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [darkBackground, darkSurface],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Neutral shades (used in nav, chips, etc.) ──────────────────────────────
  static const Color neutral100 = Color(0xFFF5F5F5);
  static const Color neutral200 = Color(0xFFE5E7EB);
  static const Color neutral300 = Color(0xFFD1D5DB);
  static const Color neutral400 = Color(0xFF9CA3AF);
  static const Color neutral500 = Color(0xFF6B7280);
  static const Color neutral600 = Color(0xFF4B5563);
  static const Color neutral700 = Color(0xFF374151);
  static const Color neutral800 = Color(0xFF1F2937);

  // ── Market change colors ────────────────────────────────────────────────────
  static const Color marketUp = Color(0xFF16A34A);
  static const Color marketUpBg = Color(0xFFDCFCE7);
  static const Color marketDown = Color(0xFFDC2626);
  static const Color marketDownBg = Color(0xFFFEE2E2);
}
