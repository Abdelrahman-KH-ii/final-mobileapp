import 'package:farmtec/core/themes/app_fonts.dart';
import 'package:farmtec/core/themes/pallete.dart';
import 'package:farmtec/features/profile/presentation/widgets/profile_card_style.dart';
import 'package:flutter/material.dart';

class ProfileSectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;
  final bool isDark;
  final Color cardColor;

  const ProfileSectionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.child,
    required this.isDark,
    required this.cardColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
      decoration: profileCardDecoration(isDark, cardColor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: Pallete.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppFonts.font(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Pallete.chartGreen : Pallete.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}
