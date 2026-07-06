import 'package:farmtec/core/l10n/app_localizations.dart';
import 'package:farmtec/core/themes/app_fonts.dart';
import 'package:farmtec/core/services/yield_prediction_service.dart';
import 'package:farmtec/core/themes/pallete.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfitCalculatorCard extends StatelessWidget {
  final bool isDark;
  final Color textColor;
  final Color subColor;
  final double marketPrice;

  const ProfitCalculatorCard({
    super.key,
    required this.isDark,
    required this.textColor,
    required this.subColor,
    required this.marketPrice,
  });

  String _money(AppLocalizations l, double value) {
    final amount = l.convertNumbers(value.toStringAsFixed(2));
    final currency = l.tr('currency_egp');
    if (l.isArabic) return '$amount $currency';
    return '$currency $amount';
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final yieldPrediction = Provider.of<YieldPredictionService>(context);

    final estimatedYield = yieldPrediction.yieldPerHa;
    // Multiply incoming market price by 10 for display and calculations
    final displayedMarketPrice = marketPrice * 10;
    final totalProfit = estimatedYield * displayedMarketPrice;
    final normalizedUnit = yieldPrediction.unit.trim().toLowerCase();
    final unitLabel =
        normalizedUnit.contains('feddan') ||
                normalizedUnit.contains('ton') ||
                normalizedUnit.contains('tonne') ||
                normalizedUnit.contains('t/ha')
            ? l.tr('tonnes_per_feddan')
            : l.trOr(normalizedUnit, normalizedUnit);
    final currency = l.tr('currency_egp');
    final priceAmount = l.convertNumbers(displayedMarketPrice.toStringAsFixed(2));
    final priceLabel = l.isArabic
      ? '$priceAmount $currency ${l.tr('per_ton')}'
      : '$currency $priceAmount${l.tr('per_ton')}';

    return Directionality(
      textDirection: TextDirection.ltr,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: _metricTile(
                label: l.tr('estimated_yield'),
                value:
                    '${l.convertNumbers(estimatedYield.toStringAsFixed(2))} $unitLabel',
                icon: Icons.eco_rounded,
                isDark: isDark,
                subColor: subColor,
                textColor: textColor,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _metricTile(
                label: l.tr('current_market_price'),
                value: priceLabel,
                icon: Icons.paid_rounded,
                isDark: isDark,
                subColor: subColor,
                textColor: textColor,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Pallete.primary.withAlpha(isDark ? 35 : 14),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Pallete.primary.withAlpha(isDark ? 40 : 20),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.savings_rounded,
                      size: 16,
                      color: Pallete.primary,
                    ),
                    const Spacer(),
                    Text(
                      l.tr('total_expected_profit'),
                      style: AppFonts.font(
                        fontSize: 8,
                        fontWeight: FontWeight.w600,
                        color: Pallete.primary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _money(l, totalProfit),
                      style: AppFonts.font(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: Pallete.primary,
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

  Widget _metricTile({
    required String label,
    required String value,
    required IconData icon,
    required bool isDark,
    required Color subColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark ? Pallete.darkSurfaceVariant : const Color(0xFFF8F9F6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Pallete.darkOutline.withAlpha(40) : const Color(0xFFE8EBE4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Pallete.primary),
          const Spacer(),
          Text(
            label,
            style: AppFonts.font(fontSize: 8, color: subColor),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppFonts.font(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
