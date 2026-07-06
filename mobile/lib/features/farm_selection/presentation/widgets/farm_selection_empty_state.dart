import 'package:farmtec/core/l10n/app_localizations.dart';
import 'package:farmtec/core/themes/app_fonts.dart';
import 'package:farmtec/core/themes/pallete.dart';
import 'package:flutter/material.dart';

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
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/auth_background.png'),
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/add_illus.png',
                width: 180,
                fit: BoxFit.contain,
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
                textAlign: TextAlign.center,
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
        ),
      ),
    );
  }
}
