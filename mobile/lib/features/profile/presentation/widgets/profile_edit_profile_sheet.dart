import 'package:farmtec/core/l10n/app_localizations.dart';
import 'package:farmtec/core/themes/app_fonts.dart';
import 'package:farmtec/core/themes/pallete.dart';
import 'package:farmtec/features/profile/presentation/widgets/profile_sheet.dart';
import 'package:farmtec/features/profile/presentation/widgets/profile_sheet_field.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileEditProfileSheet extends StatelessWidget {
  final bool isDark;
  final AppLocalizations l;

  const ProfileEditProfileSheet({
    super.key,
    required this.isDark,
    required this.l,
  });

  @override
  Widget build(BuildContext context) {
    return ProfileSheet(
      title: l.tr('edit_profile'),
      isDark: isDark,
      child: Column(
        children: [
          ProfileSheetField(
            l.tr('full_name'),
            'Ahmed Al-Rashid',
            Icons.person_outline_rounded,
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          ProfileSheetField(
            l.tr('email_address'),
            'ahmed@farmtec.io',
            Icons.email_outlined,
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          ProfileSheetField(
            l.tr('phone_number'),
            '+966 50 123 4567',
            Icons.phone_outlined,
            isDark: isDark,
          ),
          const SizedBox(height: 20),
          ProfileSheetButton(
            l.tr('save_changes'),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    l.tr('profile_updated'),
                    style: AppFonts.font(),
                  ),
                  backgroundColor: Pallete.primary,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
