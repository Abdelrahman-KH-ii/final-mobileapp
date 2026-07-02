import 'package:farmtec/core/l10n/app_localizations.dart';
import 'package:farmtec/core/themes/app_fonts.dart';
import 'package:farmtec/core/services/crop_lifecycle_service.dart';
import 'package:farmtec/core/themes/app_theme_colors.dart';
import 'package:farmtec/core/themes/pallete.dart';
import 'package:farmtec/core/widgets/crop_avatar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FarmSheetField extends StatelessWidget {
  final String label;
  final TextEditingController ctrl;
  final IconData icon;
  final bool isDark;
  final Color fillColor;
  final Color textColor;
  final TextInputType type;
  const FarmSheetField({
    super.key,
    required this.label,
    required this.ctrl,
    required this.icon,
    required this.isDark,
    required this.fillColor,
    required this.textColor,
    this.type = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return TextField(
      controller: ctrl,
      keyboardType: type,
      style: AppFonts.font(fontSize: 14, color: textColor),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppFonts.font(fontSize: 13, color: colors.textHint),
        prefixIcon: Icon(icon, size: 18, color: textColor),
        filled: true,
        fillColor: fillColor,
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
      ),
    );
  }
}

class FarmSheetDropdown extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final IconData icon;
  final bool isDark;
  final Color fillColor;
  final Color textColor;

  const FarmSheetDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.icon,
    required this.isDark,
    required this.fillColor,
    required this.textColor,
  });

  Widget _cropRow(BuildContext context, String crop) {
    final l = AppLocalizations.of(context);
    return Row(
      children: [
        CropThumbnail(crop: crop, size: 28, isDark: isDark),
        const SizedBox(width: 12),
        Text(
          l.tr(CropLifecycleService.cropL10nKey(crop)),
          style: AppFonts.font(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return DropdownButtonFormField<String>(
      value: value,
      items:
          items
              .map(
                (e) => DropdownMenuItem(value: e, child: _cropRow(context, e)),
              )
              .toList(),
      selectedItemBuilder:
          (context) => items.map((e) => _cropRow(context, e)).toList(),
      onChanged: onChanged,
      icon: Icon(Icons.keyboard_arrow_down_rounded, color: textColor),
      style: AppFonts.font(fontSize: 15, color: textColor),
      dropdownColor: colors.card,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppFonts.font(fontSize: 13, color: colors.textHint),
        filled: true,
        fillColor: fillColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
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
      ),
    );
  }
}
