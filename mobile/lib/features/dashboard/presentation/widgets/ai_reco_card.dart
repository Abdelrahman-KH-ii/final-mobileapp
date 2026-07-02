import 'package:farmtec/core/l10n/app_localizations.dart';
import 'package:farmtec/core/themes/app_fonts.dart';
import 'package:farmtec/core/themes/pallete.dart';
import 'package:farmtec/features/dashboard/presentation/widgets/dashboard_action_chip.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AiRecoCard extends StatelessWidget {
  final bool isDark;
  final Color textColor;
  final String farmName;

  const AiRecoCard({
    super.key,
    required this.isDark,
    required this.textColor,
    required this.farmName,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF2D5A27).withAlpha(isDark ? 40 : 20),
            const Color(0xFF4CAF50).withAlpha(isDark ? 50 : 30),
          ],
        ),
        border: Border.all(color: const Color(0xFF4CAF50).withAlpha(75)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Pallete.primary,
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.tr('ai_recommendation').toUpperCase(),
                  style: AppFonts.font(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: isDark
                        ? Pallete.darkTextSecondary
                        : Pallete.secondary,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  l.convertNumbers(l.trParams('ai_reco_apply_urea', {'farm': farmName})),
                  style: AppFonts.font(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    DashboardActionChip(label: l.tr('apply_now'), filled: true),
                    const SizedBox(width: 8),
                    DashboardActionChip(label: l.tr('schedule'), filled: false),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
