import 'package:farmtec/core/l10n/app_localizations.dart';
import 'package:farmtec/core/themes/app_fonts.dart';
import 'package:farmtec/core/themes/app_theme_colors.dart';
import 'package:flutter/material.dart';

class _SuggestionItem {
  final IconData icon;
  final Color color;
  final String labelKey;

  const _SuggestionItem({
    required this.icon,
    required this.color,
    required this.labelKey,
  });
}

class ChatQuestions extends StatelessWidget {
  final bool isDark;
  final AppLocalizations l;
  final ValueChanged<String> onQuestionTap;

  const ChatQuestions({
    super.key,
    required this.isDark,
    required this.l,
    required this.onQuestionTap,
  });

  String _label(String key) {
    final raw = l.tr(key);
    return raw.replaceAll(RegExp(r'[\u{1F300}-\u{1FAFF}]', unicode: true), '').trim();
  }

  @override
  Widget build(BuildContext context) {
    const items = [
      _SuggestionItem(
        icon: Icons.eco_rounded,
        color: Color(0xFF4CAF50),
        labelKey: 'question_field_health',
      ),
      _SuggestionItem(
        icon: Icons.water_drop_rounded,
        color: Color(0xFF2196F3),
        labelKey: 'question_irrigation',
      ),
      _SuggestionItem(
        icon: Icons.bug_report_rounded,
        color: Color(0xFF66BB6A),
        labelKey: 'question_disease',
      ),
      _SuggestionItem(
        icon: Icons.show_chart_rounded,
        color: Color(0xFFEF4444),
        labelKey: 'question_market',
      ),
      _SuggestionItem(
        icon: Icons.spa_rounded,
        color: Color(0xFF43A047),
        labelKey: 'question_crop',
      ),
    ];

    final colors = context.appColors;
    final borderColor = colors.outline;
    final bgColor = colors.elevatedSurface;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children:
            items.map((item) {
              final label = _label(item.labelKey);
              return GestureDetector(
                onTap: () => onQuestionTap(label),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: borderColor),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(item.icon, size: 15, color: item.color),
                      const SizedBox(width: 6),
                      Text(
                        label,
                        style: AppFonts.font(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: colors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }
}
