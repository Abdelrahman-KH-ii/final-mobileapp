import 'package:farmtec/core/l10n/app_localizations.dart';
import 'package:farmtec/core/themes/app_fonts.dart';
import 'package:farmtec/core/themes/pallete.dart';
import 'package:farmtec/core/services/auth_service.dart';
import 'package:farmtec/features/profile/presentation/widgets/profile_sheet.dart';
import 'package:farmtec/features/profile/presentation/widgets/profile_sheet_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileChangePasswordSheet extends StatefulWidget {
  final bool isDark;
  final AppLocalizations l;

  const ProfileChangePasswordSheet({
    super.key,
    required this.isDark,
    required this.l,
  });

  @override
  State<ProfileChangePasswordSheet> createState() => _ProfileChangePasswordSheetState();
}

class _ProfileChangePasswordSheetState extends State<ProfileChangePasswordSheet> {
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _update() async {
    final oldPass = _oldPasswordController.text;
    final newPass = _newPasswordController.text;
    final confPass = _confirmPasswordController.text;

    if (oldPass.isEmpty || newPass.isEmpty || confPass.isEmpty) {
      _showSnackbar(widget.l.tr('fill_all_fields') ?? 'Please fill all fields', isError: true);
      return;
    }

    if (newPass != confPass) {
      _showSnackbar(widget.l.isArabic ? 'كلمة المرور الجديدة غير متطابقة' : 'Passwords do not match', isError: true);
      return;
    }

    if (newPass.length < 8) {
      _showSnackbar(widget.l.isArabic ? 'يجب أن تتكون كلمة المرور من 8 أحرف على الأقل' : 'Password must be at least 8 characters', isError: true);
      return;
    }

    setState(() => _loading = true);

    try {
      final auth = context.read<AuthService>();
      await auth.changePassword(oldPassword: oldPass, newPassword: newPass);

      if (!mounted) return;
      Navigator.pop(context);
      _showSnackbar(widget.l.tr('password_changed') ?? 'Password changed successfully');
    } catch (e) {
      if (!mounted) return;
      _showSnackbar(e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showSnackbar(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: AppFonts.font()),
        backgroundColor: isError ? Colors.red : Pallete.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ProfileSheet(
      title: widget.l.tr('change_password'),
      isDark: widget.isDark,
      child: Column(
        children: [
          ProfileSheetField(
            widget.l.tr('current_password'),
            '',
            Icons.lock_outline_rounded,
            obscure: true,
            isDark: widget.isDark,
            controller: _oldPasswordController,
          ),
          const SizedBox(height: 12),
          ProfileSheetField(
            widget.l.tr('new_password'),
            '',
            Icons.lock_outline_rounded,
            obscure: true,
            isDark: widget.isDark,
            controller: _newPasswordController,
          ),
          const SizedBox(height: 12),
          ProfileSheetField(
            widget.l.tr('confirm_password'),
            '',
            Icons.lock_outline_rounded,
            obscure: true,
            isDark: widget.isDark,
            controller: _confirmPasswordController,
          ),
          const SizedBox(height: 20),
          if (_loading)
            const CircularProgressIndicator(color: Pallete.primary)
          else
            ProfileSheetButton(
              widget.l.tr('update_password'),
              onTap: _update,
            ),
        ],
      ),
    );
  }
}
