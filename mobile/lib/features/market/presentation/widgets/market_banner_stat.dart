import 'package:farmtec/core/l10n/app_localizations.dart';
import 'package:farmtec/core/themes/app_fonts.dart';
import 'package:farmtec/core/widgets/crop_avatar.dart';
import 'package:farmtec/features/market/data/models/commodity_model.dart';
import 'package:farmtec/features/market/presentation/widgets/market_spark_chart.dart';
import 'package:flutter/material.dart';

class MarketBannerStat extends StatelessWidget {
  final CommodityModel item;

  const MarketBannerStat(this.item, {super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final translatedName = l.tr(item.name.toLowerCase().replaceAll(' ', '_'));

    final changeColor =
        item.isUp ? const Color(0xFF4ADE80) : const Color(0xFFFCA5A5);
    final chartColor =
        item.isUp ? const Color(0xFF4ADE80) : const Color(0xFFEF4444);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(20),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(3),
              child: CropAvatar(crop: item.name, size: 24, isDark: true),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    translatedName,
                    style: AppFonts.font(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withAlpha(180),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '\$${item.price.toStringAsFixed(2)}',
                    style: AppFonts.font(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        item.isUp
                            ? Icons.arrow_drop_up_rounded
                            : Icons.arrow_drop_down_rounded,
                        color: changeColor,
                        size: 14,
                      ),
                      Text(
                        '${item.changePercent.abs()}%',
                        style: AppFonts.font(
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                          color: changeColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 18,
          width: double.infinity,
          child: CustomPaint(
            painter: MarketSparkChartPainter(
              item.sparkData,
              chartColor,
              showGradient: false,
            ),
          ),
        ),
      ],
    );
  }
}
