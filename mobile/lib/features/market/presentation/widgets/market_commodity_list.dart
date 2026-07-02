import 'package:farmtec/features/market/data/models/commodity_model.dart';
import 'package:farmtec/features/market/presentation/widgets/market_commodity_card.dart';
import 'package:flutter/material.dart';

class MarketCommodityList extends StatelessWidget {
  final List<CommodityModel> items;
  final double bottomPadding;

  const MarketCommodityList({
    super.key,
    required this.items,
    required this.bottomPadding,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(20, 4, 20, bottomPadding),
      itemCount: items.length,
      itemBuilder: (_, i) => MarketCommodityCard(item: items[i]),
    );
  }
}
