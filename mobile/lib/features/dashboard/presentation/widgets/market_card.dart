import 'package:farmtec/core/l10n/app_localizations.dart';
import 'package:farmtec/core/themes/app_fonts.dart';
import 'package:farmtec/core/services/crop_lifecycle_service.dart';
import 'package:farmtec/core/themes/app_theme_colors.dart';
import 'package:farmtec/core/themes/pallete.dart';
import 'package:farmtec/core/widgets/crop_avatar.dart';
import 'package:farmtec/features/dashboard/presentation/utils/market_crop_utils.dart';
import 'package:flutter/material.dart';

class MarketCard extends StatelessWidget {
  final Future<List<Map<String, dynamic>>> future;
  final String cropName;
  final bool isDark;
  final Color textColor;
  final Color subColor;

  const MarketCard({
    super.key,
    required this.future,
    required this.cropName,
    required this.isDark,
    required this.textColor,
    required this.subColor,
  });

  List<Map<String, dynamic>> _filterForCrop(
    List<Map<String, dynamic>> data,
    String crop,
  ) {
    return data
        .where(
          (e) => MarketCropUtils.matchesCommodity(
            e['name']?.toString() ?? '',
            crop,
          ),
        )
        .toList();
  }

  String _priceLabel(AppLocalizations l, double? rawPrice, String fallback) {
    if (rawPrice == null) return l.convertNumbers(fallback);
    final amount = l.convertNumbers(rawPrice.toStringAsFixed(2));
    final currency = l.tr('currency_egp');
    if (l.isArabic) return '$amount $currency ${l.tr('per_ton')}';
    return '$currency $amount${l.tr('per_ton')}';
  }

  Color _panelBg(AppThemeColors colors) =>
      isDark ? colors.surfaceVariant : const Color(0xFFF3F4F0);

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final colors = context.appColors;
    final cropLabel = l.tr(CropLifecycleService.cropL10nKey(cropName));
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final panelBg = _panelBg(colors);
    final accent = isDark ? colors.iconAccent : Pallete.primary;

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: future,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return SizedBox(
            height: 110,
            child: Center(
              child: CircularProgressIndicator(color: colors.iconAccent),
            ),
          );
        }
        if (!snap.hasData || snap.data!.isEmpty) {
          return _emptyContent(l, cropLabel);
        }

        final filtered = _filterForCrop(snap.data!, cropName);
        if (filtered.isEmpty) {
          return _emptyContent(l, cropLabel);
        }

        final entry = filtered.first;
        final isUp = entry['isUp'] as bool? ?? true;
        final badgeBg = isUp ? colors.marketUpBg : colors.marketDownBg;
        final badgeFg = isUp ? colors.marketUpText : colors.marketDownText;
        // Multiply current market raw value by 10 for dashboard display per request
        final rawPrice = (entry['rawValue'] as num?)?.toDouble();
        final displayedPrice = rawPrice != null ? rawPrice * 10 : null;
        final priceText = _priceLabel(
          l,
          displayedPrice,
          entry['price']?.toString() ?? '—',
        );
        final changeText = l.convertNumbers(entry['change']?.toString() ?? '');

        final chartPanel = Expanded(
          flex: 42,
          child: Container(
            height: 110,
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
            decoration: BoxDecoration(
              color: panelBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _TrendChartPainter(
                      isUp: isUp,
                      isDark: isDark,
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: accent,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: accent.withAlpha(50),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      isUp
                          ? Icons.north_east_rounded
                          : Icons.south_east_rounded,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );

        final productPanel = Expanded(
          flex: 58,
          child: Container(
            height: 110,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              color: panelBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children:
                  isRtl
                      ? [
                        CropAvatar(crop: cropName, size: 46, isDark: isDark),
                        const SizedBox(width: 8),
                        Expanded(child: _productDetails(
                          cropLabel: cropLabel,
                          priceText: priceText,
                          changeText: changeText,
                          badgeBg: badgeBg,
                          badgeFg: badgeFg,
                          isUp: isUp,
                          l: l,
                          accent: accent,
                        )),
                      ]
                      : [
                        Expanded(child: _productDetails(
                          cropLabel: cropLabel,
                          priceText: priceText,
                          changeText: changeText,
                          badgeBg: badgeBg,
                          badgeFg: badgeFg,
                          isUp: isUp,
                          l: l,
                          accent: accent,
                        )),
                        const SizedBox(width: 8),
                        CropAvatar(crop: cropName, size: 46, isDark: isDark),
                      ],
            ),
          ),
        );

        return Row(
          children:
              isRtl
                  ? [
                    productPanel,
                    const SizedBox(width: 8),
                    chartPanel,
                  ]
                  : [
                    chartPanel,
                    const SizedBox(width: 8),
                    productPanel,
                  ],
        );
      },
    );
  }

  Widget _productDetails({
    required String cropLabel,
    required String priceText,
    required String changeText,
    required Color badgeBg,
    required Color badgeFg,
    required bool isUp,
    required AppLocalizations l,
    required Color accent,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          cropLabel,
          style: AppFonts.font(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: accent,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          l.tr('current_market_price'),
          style: AppFonts.font(fontSize: 9, color: subColor),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          priceText,
          style: AppFonts.font(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: accent,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
          decoration: BoxDecoration(
            color: badgeBg,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isUp ? Icons.north_east_rounded : Icons.south_east_rounded,
                size: 10,
                color: badgeFg,
              ),
              const SizedBox(width: 3),
              Text(
                changeText,
                style: AppFonts.font(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: badgeFg,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _emptyContent(AppLocalizations l, String cropLabel) {
    return Row(
      children: [
        Icon(Icons.show_chart_rounded, color: subColor, size: 24),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            l.trParams('no_market_for_crop', {'crop': cropLabel}),
            style: AppFonts.font(fontSize: 12, color: subColor),
          ),
        ),
      ],
    );
  }
}

class _TrendChartPainter extends CustomPainter {
  final bool isUp;
  final bool isDark;

  _TrendChartPainter({required this.isUp, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final lineColor =
        isUp
            ? (isDark ? const Color(0xFF4ADE80) : const Color(0xFF16A34A))
            : (isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626));
    final points =
        isUp
            ? [0.72, 0.58, 0.64, 0.42, 0.5, 0.35, 0.22]
            : [0.28, 0.42, 0.36, 0.55, 0.48, 0.68, 0.78];

    final path = Path();
    for (int i = 0; i < points.length; i++) {
      final x = (i / (points.length - 1)) * size.width;
      final y = points[i] * size.height;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    final fillPaint =
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              lineColor.withAlpha(isDark ? 55 : 70),
              lineColor.withAlpha(0),
            ],
          ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(fillPath, fillPaint);

    final linePaint =
        Paint()
          ..color = lineColor
          ..strokeWidth = 2.2
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, linePaint);

    for (int i = 0; i < points.length; i++) {
      final x = (i / (points.length - 1)) * size.width;
      final y = points[i] * size.height;
      canvas.drawCircle(Offset(x, y), 2.8, Paint()..color = lineColor);
      canvas.drawCircle(
        Offset(x, y),
        1.2,
        Paint()..color = Colors.white.withAlpha(isDark ? 180 : 255),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _TrendChartPainter oldDelegate) =>
      oldDelegate.isUp != isUp || oldDelegate.isDark != isDark;
}
