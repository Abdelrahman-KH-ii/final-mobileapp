import 'package:farmtec/core/exceptions/api_exception.dart';
import 'package:farmtec/core/l10n/app_localizations.dart';
import 'package:farmtec/core/services/auth_service.dart';
import 'package:farmtec/core/themes/app_fonts.dart';
import 'package:farmtec/core/themes/pallete.dart';
import 'package:farmtec/core/utils/assets.dart';
import 'package:farmtec/features/auth/presentation/screens/signup_screen.dart';
import 'package:farmtec/features/farm/presentation/providers/farm_provider.dart';
import 'package:farmtec/features/farm_selection/presentation/screens/farm_selection_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:svg_flutter/svg.dart';

class LoginBody extends StatefulWidget {
  const LoginBody({super.key});

  @override
  State<LoginBody> createState() => _LoginBodyState();
}

class _LoginBodyState extends State<LoginBody>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _submitting = false;
  String? _errorMessage;
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
    _emailController.dispose();
    _passwordController.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _submitting = true;
      _errorMessage = null;
    });
    try {
      final auth = context.read<AuthService>();
      await auth.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (!mounted) return;
      await context.read<FarmProvider>().refresh();
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, FarmSelectionScreen.routeName);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = e.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _errorMessage = AppLocalizations.of(context).tr('connection_error'));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l = AppLocalizations.of(context);
    final cardColor = isDark ? Pallete.darkCard : Pallete.surface;
    final textColor = isDark ? Pallete.darkTextPrimary : Pallete.primary;
    final subColor = isDark ? Pallete.darkTextSecondary : Pallete.textSecondary;
    final fillColor = isDark ? Pallete.darkSurfaceVariant : Pallete.background;
    final borderColor = isDark ? Pallete.darkOutline : const Color(0xFFE6E9E9);

    return Scaffold(
      backgroundColor: isDark ? Pallete.darkBackground : Pallete.background,
      body: SafeArea(
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
                        const SizedBox(height: 24),
                        // Logo
                        _buildLogo(isDark),
                        const Spacer(flex: 1),

                        // Header
                        Text(
                          l.tr('welcome_back'),
                          style: AppFonts.font(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: textColor,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l.tr('sign_in_subtitle'),
                          style: AppFonts.font(
                            fontSize: 15,
                            color: subColor,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Form
                        Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _label(l.tr('email_address'), textColor),
                              const SizedBox(height: 8),
                              _buildInput(
                                controller: _emailController,
                                hint: 'farm@example.com',
                                type: TextInputType.emailAddress,
                                fillColor: fillColor,
                                borderColor: borderColor,
                                textColor: textColor,
                                subColor: subColor,
                              ),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _label(l.tr('password'), textColor),
                                  GestureDetector(
                                    onTap: () {},
                                    child: Text(
                                      l.tr('forgot_password'),
                                      style: AppFonts.font(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Pallete.accent,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              _buildInput(
                                controller: _passwordController,
                                hint: '••••••••',
                                type: TextInputType.visiblePassword,
                                obscure: _obscurePassword,
                                fillColor: fillColor,
                                borderColor: borderColor,
                                textColor: textColor,
                                subColor: subColor,
                                suffix: GestureDetector(
                                  onTap: () => setState(
                                    () => _obscurePassword = !_obscurePassword,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(14),
                                    child: SvgPicture.asset(
                                      Assets.eyeIcon,
                                      width: 20,
                                      height: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        if (_errorMessage != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            _errorMessage!,
                            style: AppFonts.font(
                              fontSize: 13,
                              color: Pallete.error,
                            ),
                          ),
                        ],
                        const SizedBox(height: 28),

                        // Login Button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Pallete.primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: _submitting ? null : _handleLogin,
                            child: _submitting
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  l.tr('login_button'),
                                  style: AppFonts.font(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.arrow_forward_rounded,
                                    size: 20),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Divider
                        Row(
                          children: [
                            Expanded(
                                child: Divider(color: borderColor, height: 1)),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                l.tr('or'),
                                style: AppFonts.font(
                                  fontSize: 13,
                                  color: Pallete.textHint,
                                ),
                              ),
                            ),
                            Expanded(
                                child: Divider(color: borderColor, height: 1)),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Social buttons
                        Row(
                          children: [
                            Expanded(
                              child: _socialButton(
                                'Google',
                                Assets.googleIcon,
                                cardColor,
                                borderColor,
                                textColor,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _socialButton(
                                'Apple',
                                Assets.appleIcon,
                                cardColor,
                                borderColor,
                                textColor,
                              ),
                            ),
                          ],
                        ),

                        const Spacer(flex: 2),

                        // Sign up link
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 24),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  l.tr('no_account'),
                                  style: AppFonts.font(
                                    fontSize: 14,
                                    color: subColor,
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
                                      fontWeight: FontWeight.w700,
                                      color: Pallete.accent,
                                    ),
                                  ),
                                ),
                              ],
                            ),
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
    );
  }

  Widget _buildLogo(bool isDark) {
    return Row(
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
    );
  }

  Widget _label(String text, Color color) {
    return Text(
      text,
      style: AppFonts.font(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: color,
      ),
    );
  }

  Widget _buildInput({
    TextEditingController? controller,
    required String hint,
    required TextInputType type,
    bool obscure = false,
    Widget? suffix,
    required Color fillColor,
    required Color borderColor,
    required Color textColor,
    required Color subColor,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: type,
      style: AppFonts.font(fontSize: 15, color: textColor),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppFonts.font(fontSize: 15, color: Pallete.textHint),
        filled: true,
        fillColor: fillColor,
        suffixIcon: suffix,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Pallete.primary, width: 1.5),
        ),
      ),
      validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
    );
  }

  Widget _socialButton(
    String label,
    String svgPath,
    Color bg,
    Color border,
    Color textColor,
  ) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
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