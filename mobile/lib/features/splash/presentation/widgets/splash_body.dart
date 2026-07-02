import 'package:farmtec/core/l10n/app_localizations.dart';
import 'package:farmtec/core/themes/app_fonts.dart';
import 'package:farmtec/core/themes/app_theme_colors.dart';
import 'package:farmtec/core/themes/pallete.dart';
import 'package:farmtec/features/splash/presentation/widgets/splash_particles.dart';
import 'package:farmtec/core/services/preferences_service.dart';
import 'package:farmtec/core/services/auth_service.dart';
import 'package:farmtec/features/farm/presentation/providers/farm_provider.dart';
import 'package:farmtec/features/farm_selection/presentation/screens/farm_selection_screen.dart';
import 'package:provider/provider.dart';
import 'package:farmtec/features/auth/presentation/screens/login_screen.dart';
import 'package:farmtec/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashBody extends StatefulWidget {
  const SplashBody({super.key});

  @override
  State<SplashBody> createState() => _SplashBodyState();
}

class _SplashBodyState extends State<SplashBody> with TickerProviderStateMixin {
  late final AnimationController _mainCtrl;
  late final AnimationController _pulseCtrl;
  late final AnimationController _particleCtrl;

  late final Animation<double> _iconScale;
  late final Animation<double> _iconRotate;
  late final Animation<double> _titleSlide;
  late final Animation<double> _subtitleSlide;
  late final Animation<double> _fadeOut;

  @override
  void initState() {
    super.initState();

    _mainCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    );

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _particleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..repeat();

    // Icon: grow from 0 → 1 (0..40%)
    _iconScale = CurvedAnimation(
      parent: _mainCtrl,
      curve: const Interval(0.0, 0.4, curve: Curves.elasticOut),
    );

    // Icon: subtle rotation
    _iconRotate = Tween<double>(begin: -0.1, end: 0.0).animate(
      CurvedAnimation(
        parent: _mainCtrl,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    // Title: slide up + fade (30..55%)
    _titleSlide = CurvedAnimation(
      parent: _mainCtrl,
      curve: const Interval(0.3, 0.55, curve: Curves.easeOutCubic),
    );

    // Subtitle: slide up + fade (45..70%)
    _subtitleSlide = CurvedAnimation(
      parent: _mainCtrl,
      curve: const Interval(0.45, 0.7, curve: Curves.easeOutCubic),
    );

    // Fade-out everything (85..100%)
    _fadeOut = CurvedAnimation(
      parent: _mainCtrl,
      curve: const Interval(0.85, 1.0, curve: Curves.easeIn),
    );

    _mainCtrl.forward().then((_) async {
      if (!mounted) return;
      final seen = await PreferencesService.isOnboardingSeen();
      if (!mounted) return;
      final auth = context.read<AuthService>();
      final restored = await auth.restoreSession();
      if (!mounted) return;
      if (restored) {
        await context.read<FarmProvider>().refresh();
      }
      if (!mounted) return;
      final destination = restored
          ? FarmSelectionScreen.routeName
          : (seen ? LoginScreen.routeName : OnboardingScreen.routeName);
      Navigator.pushReplacementNamed(context, destination);
    });
  }

  @override
  void dispose() {
    _mainCtrl.dispose();
    _pulseCtrl.dispose();
    _particleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colors = context.appColors;
    final isDark = context.isDarkTheme;
    final bgColor = colors.background;
    final textColor = colors.textPrimary;
    final subColor = colors.textSecondary;

    return AnimatedBuilder(
      animation: Listenable.merge([_mainCtrl, _pulseCtrl, _particleCtrl]),
      builder: (context, _) {
        final fadeOutOpacity = 1.0 - _fadeOut.value;

        return Scaffold(
          backgroundColor: bgColor,
          body: Opacity(
            opacity: fadeOutOpacity.clamp(0.0, 1.0),
            child: Stack(
              children: [
                SplashParticles(
                  particleAnimation: _particleCtrl,
                  iconScale: _iconScale,
                  isDark: isDark,
                ),

                // ── Gradient ring behind icon ──
                Center(
                  child: Transform.scale(
                    scale: _iconScale.value * (1 + _pulseCtrl.value * 0.06),
                    child: Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Pallete.primary.withAlpha(
                              (40 + _pulseCtrl.value * 30).toInt(),
                            ),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // ── Main content ──
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // App icon
                      Transform.rotate(
                        angle: _iconRotate.value,
                        child: Transform.scale(
                          scale: _iconScale.value,
                          child: Container(
                            width: 96,
                            height: 96,
                            decoration: BoxDecoration(
                              color: Pallete.primary,
                              borderRadius: BorderRadius.circular(28),
                              boxShadow: [
                                BoxShadow(
                                  color: Pallete.primary.withAlpha(
                                    (100 + _pulseCtrl.value * 60).toInt(),
                                  ),
                                  blurRadius: 30 + _pulseCtrl.value * 15,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Inner glow
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: [
                                        Colors.white.withAlpha(30),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                ),
                                const Icon(
                                  Icons.eco_rounded,
                                  color: Colors.white,
                                  size: 46,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Title
                      Transform.translate(
                        offset: Offset(0, 30 * (1 - _titleSlide.value)),
                        child: Opacity(
                          opacity: _titleSlide.value,
                          child: Text(
                            l.tr('app_name'),
                            style: AppFonts.font(
                              fontSize: 40,
                              fontWeight: FontWeight.w900,
                              color: textColor,
                              letterSpacing: -1,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Subtitle
                      Transform.translate(
                        offset: Offset(0, 20 * (1 - _subtitleSlide.value)),
                        child: Opacity(
                          opacity: _subtitleSlide.value,
                          child: Text(
                            l.tr('precision_intelligence'),
                            style: AppFonts.font(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: subColor,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Bottom progress ──
                Positioned(
                  left: 60,
                  right: 60,
                  bottom: 80,
                  child: Opacity(
                    opacity: _titleSlide.value * fadeOutOpacity,
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: _mainCtrl.value,
                            minHeight: 3,
                            backgroundColor: colors.outline,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Pallete.chartGreen,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          l.tr('loading_farm_data'),
                          style: AppFonts.font(
                            fontSize: 12,
                            color: colors.textHint,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

