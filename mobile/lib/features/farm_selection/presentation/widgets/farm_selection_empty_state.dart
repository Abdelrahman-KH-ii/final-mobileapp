import 'package:farmtec/core/l10n/app_localizations.dart';
import 'package:farmtec/core/themes/app_fonts.dart';
import 'package:farmtec/core/themes/pallete.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FarmSelectionEmptyState extends StatelessWidget {
  final AppLocalizations l;
  final Color textColor;
  final Color subColor;
  final VoidCallback onAddFarm;
  const FarmSelectionEmptyState({
    super.key,
    required this.l,
    required this.textColor,
    required this.subColor,
    required this.onAddFarm,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Pallete.primary.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.agriculture_rounded,
              size: 50,
              color: Pallete.primary.withAlpha(120),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            l.tr('add_first_farm'),
            style: AppFonts.font(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l.tr('add_first_farm_desc'),
            style: AppFonts.font(fontSize: 14, color: subColor),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Pallete.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: onAddFarm,
            icon: const Icon(Icons.add_rounded, size: 20),
            label: Text(
              l.tr('add_farm'),
              style: AppFonts.font(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
