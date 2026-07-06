import 'package:farmtec/core/l10n/app_localizations.dart';
import 'package:farmtec/core/themes/app_fonts.dart';
import 'package:farmtec/core/themes/pallete.dart';
import 'package:flutter/material.dart';

class ChatEmptyState extends StatelessWidget {
  final bool isDark;
  final AppLocalizations l;

  const ChatEmptyState({
    super.key,
    required this.isDark,
    required this.l,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Pallete.primary.withAlpha(15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.eco_rounded,
              size: 36,
              color: Pallete.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l.tr('farmbrain_ai'),
            style: AppFonts.font(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: isDark ? Pallete.darkTextPrimary : Pallete.primary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l.tr('ask_anything'),
            style: AppFonts.font(
              fontSize: 14,
              color: isDark ? Pallete.darkTextSecondary : Pallete.textHint,
            ),
          ),
        ],
      ),
    );
  }
}
