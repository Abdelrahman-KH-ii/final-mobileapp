import 'package:farmtec/core/l10n/app_localizations.dart';
import 'package:farmtec/core/themes/pallete.dart';
import 'package:farmtec/features/farm/presentation/providers/farm_provider.dart';
import 'package:farmtec/features/farm_selection/presentation/widgets/farm_selection_card.dart';
import 'package:farmtec/features/farm_selection/presentation/widgets/farm_selection_empty_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FarmsTab extends StatelessWidget {
  final VoidCallback onAddFarm;
  const FarmsTab({super.key, required this.onAddFarm});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final farmService = Provider.of<FarmProvider>(context);
    final l = AppLocalizations.of(context);
    final textColor = isDark ? Pallete.darkTextPrimary : Pallete.primary;
    final subColor = isDark ? Pallete.darkTextSecondary : Pallete.textSecondary;
    final cardColor = isDark ? Pallete.darkCard : Pallete.surface;

    if (farmService.farms.isEmpty) {
      return FarmSelectionEmptyState(
        l: l,
        textColor: textColor,
        subColor: subColor,
        onAddFarm: onAddFarm,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
      itemCount: farmService.farms.length,
      itemBuilder: (_, i) {
        final farm = farmService.farms[i];
        final selected = farm.id == farmService.selectedFarm?.id;
        return FarmSelectionCard(
          farm: farm,
          isSelected: selected,
          isDark: isDark,
          cardColor: cardColor,
          textColor: textColor,
          subColor: subColor,
          onTap: () => farmService.selectFarm(farm.id),
        );
      },
    );
  }
}
