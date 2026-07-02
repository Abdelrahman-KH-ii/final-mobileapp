import 'package:farmtec/core/providers/locale_provider.dart';
import 'package:farmtec/core/themes/pallete.dart';
import 'package:farmtec/features/profile/presentation/widgets/profile_lang_tile.dart';
import 'package:flutter/material.dart';

class ProfileLanguagePicker extends StatelessWidget {
  final bool isDark;
  final Color textColor;
  final LocaleProvider localeProvider;

  const ProfileLanguagePicker({
    super.key,
    required this.isDark,
    required this.textColor,
    required this.localeProvider,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ProfileLangTile(
          label: 'English',
          code: 'en',
          isDark: isDark,
          textColor: textColor,
          isActive: localeProvider.locale.languageCode == 'en',
          onTap: () => localeProvider.setLocale(const Locale('en')),
        ),
        Divider(
          height: 1,
          color: isDark ? Pallete.darkOutline : Pallete.neutral200,
        ),
        ProfileLangTile(
          label: 'العربية',
          code: 'ar',
          isDark: isDark,
          textColor: textColor,
          isActive: localeProvider.locale.languageCode == 'ar',
          onTap: () => localeProvider.setLocale(const Locale('ar')),
        ),
      ],
    );
  }
}
