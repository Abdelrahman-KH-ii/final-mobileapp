import 'package:farmtec/core/l10n/app_localizations.dart';
import 'package:farmtec/features/farm/domain/entities/farm.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

extension FarmUiExtensions on Farm {
  Color get healthColor {
    switch (health) {
      case 'warning':
        return const Color(0xFFFF9800);
      case 'critical':
        return const Color(0xFFF44336);
      default:
        return const Color(0xFF4CAF50);
    }
  }

  String get healthLabel {
    switch (health) {
      case 'warning':
        return 'Warning';
      case 'critical':
        return 'Critical';
      default:
        return 'Healthy';
    }
  }

  IconData get healthIcon {
    switch (health) {
      case 'warning':
        return Icons.warning_amber_rounded;
      case 'critical':
        return Icons.error_rounded;
      default:
        return Icons.check_circle_rounded;
    }
  }

  String formatPlantingDate(AppLocalizations l) {
    if (plantedAt == null) return l.tr('no_planting_date');
    final locale = l.isArabic ? 'ar' : 'en';
    return l.convertNumbers(DateFormat.yMMMd(locale).format(plantedAt!));
  }
}
