import 'package:farmtec/core/themes/app_theme_colors.dart';
import 'package:farmtec/core/services/app_notification_service.dart';
import 'package:farmtec/core/services/notification_settings_service.dart';
import 'package:farmtec/features/ai_models/presentation/widgets/ai_models_view.dart';
import 'package:farmtec/features/chat/presentation/screens/farmbrain_chat_screen.dart';
import 'package:farmtec/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:farmtec/features/home/presentation/widgets/custom_bottom_nav_bar.dart';
import 'package:farmtec/features/market/presentation/widgets/market_view.dart';
import 'package:farmtec/features/my_farm/presentation/widgets/my_farm_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const String routeName = 'home';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrapNotifications());
  }

  Future<void> _bootstrapNotifications() async {
    if (!mounted) return;
    final notifService = context.read<AppNotificationService>();
    final settings = context.read<NotificationSettingsService>();
    await notifService.load();
    await notifService.fetchDynamicAlerts(settings);
  }

  static const List<Widget> _pages = [
    DashboardScreen(),
    MyFarmView(),
    AIModelsView(),
    MarketView(),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Scaffold(
      backgroundColor: colors.background,
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              child: KeyedSubtree(
                key: ValueKey(_currentIndex),
                child: _pages[_currentIndex],
              ),
            ),
          ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: CustomBottomNavBar(
                currentIndex: _currentIndex,
                onIndexChanged: (index) =>
                    setState(() => _currentIndex = index),
                onChatPressed: () {
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) =>
                          const FarmBrainChatScreen(),
                      transitionsBuilder: (_, anim, __, child) {
                        return SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 1),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: anim,
                              curve: Curves.easeOutCubic,
                            ),
                          ),
                          child: child,
                        );
                      },
                      transitionDuration: const Duration(milliseconds: 400),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
    );
  }
}
