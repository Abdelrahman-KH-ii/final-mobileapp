import 'package:farmtec/core/l10n/app_localizations.dart';
import 'package:farmtec/core/themes/app_fonts.dart';
import 'package:farmtec/features/market/data/models/commodity_model.dart';
import 'package:farmtec/features/market/presentation/widgets/market_banner_stat.dart';
import 'package:flutter/material.dart';

class MarketBanner extends StatelessWidget {
  final List<CommodityModel> items;

  const MarketBanner({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    final l = AppLocalizations.of(context);
    final featured = items.take(3).toList();

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: const Color(0xFF0C291F),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(
                Icons.show_chart_rounded,
                size: 15,
                color: Color(0xFFFFB800),
              ),
              const SizedBox(width: 6),
              Text(
                l.tr('market_snapshot'),
                style: AppFonts.font(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withAlpha(180),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < featured.length; i++) ...[
                  if (i > 0)
                    Container(
                      width: 1,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      color: Colors.white.withAlpha(20),
                    ),
                  Expanded(
                    child: MarketBannerStat(featured[i]),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
