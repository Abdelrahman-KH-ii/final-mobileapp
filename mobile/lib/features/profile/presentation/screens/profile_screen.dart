import 'package:farmtec/core/l10n/app_localizations.dart';
import 'package:farmtec/core/themes/app_fonts.dart';
import 'package:farmtec/core/providers/locale_provider.dart';
import 'package:farmtec/core/providers/theme_provider.dart';
import 'package:farmtec/features/farm/presentation/providers/farm_provider.dart';
import 'package:farmtec/core/services/notification_settings_service.dart';
import 'package:farmtec/core/themes/app_theme_colors.dart';
import 'package:farmtec/core/themes/pallete.dart';
import 'package:farmtec/features/profile/presentation/screens/support_info_screen.dart';
import 'package:farmtec/features/profile/presentation/widgets/profile_change_password_sheet.dart';
import 'package:farmtec/features/profile/presentation/widgets/profile_edit_profile_sheet.dart';
import 'package:farmtec/features/profile/presentation/widgets/profile_language_picker.dart';
import 'package:farmtec/features/profile/presentation/widgets/profile_section_card.dart';
import 'package:farmtec/features/profile/presentation/widgets/profile_settings_tile.dart';
import 'package:farmtec/features/profile/presentation/widgets/profile_stat_card.dart';
import 'package:farmtec/features/profile/presentation/widgets/profile_switch_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  static const routeName = 'profile';

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Widget _headerIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: const Color(0xFF0C291F).withAlpha(220),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(30),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isDark = context.isDarkTheme;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);
    final farmService = Provider.of<FarmProvider>(context);
    final notificationSettings = Provider.of<NotificationSettingsService>(
      context,
    );
    final l = AppLocalizations.of(context);
    final farm = farmService.selectedFarm;
    final textColor = colors.textPrimary;
    final bgColor = colors.background;
    final cardColor = colors.card;
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // ── Illustration header ────────────────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 230 + topPadding,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/images/myfarm_illus.png',
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 90,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            bgColor.withAlpha(0),
                            bgColor,
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.black.withAlpha(80)
                          : Colors.white.withAlpha(25),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Scrollable content ─────────────────────────────────────────────
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(20, topPadding + 12, 20, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _headerIconButton(
                            icon: Icons.edit_rounded,
                            onTap: () => _showEditProfile(context, l),
                          ),
                          _headerIconButton(
                            icon: Icons.arrow_back_rounded,
                            onTap: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 36),
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            color:
                                isDark
                                    ? colors.chipBg
                                    : const Color(0xFF4B5563),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withAlpha(180),
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(30),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.person_rounded,
                            color: Colors.white,
                            size: 42,
                          ),
                        ),
                        Positioned(
                          bottom: 4,
                          right: 4,
                          child: Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              color: const Color(0xFF22C55E),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l.tr('profile_user_name'),
                      style: AppFonts.font(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: isDark ? colors.iconAccent : colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    ProfileSectionCard(
                      icon: Icons.bar_chart_rounded,
                      title: l.tr('farm_statistics'),
                      isDark: isDark,
                      cardColor: cardColor,
                      child: IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ProfileStatCard(
                              farm?.area ?? '42.2 ha',
                              l.tr('total_area'),
                              Icons.map_rounded,
                              const Color(0xFF4CAF50),
                              isDark: isDark,
                            ),
                            Container(
                              width: 1,
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              color:
                                  isDark
                                      ? colors.outline
                                      : Pallete.neutral200,
                            ),
                            ProfileStatCard(
                              l.convertNumbers(
                                farmService.farms.length.toString(),
                              ),
                              l.tr('farms'),
                              Icons.terrain_rounded,
                              const Color(0xFF2196F3),
                              isDark: isDark,
                            ),
                          ],
                        ),
                      ),
                    ),

                    ProfileSectionCard(
                      icon: Icons.palette_outlined,
                      title: l.tr('appearance'),
                      isDark: isDark,
                      cardColor: cardColor,
                      child: ProfileSwitchTile(
                        icon: Icons.dark_mode_rounded,
                        label: l.tr('dark_mode'),
                        value: isDark,
                        onChanged: (_) => themeProvider.toggle(),
                        isDark: isDark,
                        textColor: textColor,
                      ),
                    ),

                    ProfileSectionCard(
                      icon: Icons.language_rounded,
                      title: l.tr('language'),
                      isDark: isDark,
                      cardColor: cardColor,
                      child: ProfileLanguagePicker(
                        isDark: isDark,
                        textColor: textColor,
                        localeProvider: localeProvider,
                      ),
                    ),

                    ProfileSectionCard(
                      icon: Icons.person_outline_rounded,
                      title: l.tr('account'),
                      isDark: isDark,
                      cardColor: cardColor,
                      child: Column(
                        children: [
                          ProfileSettingsTile(
                            icon: Icons.person_outline_rounded,
                            label: l.tr('edit_profile'),
                            isDark: isDark,
                            textColor: textColor,
                            onTap: () => _showEditProfile(context, l),
                          ),
                          ProfileSettingsTile(
                            icon: Icons.lock_outline_rounded,
                            label: l.tr('change_password'),
                            isDark: isDark,
                            textColor: textColor,
                            showDivider: true,
                            onTap: () => _showChangePassword(context, l),
                          ),
                        ],
                      ),
                    ),

                    ProfileSectionCard(
                      icon: Icons.notifications_outlined,
                      title: l.tr('notifications'),
                      isDark: isDark,
                      cardColor: cardColor,
                      child: Column(
                        children: [
                          ProfileSwitchTile(
                            icon: Icons.notifications_outlined,
                            label: l.tr('push_notifications'),
                            value: notificationSettings.pushEnabled,
                            onChanged: notificationSettings.setPushEnabled,
                            isDark: isDark,
                            textColor: textColor,
                          ),
                          ProfileSwitchTile(
                            icon: Icons.wb_cloudy_outlined,
                            label: l.tr('weather_alerts'),
                            value: notificationSettings.weatherSwitchValue,
                            onChanged: notificationSettings.setWeatherAlerts,
                            isDark: isDark,
                            textColor: textColor,
                            showDivider: true,
                          ),
                          ProfileSwitchTile(
                            icon: Icons.show_chart_rounded,
                            label: l.tr('market_price_alerts'),
                            value: notificationSettings.marketSwitchValue,
                            onChanged: notificationSettings.setMarketPriceAlerts,
                            isDark: isDark,
                            textColor: textColor,
                            showDivider: true,
                          ),
                        ],
                      ),
                    ),

                    ProfileSectionCard(
                      icon: Icons.support_agent_rounded,
                      title: l.tr('support'),
                      isDark: isDark,
                      cardColor: cardColor,
                      child: Column(
                        children: [
                          ProfileSettingsTile(
                            icon: Icons.help_outline_rounded,
                            label: l.tr('help_faq'),
                            isDark: isDark,
                            textColor: textColor,
                            onTap:
                                () => Navigator.pushNamed(
                                  context,
                                  SupportInfoScreen.helpRouteName,
                                ),
                          ),
                          ProfileSettingsTile(
                            icon: Icons.privacy_tip_outlined,
                            label: l.tr('privacy_policy'),
                            isDark: isDark,
                            textColor: textColor,
                            showDivider: true,
                            onTap:
                                () => Navigator.pushNamed(
                                  context,
                                  SupportInfoScreen.privacyRouteName,
                                ),
                          ),
                          ProfileSettingsTile(
                            icon: Icons.info_outline_rounded,
                            label: l.tr('about_us'),
                            isDark: isDark,
                            textColor: textColor,
                            showDivider: true,
                            onTap:
                                () => Navigator.pushNamed(
                                  context,
                                  SupportInfoScreen.aboutRouteName,
                                ),
                          ),
                          ProfileSettingsTile(
                            icon: Icons.contact_support_outlined,
                            label: l.tr('contact'),
                            isDark: isDark,
                            textColor: textColor,
                            showDivider: true,
                            onTap:
                                () => Navigator.pushNamed(
                                  context,
                                  SupportInfoScreen.contactRouteName,
                                ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFDC2626),
                          side: const BorderSide(
                            color: Color(0xFFDC2626),
                            width: 1.5,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () => _confirmLogout(context, l),
                        icon: const Icon(Icons.logout_rounded),
                        label: Text(
                          l.tr('sign_out'),
                          style: AppFonts.font(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showEditProfile(BuildContext context, AppLocalizations l) {
    final isDark = context.isDarkTheme;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ProfileEditProfileSheet(isDark: isDark, l: l),
    );
  }

  void _showChangePassword(BuildContext context, AppLocalizations l) {
    final isDark = context.isDarkTheme;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ProfileChangePasswordSheet(isDark: isDark, l: l),
    );
  }

  void _confirmLogout(BuildContext context, AppLocalizations l) {
    final colors = context.appColors;
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            backgroundColor: colors.card,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              l.tr('sign_out_confirm'),
              style: AppFonts.font(
                fontWeight: FontWeight.w800,
                color: colors.textPrimary,
              ),
            ),
            content: Text(
              l.tr('sign_out_message'),
              style: AppFonts.font(
                fontSize: 14,
                color: colors.textSecondary,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  l.tr('cancel'),
                  style: AppFonts.font(
                    fontWeight: FontWeight.w700,
                    color: Pallete.primary,
                  ),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDC2626),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    'login',
                    (_) => false,
                  );
                },
                child: Text(
                  l.tr('sign_out'),
                  style: AppFonts.font(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
    );
  }
}
