import 'package:farmtec/core/l10n/app_localizations.dart';
import 'package:farmtec/core/services/app_notification_service.dart';
import 'package:farmtec/core/themes/app_fonts.dart';
import 'package:farmtec/core/providers/theme_provider.dart';
import 'package:farmtec/core/themes/pallete.dart';
import 'package:farmtec/features/dashboard/presentation/widgets/dashboard_icon_button.dart';
import 'package:farmtec/features/farm_selection/presentation/screens/farm_selection_screen.dart';
import 'package:farmtec/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:farmtec/features/profile/presentation/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DashboardHeader extends StatelessWidget {
  final String farmName;
  final bool isDark;
  final Color textColor;
  final Color subColor;

  const DashboardHeader({
    super.key,
    required this.farmName,
    required this.isDark,
    required this.textColor,
    required this.subColor,
  });

  String _getInitial(String name) {
    if (name.isEmpty) return '?';
    return name[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final l = AppLocalizations.of(context);

    final unreadCount = context.watch<AppNotificationService>().unreadCount;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // ── Left: Notification + Dark mode ──
        DashboardIconButton(
          icon: Icons.notifications_rounded,
          isDark: isDark,
          hasBadge: unreadCount > 0,
          badgeCount: unreadCount,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NotificationsScreen()),
          ),
        ),
        const SizedBox(width: 10),
        DashboardIconButton(
          icon: themeProvider.isDark
              ? Icons.light_mode_rounded
              : Icons.dark_mode_rounded,
          isDark: isDark,
          onTap: () => themeProvider.toggle(),
        ),
        const Spacer(),
        // ── Right: Greeting + Name + Avatar ──
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l.tr('good_morning'),
              style: AppFonts.font(fontSize: 12, color: subColor),
            ),
            const SizedBox(height: 2),
            GestureDetector(
              onTap: () => Navigator.pushReplacementNamed(
                context,
                FarmSelectionScreen.routeName,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Pallete.primary.withAlpha(20),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.swap_horiz_rounded,
                      size: 14,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    farmName,
                    style: AppFonts.font(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProfileScreen()),
          ),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Pallete.primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Pallete.primary.withAlpha(60),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.person_rounded,
                size: 22,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
