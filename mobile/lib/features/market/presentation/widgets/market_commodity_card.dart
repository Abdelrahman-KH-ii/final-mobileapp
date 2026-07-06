import 'package:farmtec/core/l10n/app_localizations.dart';
import 'package:farmtec/core/themes/app_fonts.dart';
import 'package:farmtec/core/themes/app_theme_colors.dart';
import 'package:farmtec/core/widgets/crop_avatar.dart';
import 'package:farmtec/features/market/data/models/commodity_model.dart';
import 'package:farmtec/features/market/presentation/widgets/market_spark_chart.dart';
import 'package:flutter/material.dart';

class MarketCommodityCard extends StatelessWidget {
  final CommodityModel item;

  const MarketCommodityCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colors = context.appColors;
    final isDark = context.isDarkTheme;
    final col = item.isUp ? colors.marketUpText : colors.marketDownText;
    final bg = item.isUp ? colors.marketUpBg : colors.marketDownBg;
    final tileColor = colors.card;
    final textColor = colors.textPrimary;
    final subtitleColor = colors.textSecondary;
    final translatedName = l.tr(item.name.toLowerCase().replaceAll(' ', '_'));
    final perUnit = l.tr('per_ton_full');
    Widget leadingAvatar({required double size}) {
      return CropAvatar(crop: item.name, size: size, isDark: isDark);
    }

    return GestureDetector(
      onTap: () => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (sheetContext) {
          final sheetColors = sheetContext.appColors;
          final sheetBg = sheetColors.elevatedSurface;
          final sheetText = sheetColors.textPrimary;
          final sheetSub = sheetColors.textSecondary;
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: sheetBg,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: sheetColors.outline,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    leadingAvatar(size: 48),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            translatedName,
                            style: AppFonts.font(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: sheetText,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            perUnit,
                            style: AppFonts.font(
                              fontSize: 12,
                              color: sheetSub,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          l.tr('current_price'),
                          style: AppFonts.font(
                            fontSize: 10,
                            color: sheetSub,
                          ),
                        ),
                        Text(
                          l.isArabic
                              ? 'ج.م${l.convertNumbers(item.price.toStringAsFixed(2))}'
                              : 'EGP ${l.convertNumbers(item.price.toStringAsFixed(2))}',
                          style: AppFonts.font(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: sheetText,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: bg,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${item.isUp ? '+' : ''}${l.convertNumbers(item.changePercent.toStringAsFixed(2))}%',
                            style: AppFonts.font(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: col,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 80,
                  width: double.infinity,
                  child: CustomPaint(
                    painter: MarketSparkChartPainter(item.sparkData, col),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  l.tr('forecast_details'),
                  style: AppFonts.font(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: sheetText,
                  ),
                ),
                const SizedBox(height: 12),
                ...item.forecastDetails.map((detail) {
                  final year = detail['year'];
                  final quarter = detail['quarter'];
                  final price = (detail['price'] as num).toDouble();
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l.convertNumbers('Q$quarter $year'),
                          style: AppFonts.font(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: sheetColors.textTertiary,
                          ),
                        ),
                        Text(
                          l.isArabic
                              ? 'ج.م${l.convertNumbers(price.toStringAsFixed(2))}'
                              : 'EGP ${l.convertNumbers(price.toStringAsFixed(2))}',
                          style: AppFonts.font(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: sheetText,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 8),
              ],
            ),
          );
        },
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: tileColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withAlpha(12),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
          border: isDark ? Border.all(color: colors.outline) : null,
        ),
        child: Row(
          children: [
            // Crop icon avatar
            leadingAvatar(size: 46),
            const SizedBox(width: 12),
            // Title + unit unit label
            SizedBox(
              width: 105,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    translatedName,
                    style: AppFonts.font(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: textColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    perUnit,
                    style: AppFonts.font(
                      fontSize: 11,
                      color: subtitleColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Sparkline chart
            Expanded(
              child: SizedBox(
                height: 38,
                child: CustomPaint(
                  painter: MarketSparkChartPainter(item.sparkData, col),
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Price + change
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  l.isArabic
                      ? 'ج.م${l.convertNumbers(item.price.toStringAsFixed(2))}'
                      : 'EGP ${l.convertNumbers(item.price.toStringAsFixed(2))}',
                  style: AppFonts.font(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 3),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        item.isUp ? Icons.arrow_drop_up_rounded : Icons.arrow_drop_down_rounded,
                        color: col,
                        size: 14,
                      ),
                      Text(
                        '${item.changePercent.abs()}%',
                        style: AppFonts.font(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: col,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            // Chevron arrow button
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: colors.chipBg,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.chevron_right_rounded,
                color: colors.iconAccent,
                size: 18,
              ),
            ),
          ],
        ),

      ),
    );
  }
}
