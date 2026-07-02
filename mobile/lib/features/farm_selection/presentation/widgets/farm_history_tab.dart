import 'package:farmtec/core/l10n/app_localizations.dart';
import 'package:farmtec/core/themes/app_fonts.dart';
import 'package:farmtec/core/services/farm_history_service.dart';
import 'package:farmtec/core/themes/pallete.dart';
import 'package:farmtec/features/farm/presentation/providers/farm_provider.dart';
import 'package:farmtec/features/farm_selection/presentation/widgets/farm_history_tile.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class FarmHistoryTab extends StatelessWidget {
  const FarmHistoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l = AppLocalizations.of(context);
    final historyService = Provider.of<FarmHistoryService>(context);
    final farmProvider = Provider.of<FarmProvider>(context);
    final textColor = isDark ? Pallete.darkTextPrimary : Pallete.primary;
    final subColor = isDark ? Pallete.darkTextSecondary : Pallete.textSecondary;
    final cardColor = isDark ? Pallete.darkCard : Pallete.surface;

    final farmNames = {for (final f in farmProvider.farms) f.id: f.name};
    final ops = historyService.operations
        .where((o) => farmNames.containsKey(o.farmId))
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    if (ops.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.history_rounded,
              size: 56,
              color: subColor.withAlpha(80),
            ),
            const SizedBox(height: 12),
            Text(
              l.tr('no_activity_yet'),
              style: AppFonts.font(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: subColor,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
      itemCount: ops.length,
      itemBuilder: (_, i) {
        final op = ops[i];
        return FarmHistoryTile(
          operation: op,
          farmName: farmNames[op.farmId]!,
          isDark: isDark,
          cardColor: cardColor,
          textColor: textColor,
          subColor: subColor,
        );
      },
    );
  }
}
