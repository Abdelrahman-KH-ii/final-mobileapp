import 'package:farmtec/core/l10n/app_localizations.dart';
import 'package:farmtec/core/themes/app_fonts.dart';
import 'package:farmtec/core/themes/app_theme_colors.dart';
import 'package:farmtec/core/themes/pallete.dart';
import 'package:farmtec/features/farm/presentation/providers/farm_provider.dart';
import 'package:farmtec/features/farm_selection/presentation/widgets/add_farm_sheet.dart';
import 'package:farmtec/features/farm_selection/presentation/widgets/farm_history_tab.dart';
import 'package:farmtec/features/farm_selection/presentation/widgets/farm_tec_logo.dart';
import 'package:farmtec/features/farm_selection/presentation/widgets/farms_tab.dart';
import 'package:farmtec/features/home/presentation/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class FarmSelectionScreen extends StatefulWidget {
  const FarmSelectionScreen({super.key});
  static const String routeName = 'farm_selection';

  @override
  State<FarmSelectionScreen> createState() => _FarmSelectionScreenState();
}

class _FarmSelectionScreenState extends State<FarmSelectionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isDark = context.isDarkTheme;
    final l = AppLocalizations.of(context);
    final farmService = Provider.of<FarmProvider>(context);
    final textColor = colors.textPrimary;
    final subColor = colors.textSecondary;
    final bgColor = colors.background;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FarmTecLogo(isDark: isDark),
                  const SizedBox(height: 24),
                  Text(
                    l.tr('select_farm'),
                    style: AppFonts.font(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l.tr('select_farm_subtitle'),
                    style: AppFonts.font(fontSize: 14, color: subColor),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),

            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: colors.chipBg,
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.all(4),
              child: TabBar(
                controller: _tabCtrl,
                indicator: BoxDecoration(
                  color: colors.card,
                  borderRadius: BorderRadius.circular(11),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(12),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelColor: textColor,
                unselectedLabelColor: subColor,
                labelStyle: AppFonts.font(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
                unselectedLabelStyle: AppFonts.font(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                tabs: [
                  Tab(text: l.tr('farms')),
                  Tab(text: l.tr('recent_activity')),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: TabBarView(
                controller: _tabCtrl,
                children: [
                  FarmsTab(onAddFarm: () => _showAddFarmSheet(context)),
                  const FarmHistoryTab(),
                ],
              ),
            ),

            if (farmService.farms.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Pallete.primary,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Pallete.primary.withAlpha(
                            80,
                          ),
                          disabledForegroundColor: Colors.white54,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed:
                            farmService.selectedFarm != null
                                ? () => Navigator.pushReplacementNamed(
                                  context,
                                  HomeScreen.routeName,
                                )
                                : null,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              l.tr('continue_text'),
                              style: AppFonts.font(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward_rounded, size: 20),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: () => _showAddFarmSheet(context),
                      icon: const Icon(
                        Icons.add_rounded,
                        size: 18,
                        color: Pallete.accent,
                      ),
                      label: Text(
                        l.tr('add_farm'),
                        style: AppFonts.font(
                          fontWeight: FontWeight.w600,
                          color: Pallete.accent,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showAddFarmSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddFarmSheet(),
    );
  }
}
