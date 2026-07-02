import 'package:farmtec/core/l10n/app_localizations.dart';
import 'package:farmtec/core/services/app_notification_service.dart';
import 'package:farmtec/core/services/notification_settings_service.dart';
import 'package:farmtec/core/services/push_notification_service.dart';
import 'package:farmtec/core/themes/app_fonts.dart';
import 'package:farmtec/core/themes/app_theme_colors.dart';
import 'package:farmtec/core/themes/pallete.dart';
import 'package:farmtec/features/notifications/presentation/widgets/notification_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  static const routeName = 'notifications';

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  NotifType? _filter;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _refreshAlerts());
  }

  Future<void> _refreshAlerts() async {
    setState(() => _loading = true);
    final notifService =
        Provider.of<AppNotificationService>(context, listen: false);
    final settings =
        Provider.of<NotificationSettingsService>(context, listen: false);
    await notifService.load();
    await notifService.fetchDynamicAlerts(settings);
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _enablePush() async {
    final settings =
        Provider.of<NotificationSettingsService>(context, listen: false);
    await settings.setPushEnabled(true);
    await _refreshAlerts();
  }

  List<AppNotification> _filteredItems(List<AppNotification> items) {
    if (_filter == null) return items;
    return items.where((item) => item.type == _filter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colors = context.appColors;
    final isDark = context.isDarkTheme;
    final notifService = Provider.of<AppNotificationService>(context);
    final settings = Provider.of<NotificationSettingsService>(context);
    final items = _filteredItems(notifService.notifications);
    final bgColor = colors.background;
    final textColor = colors.textPrimary;
    final subColor = colors.textSecondary;
    final cardColor = colors.card;
    final topPadding = MediaQuery.of(context).padding.top;
    const heroHeight = 180.0;
    final pushGranted = PushNotificationService.instance.permissionGranted;

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: topPadding,
            child: ColoredBox(color: bgColor),
          ),
          Positioned(
            top: topPadding,
            left: 0,
            right: 0,
            child: SizedBox(
              height: heroHeight,
              child: Stack(
                fit: StackFit.expand,
                clipBehavior: Clip.hardEdge,
                children: [
                  Image.asset(
                    'assets/images/dashboard_illus.png',
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.black.withAlpha(120)
                          : Colors.white.withAlpha(35),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [bgColor.withAlpha(0), bgColor],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(16, topPadding + 8, 16, 0),
                child: Row(
                  children: [
                    _CircleHeaderButton(
                      icon: Icons.arrow_back_rounded,
                      onTap: () => Navigator.pop(context),
                      isDark: isDark,
                      colors: colors,
                    ),
                    const Spacer(),
                    if (notifService.unreadCount > 0)
                      TextButton(
                        onPressed: () =>
                            notifService.markAllRead(),
                        child: Text(
                          l.tr('mark_all_read'),
                          style: AppFonts.font(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Pallete.chartGreen : Pallete.primary,
                          ),
                        ),
                      ),
                    _CircleHeaderButton(
                      icon: Icons.delete_sweep_outlined,
                      onTap: notifService.notifications.isEmpty
                          ? null
                          : () => notifService.clearAll(),
                      isDark: isDark,
                      colors: colors,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.notifications_active_rounded,
                          color: context.screenHeaderTitle,
                          size: 22,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          l.tr('notifications'),
                          style: AppFonts.font(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: context.screenHeaderTitle,
                          ),
                        ),
                        if (notifService.unreadCount > 0) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Pallete.chartGreen.withAlpha(40)
                                  : Pallete.primary.withAlpha(20),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              l.convertNumbers(
                                '${notifService.unreadCount}',
                              ),
                              style: AppFonts.font(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: isDark
                                    ? Pallete.chartGreen
                                    : Pallete.primary,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l.tr('notifications_subtitle'),
                      style: AppFonts.font(
                        fontSize: 12,
                        color: context.screenHeaderSubtitle,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: RefreshIndicator(
                  color: isDark ? Pallete.chartGreen : Pallete.primary,
                  onRefresh: _refreshAlerts,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    children: [
                      if (!settings.pushEnabled || !pushGranted)
                        _PushBanner(
                          l: l,
                          colors: colors,
                          cardColor: cardColor,
                          isDark: isDark,
                          pushDisabled: !settings.pushEnabled,
                          onEnable: _enablePush,
                        ),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: colors.shadow,
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: _FilterChip(
                                label: l.tr('all_commodities'),
                                selected: _filter == null,
                                onTap: () => setState(() => _filter = null),
                                isDark: isDark,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _FilterChip(
                                label: l.tr('weather_alerts'),
                                selected: _filter == NotifType.weather,
                                onTap: () => setState(
                                  () => _filter = NotifType.weather,
                                ),
                                isDark: isDark,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _FilterChip(
                                label: l.tr('market_price_alerts'),
                                selected: _filter == NotifType.market,
                                onTap: () => setState(
                                  () => _filter = NotifType.market,
                                ),
                                isDark: isDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_loading)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (items.isEmpty)
                        _EmptyState(
                          l: l,
                          subColor: subColor,
                          textColor: textColor,
                          pushEnabled: settings.pushEnabled,
                        )
                      else
                        ...items.map(
                          (item) => NotificationCard(
                            item: item,
                            onTap: () => notifService.markAsRead(item.id),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CircleHeaderButton extends StatelessWidget {
  const _CircleHeaderButton({
    required this.icon,
    required this.onTap,
    required this.isDark,
    required this.colors,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final bool isDark;
  final AppThemeColors colors;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isDark
          ? Colors.white.withAlpha(18)
          : Colors.white.withAlpha(230),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isDark
                  ? Colors.white.withAlpha(30)
                  : colors.outline.withAlpha(120),
            ),
          ),
          child: Icon(
            icon,
            size: 20,
            color: onTap == null ? colors.textHint : colors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _PushBanner extends StatelessWidget {
  const _PushBanner({
    required this.l,
    required this.colors,
    required this.cardColor,
    required this.isDark,
    required this.pushDisabled,
    required this.onEnable,
  });

  final AppLocalizations l;
  final AppThemeColors colors;
  final Color cardColor;
  final bool isDark;
  final bool pushDisabled;
  final VoidCallback onEnable;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Pallete.warning.withAlpha(isDark ? 80 : 50),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Pallete.warning.withAlpha(isDark ? 40 : 25),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.notifications_off_outlined,
              color: Pallete.warning,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              pushDisabled
                  ? l.tr('notifications_off')
                  : l.tr('enable_push_prompt'),
              style: AppFonts.font(
                fontSize: 12,
                color: colors.textSecondary,
                height: 1.4,
              ),
            ),
          ),
          if (pushDisabled)
            TextButton(
              onPressed: onEnable,
              child: Text(
                l.tr('enable'),
                style: AppFonts.font(
                  fontWeight: FontWeight.w800,
                  color: isDark ? Pallete.chartGreen : Pallete.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.isDark,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final activeColor = isDark ? Pallete.chartGreen : Pallete.primary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? activeColor.withAlpha(isDark ? 35 : 18)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? activeColor.withAlpha(isDark ? 100 : 80)
                : context.appColors.outline.withAlpha(80),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppFonts.font(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: selected ? activeColor : context.appColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.l,
    required this.subColor,
    required this.textColor,
    required this.pushEnabled,
  });

  final AppLocalizations l;
  final Color subColor;
  final Color textColor;
  final bool pushEnabled;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: context.appColors.chipBg,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_none_rounded,
              size: 34,
              color: subColor,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            pushEnabled
                ? l.tr('no_notifications_match')
                : l.tr('notifications_off'),
            style: AppFonts.font(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            l.tr('notifications_empty_hint'),
            style: AppFonts.font(fontSize: 12, color: subColor, height: 1.5),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
