import 'package:farmtec/core/l10n/app_localizations.dart';
import 'package:farmtec/core/themes/app_fonts.dart';
import 'package:farmtec/core/themes/pallete.dart';
import 'package:farmtec/features/auth/presentation/screens/login_screen.dart';
import 'package:farmtec/features/auth/presentation/widgets/app_text_field.dart';
import 'package:flutter/material.dart';

class SignupBody extends StatefulWidget {
  const SignupBody({super.key});

  @override
  State<SignupBody> createState() => _SignupBodyState();
}

class _SignupBodyState extends State<SignupBody>
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
                      constraints:
                          BoxConstraints(minHeight: constraints.maxHeight),
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
                                        l.tr('create_account'),
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
                                    l.tr('sign_up_subtitle'),
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
                            Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AppTextField(
                                    label: l.tr('full_name'),
                                    hint: 'Ahmed Rady',
                                    type: TextInputType.name,
                                    icon: Icons.person_outline_rounded,
                                    fillColor: fillColor,
                                    borderColor: borderColor,
                                    textColor: textColor,
                                  ),
                                  const SizedBox(height: 16),
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
                                    label: l.tr('phone_number'),
                                    hint: '+20 123 456 7890',
                                    type: TextInputType.phone,
                                    icon: Icons.phone_outlined,
                                    fillColor: fillColor,
                                    borderColor: borderColor,
                                    textColor: textColor,
                                  ),
                                  const SizedBox(height: 16),
                                  AppTextField(
                                    label: l.tr('location_region'),
                                    hint: 'Cairo, Egypt',
                                    type: TextInputType.text,
                                    icon: Icons.location_on_outlined,
                                    fillColor: fillColor,
                                    borderColor: borderColor,
                                    textColor: textColor,
                                    suffix: Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      color: Pallete.textHint,
                                    ),
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
                                ],
                              ),
                            ),
                            const SizedBox(height: 32),
                            // Action Button
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
                                    // Submit Form
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
                                      l.tr('signup_button'),
                                      style: AppFonts.font(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(
                                    text: l.tr('terms_prefix'),
                                    style: AppFonts.font(
                                      fontSize: 12,
                                      color: subColor,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: l.tr('terms_of_service'),
                                        style: AppFonts.font(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: isDark ? Pallete.accent : const Color(0xFFEAA610),
                                        ),
                                      ),
                                      TextSpan(text: l.tr('and')),
                                      TextSpan(
                                        text: l.tr('privacy_policy'),
                                        style: AppFonts.font(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: isDark ? Pallete.accent : const Color(0xFFEAA610),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const Spacer(),
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
                                      Icons.login_rounded,
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
                                          l.tr('have_account'),
                                          style: AppFonts.font(
                                            fontSize: 14,
                                            color: isDark ? Pallete.darkTextPrimary : Pallete.textSecondary,
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.pushReplacementNamed(
                                              context,
                                              LoginScreen.routeName,
                                            );
                                          },
                                          child: Text(
                                            l.tr('login'),
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
}
