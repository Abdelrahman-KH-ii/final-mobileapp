import 'package:farmtec/core/themes/pallete.dart';
import 'package:farmtec/features/market/presentation/widgets/market_view.dart';
import 'package:flutter/material.dart';

class MarketScreen extends StatelessWidget {
  const MarketScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor:
          isDark ? Pallete.darkBackground : const Color(0xFFF3F4ED),
      body: const SafeArea(child: MarketView()),
    );
  }
}
