import 'package:farmtec/core/l10n/app_localizations.dart';
import 'package:farmtec/core/themes/app_fonts.dart';
import 'package:farmtec/core/services/farm_history_service.dart';
import 'package:farmtec/core/themes/app_theme_colors.dart';
import 'package:farmtec/core/themes/pallete.dart';
import 'package:farmtec/features/farm/domain/entities/farm.dart';
import 'package:farmtec/features/farm/presentation/extensions/farm_ui_extensions.dart';
import 'package:farmtec/features/farm/presentation/providers/farm_provider.dart';
import 'package:farmtec/features/farm_selection/presentation/screens/farm_selection_screen.dart';
import 'package:farmtec/features/my_farm/presentation/widgets/edit_farm_sheet.dart';
import 'package:farmtec/features/my_farm/presentation/widgets/farm_activity_tile.dart';
import 'package:farmtec/features/my_farm/presentation/widgets/farm_location_card.dart';
import 'package:farmtec/features/my_farm/presentation/widgets/farm_section_label.dart';
import 'package:farmtec/features/my_farm/presentation/widgets/farm_soil_metrics_card.dart';
import 'package:farmtec/features/my_farm/presentation/widgets/farm_stat_card.dart';
import 'package:farmtec/features/my_farm/presentation/widgets/my_farm_card_style.dart';
import 'package:farmtec/features/my_farm/presentation/screens/full_map_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyFarmView extends StatelessWidget {
  const MyFarmView({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isDark = context.isDarkTheme;
    final l = AppLocalizations.of(context);
    final farmService = Provider.of<FarmProvider>(context);
    final historyService = Provider.of<FarmHistoryService>(context);
    final farm = farmService.selectedFarm;
    final textColor = colors.textPrimary;
    final subColor = colors.textSecondary;
    final cardColor = colors.card;
    final bgColor = colors.background;

    if (farm == null) {
      return Center(
        child: Text(
          l.tr('no_farm_selected'),
          style: AppFonts.font(fontSize: 16, color: subColor),
        ),
      );
    }

    final farmOps = historyService.getForFarm(farm.id);
    final recentOps = farmOps.take(5).toList();
    final areaValue =
        '${l.convertNumbers(farm.area.replaceAll(RegExp(r'\s*ha\s*', caseSensitive: false), '').trim())} ${l.tr('ha')}';
    final plantingFooter =
        farm.plantedAt != null
            ? l.trParams('time_ago_days', {
              'd': l.convertNumbers(
                DateTime.now().difference(farm.plantedAt!).inDays.toString(),
              ),
            })
            : null;

    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SizedBox(
            height: 240 + MediaQuery.of(context).padding.top,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  'assets/images/myfarm_illus.png',
                  fit: BoxFit.cover,
                ),
                Container(
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.black.withAlpha(100)
                        : Colors.white.withAlpha(30),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 100,
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
              ],
            ),
          ),
        ),
        SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            20,
            MediaQuery.of(context).padding.top + 12,
            20,
            100,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _headerButton(
                        icon: Icons.delete_outline_rounded,
                        color: isDark ? colors.marketDownText : Pallete.error,
                        label: l.tr('delete'),
                        colors: colors,
                        isDark: isDark,
                        onTap:
                            () => _confirmDelete(
                              context,
                              farm,
                              farmService,
                              l,
                              isDark,
                            ),
                      ),
                      const SizedBox(width: 8),
                      _headerButton(
                        icon: Icons.edit_rounded,
                        color: context.screenHeaderTitle,
                        label: l.tr('edit'),
                        colors: colors,
                        isDark: isDark,
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) => EditFarmSheet(farm: farm),
                          );
                        },
                      ),
                    ],
                  ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.eco_rounded,
                            size: 16,
                            color: context.screenHeaderTitle,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            l.tr('my_farm'),
                            style: AppFonts.font(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: context.screenHeaderTitle,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l.tr('farm_details'),
                        style: AppFonts.font(
                          fontSize: 12,
                          color: context.screenHeaderSubtitle,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 88),
              Row(
                children: [
                  FarmStatCard(
                    icon: Icons.map_rounded,
                    value: areaValue,
                    label: l.tr('total_area'),
                    accentColor: Pallete.secondary,
                    backgroundColor: colors.statGreenTint,
                    isDark: isDark,
                    actionLabel: l.tr('view_map_btn'),
                    actionIcon: Icons.map_outlined,
                    onAction:
                        (farm.lat != 0 || farm.lng != 0)
                            ? () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => FullMapScreen(farm: farm),
                                ),
                              );
                            }
                            : null,
                  ),
                  const SizedBox(width: 8),
                  FarmStatCard(
                    cropImage: farm.crop,
                    value: l.tr(farm.crop.toLowerCase()),
                    label: l.tr('crop_type'),
                    accentColor: const Color(0xFFC86B1A),
                    backgroundColor: colors.statCreamTint,
                    isDark: isDark,
                    accentValue: false,
                    actionLabel: l.tr('change_crop'),
                    actionIcon: Icons.eco_rounded,
                    onAction: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => EditFarmSheet(farm: farm),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  FarmStatCard(
                    icon: Icons.schedule_rounded,
                    value: farm.lastScan,
                    label: l.tr('last_scan'),
                    accentColor: const Color(0xFF8B6BAF),
                    backgroundColor: colors.statPurpleTint,
                    isDark: isDark,
                    footer: l.trParams('time_ago_days', {
                      'd': l.convertNumbers('3'),
                    }),
                  ),
                  const SizedBox(width: 8),
                  FarmStatCard(
                    icon: Icons.calendar_today_rounded,
                    value: farm.formatPlantingDate(l),
                    label: l.tr('planting_date'),
                    accentColor: const Color(0xFF5B7C99),
                    backgroundColor: colors.statBlueTint,
                    isDark: isDark,
                    accentValue: false,
                    footer: plantingFooter,
                    footerIcon: Icons.calendar_today_rounded,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (farm.lat != 0 || farm.lng != 0) ...[
                FarmLocationCard(
                  farm: farm,
                  isDark: isDark,
                  cardColor: cardColor,
                  textColor: textColor,
                  subColor: subColor,
                ),
                const SizedBox(height: 20),
              ],
              FarmSectionLabel(
                icon: Icons.science_rounded,
                title: l.tr('soil_metrics'),
                color: textColor,
              ),
              const SizedBox(height: 12),
              FarmSoilMetricsCard(
                farm: farm,
                isDark: isDark,
                cardColor: cardColor,
                textColor: textColor,
                subColor: subColor,
              ),
              const SizedBox(height: 20),
              FarmSectionLabel(
                icon: Icons.history_rounded,
                title: l.tr('recent_operations'),
                color: textColor,
              ),
              const SizedBox(height: 12),
              if (farmOps.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: myFarmCardDecoration(isDark, cardColor),
                  child: Center(
                    child: Text(
                      l.tr('no_recent_activity'),
                      style: AppFonts.font(fontSize: 13, color: subColor),
                    ),
                  ),
                )
              else
                Container(
                  decoration: myFarmCardDecoration(isDark, cardColor),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      for (int i = 0; i < recentOps.length; i++)
                        FarmActivityTile(
                          op: recentOps[i],
                          isDark: isDark,
                          textColor: textColor,
                          subColor: subColor,
                          showDivider: i < recentOps.length - 1,
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _headerButton({
    required IconData icon,
    required Color color,
    required String label,
    required AppThemeColors colors,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 56,
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withAlpha(15)
              : Colors.white.withAlpha(230),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark
                ? Colors.white.withAlpha(30)
                : colors.outline.withAlpha(140),
          ),
          boxShadow: [
            BoxShadow(
              color: colors.shadow,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 3),
            Text(
              label,
              style: AppFonts.font(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    Farm farm,
    FarmProvider farmService,
    AppLocalizations l,
    bool isDark,
  ) {
    final colors = context.appColors;
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            backgroundColor: colors.card,
            title: Text(
              l.tr('delete_farm') == 'delete_farm'
                  ? 'Delete Farm'
                  : l.tr('delete_farm'),
              style: AppFonts.font(
                fontWeight: FontWeight.w800,
                color: colors.textPrimary,
              ),
            ),
            content: Text(
              '${l.tr('confirm_delete') == 'confirm_delete' ? 'Are you sure you want to delete' : l.tr('confirm_delete')} ${farm.name}?',
              style: AppFonts.font(
                color: colors.textSecondary,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(
                  l.tr('cancel') == 'cancel' ? 'Cancel' : l.tr('cancel'),
                  style: AppFonts.font(
                    fontWeight: FontWeight.w700,
                    color: colors.textSecondary,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  farmService.removeFarm(farm.id);
                  Navigator.pop(ctx);
                  Navigator.pushReplacementNamed(
                    context,
                    FarmSelectionScreen.routeName,
                  );
                },
                child: Text(
                  l.tr('delete') == 'delete' ? 'Delete' : l.tr('delete'),
                  style: AppFonts.font(
                    fontWeight: FontWeight.w700,
                    color: Colors.redAccent,
                  ),
                ),
              ),
            ],
          ),
    );
  }
}
