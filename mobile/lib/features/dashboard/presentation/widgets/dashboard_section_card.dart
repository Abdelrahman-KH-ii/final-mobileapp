import 'package:farmtec/core/themes/app_theme_colors.dart';
import 'package:farmtec/core/themes/app_fonts.dart';
import 'package:farmtec/core/themes/pallete.dart';import 'package:farmtec/features/dashboard/presentation/widgets/dashboard_card_style.dart';
import 'package:flutter/material.dart';

class DashboardSectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color titleColor;
  final bool isDark;
  final Color cardColor;
  final Widget child;
  final bool centerContent;

  const DashboardSectionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.titleColor,
    required this.isDark,
    required this.cardColor,
    required this.child,
    this.centerContent = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: dashboardCardDecoration(isDark, cardColor),
      child: Column(
        crossAxisAlignment:
            centerContent ? CrossAxisAlignment.center : CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment:
                centerContent ? MainAxisAlignment.center : MainAxisAlignment.start,
            mainAxisSize: centerContent ? MainAxisSize.min : MainAxisSize.max,
            children: [
              Icon(icon, size: 16, color: colors.iconAccent),
              const SizedBox(width: 7),
              Text(
                title,
                style: AppFonts.font(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: titleColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
