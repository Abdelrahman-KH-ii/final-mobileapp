import 'package:farmtec/core/l10n/app_localizations.dart';
import 'package:farmtec/core/themes/app_fonts.dart';
import 'package:farmtec/core/themes/app_theme_colors.dart';
import 'package:farmtec/core/themes/pallete.dart';
import 'package:farmtec/features/market/data/models/commodity_model.dart';
import 'package:farmtec/features/market/data/repositories/market_repository_impl.dart';
import 'package:farmtec/features/market/domain/repositories/market_repository.dart';
import 'package:farmtec/features/market/presentation/widgets/market_banner.dart';
import 'package:farmtec/features/market/presentation/widgets/market_commodity_list.dart';
import 'package:flutter/material.dart';

class MarketView extends StatefulWidget {
  const MarketView({super.key, this.bottomPadding = 100});

  final double bottomPadding;

  @override
  State<MarketView> createState() => _MarketViewState();
}

class _MarketViewState extends State<MarketView> {
  late Future<List<CommodityModel>> _commoditiesFuture;
  final MarketRepository _repository = MarketRepositoryImpl();

  String _selectedCategory =
      'All'; // 'All' | 'Crops' | 'Fruits' | 'Vegetables' | 'Grains'
  String _sortOption =
      'Default'; // 'Default' | 'PriceHigh' | 'PriceLow' | 'ChangeHigh'

  @override
  void initState() {
    super.initState();
    _commoditiesFuture = _repository.fetchCommodities();
  }

  List<CommodityModel> _filterAndSort(List<CommodityModel> rawList) {
    // Copy first — repository returns a const list that cannot be sorted in place.
    var list = List<CommodityModel>.from(rawList);
    if (_selectedCategory != 'All') {
      list =
          list
              .where(
                (item) =>
                    item.category.toLowerCase() ==
                    _selectedCategory.toLowerCase(),
              )
              .toList();
    }

    // 2. Sort by option
    switch (_sortOption) {
      case 'PriceHigh':
        list.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'PriceLow':
        list.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'ChangeHigh':
        list.sort(
          (a, b) => b.changePercent.abs().compareTo(a.changePercent.abs()),
        );
        break;
      default:
        // 'Default' (preserve repository order)
        break;
    }
    return list;
  }

  Widget _buildFilterChip({
    required BuildContext context,
    required String id,
    required String label,
    required IconData? icon,
    required bool isDark,
  }) {
    final colors = context.appColors;
    final isSelected = _selectedCategory == id;
    final activeBg = const Color(0xFF0C291F); // dark forest green
    final inactiveBg = colors.chipBg;
    final activeText = Colors.white;
    final inactiveText = colors.textSecondary;
    final borderColor = colors.outline;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = id;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? activeBg : inactiveBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? activeBg : borderColor),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: activeBg.withAlpha(40),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                  : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 14,
                color: isSelected ? Colors.white70 : Colors.grey.shade500,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: AppFonts.font(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
                color: isSelected ? activeText : inactiveText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSortButton(BuildContext context, AppLocalizations l, bool isDark) {
    final colors = context.appColors;
    final borderColor = colors.outline;
    return PopupMenuButton<String>(
      icon: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: colors.chipBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.tune_rounded, size: 14, color: colors.textTertiary),
            const SizedBox(width: 6),
            Text(
              l.tr('sort'),
              style: AppFonts.font(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: colors.textPrimary,
              ),
            ),
          ],
        ),
      ),
      offset: const Offset(0, 42),
      onSelected: (val) {
        setState(() {
          _sortOption = val;
        });
      },
      itemBuilder:
          (context) => [
            PopupMenuItem(
              value: 'Default',
              child: Text(
                l.tr('sort_default'),
                style: AppFonts.font(fontSize: 13),
              ),
            ),
            PopupMenuItem(
              value: 'PriceHigh',
              child: Text(
                l.tr('sort_price_high'),
                style: AppFonts.font(fontSize: 13),
              ),
            ),
            PopupMenuItem(
              value: 'PriceLow',
              child: Text(
                l.tr('sort_price_low'),
                style: AppFonts.font(fontSize: 13),
              ),
            ),
            PopupMenuItem(
              value: 'ChangeHigh',
              child: Text(
                l.tr('sort_change_high'),
                style: AppFonts.font(fontSize: 13),
              ),
            ),
          ],
    );
  }

  Widget _buildHeader(
    BuildContext context,
    AppLocalizations l,
    bool isDark,
    AppThemeColors colors,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l.tr('market_prices'),
          style: AppFonts.font(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: context.screenHeaderTitle,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: isDark ? Pallete.chartGreen : Pallete.success,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                l.tr('market_subtitle'),
                style: AppFonts.font(
                  fontSize: 12,
                  color: context.screenHeaderSubtitle,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final isDark = context.isDarkTheme;
    final bgColor = colors.background;
    final l = AppLocalizations.of(context);
    final topPadding = MediaQuery.of(context).padding.top;

    return Stack(
      children: [
        // ── Background illustration (matches dashboard / my farm) ──────────
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SizedBox(
            height: 240 + topPadding,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  'assets/images/market_illus.png',
                  fit: BoxFit.cover,
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          bgColor.withAlpha(0),
                          bgColor,
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.black.withAlpha(100)
                        : Colors.white.withAlpha(30),
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Content ────────────────────────────────────────────────────────
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(20, topPadding + 16, 20, 0),
              child: _buildHeader(context, l, isDark, colors),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: FutureBuilder<List<CommodityModel>>(
            future: _commoditiesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError ||
                  !snapshot.hasData ||
                  snapshot.data!.isEmpty) {
                return Center(
                  child: Text(
                    l.tr('failed_to_load_market'),
                    style: AppFonts.font(color: Colors.grey),
                  ),
                );
              }

              final items = snapshot.data!;
              final filteredItems = _filterAndSort(items);

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: MarketBanner(items: items),
                  ),
                  const SizedBox(height: 12),

                  // 2. Filter & sort action row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _buildFilterChip(
                                  context: context,
                                  id: 'All',
                                  label: l.tr('all_commodities'),
                                  icon: null,
                                  isDark: isDark,
                                ),
                                const SizedBox(width: 8),
                                _buildFilterChip(
                                  context: context,
                                  id: 'Crops',
                                  label: l.tr('crops'),
                                  icon: Icons.eco_rounded,
                                  isDark: isDark,
                                ),
                                const SizedBox(width: 8),
                                _buildFilterChip(
                                  context: context,
                                  id: 'Fruits',
                                  label: l.tr('fruits'),
                                  icon: Icons.eco_rounded,
                                  isDark: isDark,
                                ),
                                const SizedBox(width: 8),
                                _buildFilterChip(
                                  context: context,
                                  id: 'Vegetables',
                                  label: l.tr('vegetables'),
                                  icon: Icons.grass_rounded,
                                  isDark: isDark,
                                ),
                                const SizedBox(width: 8),
                                _buildFilterChip(
                                  context: context,
                                  id: 'Grains',
                                  label: l.tr('grains'),
                                  icon: Icons.grain_rounded,
                                  isDark: isDark,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        _buildSortButton(context, l, isDark),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // 3. Commodity list
                  Expanded(
                    child: MarketCommodityList(
                      items: filteredItems,
                      bottomPadding: widget.bottomPadding,
                    ),
                  ),
                ],
              );
            },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
