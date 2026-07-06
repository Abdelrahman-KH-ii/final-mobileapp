import 'package:flutter/material.dart';
import 'package:farmtec/core/l10n/app_localizations.dart';
import 'package:farmtec/core/themes/app_fonts.dart';
import 'package:farmtec/features/ai_models/presentation/widgets/model_results/ai_model_result_card_shell.dart';

class MarketForecastResultsCard extends StatelessWidget {
  final dynamic data;
  final AppLocalizations l;
  final Color cardColor;
  final Color textColor;
  final Color accentGreen;

  const MarketForecastResultsCard({
    super.key,
    required this.data,
    required this.l,
    required this.cardColor,
    required this.textColor,
    required this.accentGreen,
  });

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    if (data is List && data.isNotEmpty) {
      rows.add(AiModelResultSection(
        title: l.tr('model_result_market_forecast'),
        textColor: textColor,
        accentGreen: accentGreen,
        children: [
          ...data.take(5).map((item) {
            final priceRaw = item['price'];
            final price = priceRaw is num ? priceRaw.toStringAsFixed(2) : priceRaw?.toString() ?? '0.00';
            final commodity = item['commodity']?.toString() ?? l.tr('model_result_unknown');
            return Text(
              '• $commodity: $price',
              style: AppFonts.font(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: textColor,
                height: 1.6,
              ),
            );
          }),
        ],
      ));
    } else {
      rows.add(AiModelResultSection(
        title: l.tr('model_result_market_forecast'),
        textColor: textColor,
        accentGreen: accentGreen,
        children: [
          Text(
            data?.toString() ?? l.tr('model_result_unknown'),
            style: AppFonts.font(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: textColor,
              height: 1.6,
            ),
          ),
        ],
      ));
    }

    return AiModelResultCardShell(
      cardColor: cardColor,
      textColor: textColor,
      accentGreen: accentGreen,
      topAccentColor: const Color(0xFFF97316),
      icon: Icons.trending_up,
      iconColor: const Color(0xFFEA580C),
      backgroundGradient: const LinearGradient(
        colors: [Color(0xFFFFF7ED), Color(0xFFFFEDD5)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderColor: const Color(0xFFFDBA74),
      title: l.tr('model_result_market_forecast'),
      children: [
        ...rows,
      ],
    );
  }
}
