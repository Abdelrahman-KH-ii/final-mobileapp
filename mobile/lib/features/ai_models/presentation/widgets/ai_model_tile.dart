import 'package:farmtec/core/l10n/app_localizations.dart';
import 'package:farmtec/core/themes/app_fonts.dart';
import 'package:farmtec/core/themes/pallete.dart';
import 'package:farmtec/features/ai_models/presentation/screens/ai_model_run_screen.dart';
import 'package:farmtec/features/ai_models/presentation/widgets/ai_model_definition.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AiModelTile extends StatelessWidget {
  final AIModelDefinition model;
  final bool isDark;
  final Color cardColor;
  final Color textColor;
  final Color subColor;
  final bool isNew;

  const AiModelTile({
    super.key,
    required this.model,
    required this.isDark,
    required this.cardColor,
    required this.textColor,
    required this.subColor,
    this.isNew = false,
  });

  /// Unique accent color per model icon background
  Color get _iconBgColor {
    switch (model.icon) {
      case Icons.eco_rounded:
      case Icons.agriculture_rounded:
        return const Color(0xFF2D6A4F); // green
      case Icons.bar_chart_rounded:
      case Icons.trending_up_rounded:
        return const Color(0xFF1565C0); // blue
      case Icons.water_rounded:
      case Icons.water_drop_rounded:
        return const Color(0xFF00897B); // teal
      case Icons.show_chart_rounded:
      case Icons.insights_rounded:
        return const Color(0xFF2E7D32); // dark green
      case Icons.biotech_rounded:
      case Icons.bug_report_rounded:
        return const Color(0xFF6A994E); // plant green
      case Icons.grain_rounded:
        return const Color(0xFF8B5A2B); // warm grain/soil brown
      default:
        return Pallete.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final nameKey = model.name.toLowerCase().replaceAll(' ', '_');
    final descKey = '${nameKey}_desc';

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => AiModelRunScreen(model: model)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        height: 130,
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(isDark ? 50 : 18),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            // ── Left: image thumbnail ──────────────────────────────────
            SizedBox(
              width: 115,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    model.backgroundImage,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        Container(color: Pallete.primary.withAlpha(30)),
                  ),
                  // "New" badge
                  if (isNew)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withAlpha(200)
                              : Colors.white.withAlpha(230),
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(30),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Text(
                          l.tr('new_badge'),
                          style: AppFonts.font(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: Pallete.primary,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // ── Right: text content + icon ─────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 14, 10, 14),
                child: Row(
                  children: [
                    // Text column
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            l.tr(nameKey),
                            style: AppFonts.font(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: textColor,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l.tr(descKey),
                            style: AppFonts.font(
                              fontSize: 11,
                              color: subColor,
                              height: 1.4,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Spacer(),
                          // Parameters info row
                          Row(
                            children: [
                              Icon(
                                Icons.settings_rounded,
                                size: 12,
                                color: subColor.withAlpha(180),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                model.isVisionModel
                                    ? l.tr('photo_and_text')
                                    : model.fields.isEmpty
                                        ? l.tr('get_request')
                                        : l.trParams('parameters_count', {
                                            'count': '${model.fields.length}',
                                          }),
                                style: AppFonts.font(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: subColor.withAlpha(180),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Icon badge
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: _iconBgColor.withAlpha(isDark ? 50 : 25),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        model.icon,
                        color: _iconBgColor,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
