import 'package:farmtec/core/l10n/app_localizations.dart';
import 'package:farmtec/core/themes/app_fonts.dart';
import 'package:farmtec/core/themes/pallete.dart';
import 'package:farmtec/core/utils/assets.dart';
import 'package:farmtec/features/auth/presentation/screens/signup_screen.dart';
import 'package:farmtec/features/auth/presentation/widgets/app_text_field.dart';
import 'package:farmtec/features/farm_selection/presentation/screens/farm_selection_screen.dart';
import 'package:flutter/material.dart';
import 'package:svg_flutter/svg.dart';

class LoginBody extends StatefulWidget {
  const LoginBody({super.key});

  @override
  State<LoginBody> createState() => _LoginBodyState();
}

class _LoginBodyState extends State<LoginBody>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOutCubic);
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l = AppLocalizations.of(context);
    final cardColor = isDark ? Pallete.darkCard : Colors.white;
    final textColor = isDark ? Pallete.darkTextPrimary : Pallete.primary;
    final subColor = isDark ? Pallete.darkTextSecondary : Pallete.textSecondary;
    final fillColor = isDark ? Pallete.darkSurfaceVariant : Pallete.background;
    final borderColor = isDark ? Pallete.darkOutline : const Color(0xFFE6E9E9);

    return Scaffold(
      backgroundColor: isDark ? Pallete.darkBackground : const Color(0xFFF4F6F4),
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/images/auth_background.png',
              fit: BoxFit.cover,
            ),
          ),
          // Content
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: IntrinsicHeight(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 16),
                            // Top Header Logo (no back button)
                            Align(
                              alignment: AlignmentDirectional.centerStart,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: Pallete.primary,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(Icons.eco_rounded, color: Colors.white, size: 20),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'FarmTec',
                                    style: AppFonts.font(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: isDark ? Pallete.darkTextPrimary : Pallete.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            // Centered Title & Subtitle matching mockup
                            Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        l.tr('welcome_back'),
                                        style: AppFonts.font(
                                          fontSize: 26,
                                          fontWeight: FontWeight.w800,
                                          color: textColor,
                                          height: 1.2,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Icon(
                                        Icons.spa_rounded,
                                        color: Pallete.primary,
                                        size: 28,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    l.tr('sign_in_subtitle'),
                                    textAlign: TextAlign.center,
                                    style: AppFonts.font(
                                      fontSize: 13,
                                      color: subColor,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 32),
                            // Form
                            Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AppTextField(
                                    label: l.tr('email_address'),
                                    hint: 'farm@example.com',
                                    type: TextInputType.emailAddress,
                                    icon: Icons.mail_outline_rounded,
                                    fillColor: fillColor,
                                    borderColor: borderColor,
                                    textColor: textColor,
                                  ),
                                  const SizedBox(height: 16),
                                  AppTextField(
                                    label: l.tr('password'),
                                    hint: '••••••••',
                                    type: TextInputType.visiblePassword,
                                    obscure: _obscurePassword,
                                    icon: Icons.lock_outline_rounded,
                                    fillColor: fillColor,
                                    borderColor: borderColor,
                                    textColor: textColor,
                                    suffix: GestureDetector(
                                      onTap: () => setState(
                                        () => _obscurePassword = !_obscurePassword,
                                      ),
                                      child: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        color: Pallete.textHint,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Align(
                                    alignment: AlignmentDirectional.centerEnd,
                                    child: GestureDetector(
                                      onTap: () {},
                                      child: Text(
                                        l.tr('forgot_password'),
                                        style: AppFonts.font(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: isDark ? Pallete.accent : const Color(0xFFEAA610),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 28),
                            // Login Button matching mockup style
                            SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Pallete.primary,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                onPressed: () {
                                  if (_formKey.currentState?.validate() ?? false) {
                                    Navigator.pushReplacementNamed(
                                      context,
                                      FarmSelectionScreen.routeName,
                                    );
                                  }
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.spa_rounded,
                                      color: Colors.white.withOpacity(0.9),
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      l.tr('login_button'),
                                      style: AppFonts.font(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Divider
                            Row(
                              children: [
                                Expanded(
                                  child: Divider(color: borderColor, height: 1),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  child: Text(
                                    l.tr('or'),
                                    style: AppFonts.font(
                                      fontSize: 12,
                                      color: Pallete.textHint,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Divider(color: borderColor, height: 1),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            // Social buttons matching mockup style cards
                            Row(
                              children: [
                                Expanded(
                                  child: _socialButton(
                                    'Google',
                                    Assets.googleIcon,
                                    cardColor,
                                    isDark ? Pallete.darkOutline : const Color(0xFFE8ECE9),
                                    textColor,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _socialButton(
                                    'Apple',
                                    Assets.appleIcon,
                                    cardColor,
                                    isDark ? Pallete.darkOutline : const Color(0xFFE8ECE9),
                                    textColor,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(flex: 1),
                            // Bottom switcher banner matching mockup
                            Container(
                              margin: const EdgeInsets.only(bottom: 16, top: 24),
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: isDark ? Pallete.darkSurfaceVariant : const Color(0xFFEBEFEB),
                                borderRadius: BorderRadius.circular(28),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: isDark ? const Color(0xFF2C322E) : const Color(0xFFC7D3C5),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.person_add_rounded,
                                      color: Pallete.primary,
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          l.tr('no_account'),
                                          style: AppFonts.font(
                                            fontSize: 14,
                                            color: isDark ? Pallete.darkTextPrimary : Pallete.textSecondary,
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.pushReplacementNamed(
                                              context,
                                              SignupScreen.routeName,
                                            );
                                          },
                                          child: Text(
                                            l.tr('sign_up'),
                                            style: AppFonts.font(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w800,
                                              color: Pallete.primary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _socialButton(
    String label,
    String svgPath,
    Color bg,
    Color border,
    Color textColor,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(svgPath, width: 20, height: 20),
          const SizedBox(width: 8),
          Text(
            label,
            style: AppFonts.font(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
