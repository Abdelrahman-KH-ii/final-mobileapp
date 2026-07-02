import 'package:farmtec/core/exceptions/api_exception.dart';
import 'package:farmtec/core/l10n/app_localizations.dart';
import 'package:farmtec/core/services/auth_service.dart';
import 'package:farmtec/core/themes/app_fonts.dart';
import 'package:farmtec/core/themes/pallete.dart';
import 'package:farmtec/core/utils/assets.dart';
import 'package:farmtec/features/auth/presentation/screens/login_screen.dart';
import 'package:farmtec/features/auth/presentation/widgets/app_text_field.dart';
import 'package:farmtec/features/auth/presentation/widgets/farm_tec_logo.dart';
import 'package:farmtec/features/auth/presentation/widgets/field_label.dart';
import 'package:farmtec/features/farm/presentation/providers/farm_provider.dart';
import 'package:farmtec/features/farm_selection/presentation/screens/farm_selection_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:svg_flutter/svg.dart';

class SignupBody extends StatefulWidget {
  const SignupBody({super.key});

  @override
  State<SignupBody> createState() => _SignupBodyState();
}

class _SignupBodyState extends State<SignupBody>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
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
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _passwordController.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  String _usernameFromEmail(String email) {
    final local = email.split('@').first.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '');
    return local.isEmpty ? 'farmer${DateTime.now().millisecondsSinceEpoch}' : local;
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _submitting = true;
      _errorMessage = null;
    });
    try {
      final email = _emailController.text.trim();
      final auth = context.read<AuthService>();
      await auth.register(
        email: email,
        username: _usernameFromEmail(email),
        password: _passwordController.text,
        phoneNumber: _phoneController.text.trim(),
        fullName: _fullNameController.text.trim(),
        location: _locationController.text.trim(),
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
                  constraints:
                      BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 24),
                        FarmTecLogo(isDark: isDark),
                        const SizedBox(height: 28),
                        Text(
                          l.tr('create_account'),
                          style: AppFonts.font(
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            color: textColor,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          l.tr('sign_up_subtitle'),
                          style: AppFonts.font(
                            fontSize: 14,
                            color: subColor,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              FieldLabel(
                                text: l.tr('full_name'),
                                color: textColor,
                              ),
                              const SizedBox(height: 6),
                              AppTextField(
                                controller: _fullNameController,
                                hint: 'Ahmed Rady',
                                type: TextInputType.name,
                                fillColor: fillColor,
                                borderColor: borderColor,
                                textColor: textColor,
                              ),
                              const SizedBox(height: 14),
                              FieldLabel(
                                text: l.tr('email_address'),
                                color: textColor,
                              ),
                              const SizedBox(height: 6),
                              AppTextField(
                                controller: _emailController,
                                hint: 'farm@example.com',
                                type: TextInputType.emailAddress,
                                fillColor: fillColor,
                                borderColor: borderColor,
                                textColor: textColor,
                              ),
                              const SizedBox(height: 14),
                              FieldLabel(
                                text: l.tr('phone_number'),
                                color: textColor,
                              ),
                              const SizedBox(height: 6),
                              AppTextField(
                                controller: _phoneController,
                                hint: '+20 1234567890',
                                type: TextInputType.phone,
                                fillColor: fillColor,
                                borderColor: borderColor,
                                textColor: textColor,
                                prefix: Padding(
                                  padding: const EdgeInsets.only(
                                    left: 14,
                                    right: 8,
                                  ),
                                  child: Icon(
                                    Icons.phone_rounded,
                                    size: 18,
                                    color: Pallete.textHint,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),
                              FieldLabel(
                                text: l.tr('location_region'),
                                color: textColor,
                              ),
                              const SizedBox(height: 6),
                              AppTextField(
                                controller: _locationController,
                                hint: 'Cairo, Egypt',
                                type: TextInputType.text,
                                fillColor: fillColor,
                                borderColor: borderColor,
                                textColor: textColor,
                                prefix: Padding(
                                  padding: const EdgeInsets.only(
                                    left: 14,
                                    right: 8,
                                  ),
                                  child: Icon(
                                    Icons.location_on_rounded,
                                    size: 18,
                                    color: Pallete.textHint,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),
                              FieldLabel(
                                text: l.tr('password'),
                                color: textColor,
                              ),
                              const SizedBox(height: 6),
                              AppTextField(
                                controller: _passwordController,
                                hint: '••••••••',
                                type: TextInputType.visiblePassword,
                                obscure: _obscurePassword,
                                fillColor: fillColor,
                                borderColor: borderColor,
                                textColor: textColor,
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
                        const SizedBox(height: 24),
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
                            onPressed: _submitting ? null : _handleSignup,
                            child: _submitting
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                              l.tr('signup_button'),
                              style: AppFonts.font(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Center(
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
                                    color: Pallete.accent,
                                  ),
                                ),
                                TextSpan(text: l.tr('and')),
                                TextSpan(
                                  text: l.tr('privacy_policy'),
                                  style: AppFonts.font(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Pallete.accent,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Spacer(),
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 24),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  l.tr('have_account'),
                                  style: AppFonts.font(
                                    fontSize: 14,
                                    color: subColor,
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
}
