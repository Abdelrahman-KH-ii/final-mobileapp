import 'package:farmtec/core/l10n/app_localizations.dart';
import 'package:farmtec/features/profile/presentation/widgets/profile_sheet.dart';
import 'package:farmtec/features/profile/presentation/widgets/profile_sheet_field.dart';
import 'package:flutter/material.dart';

class ProfileChangePasswordSheet extends StatelessWidget {
  final bool isDark;
  final AppLocalizations l;

  const ProfileChangePasswordSheet({
    super.key,
    required this.isDark,
    required this.l,
  });

  @override
  Widget build(BuildContext context) {
    return ProfileSheet(
      title: l.tr('change_password'),
      isDark: isDark,
      child: Column(
        children: [
          ProfileSheetField(
            l.tr('current_password'),
            '••••••••',
            Icons.lock_outline_rounded,
            obscure: true,
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          ProfileSheetField(
            l.tr('new_password'),
            '',
            Icons.lock_outline_rounded,
            obscure: true,
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          ProfileSheetField(
            l.tr('confirm_password'),
            '',
            Icons.lock_outline_rounded,
            obscure: true,
            isDark: isDark,
          ),
          const SizedBox(height: 20),
          ProfileSheetButton(
            l.tr('update_password'),
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
