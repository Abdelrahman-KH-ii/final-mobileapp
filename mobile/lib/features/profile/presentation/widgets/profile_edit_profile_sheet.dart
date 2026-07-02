import 'package:farmtec/core/l10n/app_localizations.dart';
import 'package:farmtec/core/themes/app_fonts.dart';
import 'package:farmtec/core/themes/pallete.dart';
import 'package:farmtec/core/services/auth_service.dart';
import 'package:farmtec/features/profile/presentation/widgets/profile_sheet.dart';
import 'package:farmtec/features/profile/presentation/widgets/profile_sheet_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileEditProfileSheet extends StatefulWidget {
  final bool isDark;
  final AppLocalizations l;

  const ProfileEditProfileSheet({
    super.key,
    required this.isDark,
    required this.l,
  });

  @override
  State<ProfileEditProfileSheet> createState() => _ProfileEditProfileSheetState();
}

class _ProfileEditProfileSheetState extends State<ProfileEditProfileSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthService>().user;
    _nameController = TextEditingController(text: user?.fullName ?? user?.username ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(text: user?.phoneNumber ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty) return;

    setState(() => _loading = true);

    try {
      final auth = context.read<AuthService>();
      await auth.updateProfile(
        fullName: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
      );

      if (!mounted) return;
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.l.tr('profile_updated'),
            style: AppFonts.font(),
          ),
          backgroundColor: Pallete.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
            style: AppFonts.font(),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ProfileSheet(
      title: widget.l.tr('edit_profile'),
      isDark: widget.isDark,
      child: Column(
        children: [
          ProfileSheetField(
            widget.l.tr('full_name'),
            '',
            Icons.person_outline_rounded,
            isDark: widget.isDark,
            controller: _nameController,
          ),
          const SizedBox(height: 12),
          ProfileSheetField(
            widget.l.tr('email_address'),
            '',
            Icons.email_outlined,
            isDark: widget.isDark,
            controller: _emailController,
            readOnly: true, // Email is typically read-only on backend
          ),
          const SizedBox(height: 12),
          ProfileSheetField(
            widget.l.tr('phone_number'),
            '',
            Icons.phone_outlined,
            isDark: widget.isDark,
            controller: _phoneController,
          ),
          const SizedBox(height: 20),
          if (_loading)
            const CircularProgressIndicator(color: Pallete.primary)
          else
            ProfileSheetButton(
              widget.l.tr('save_changes'),
              onTap: _save,
            ),
        ],
      ),
    );
  }
}
