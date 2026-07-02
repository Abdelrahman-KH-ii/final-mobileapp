class CommodityModel {
  final String name;
  final String unit;
  final double price;
  final double changePercent;
  final List<double> sparkData;
  final String category; // 'crop' | 'fertilizer'
  final List<Map<String, dynamic>> forecastDetails;

  const CommodityModel({
    required this.name,
    required this.unit,
    required this.price,
    required this.changePercent,
    required this.sparkData,
    required this.category,
    this.forecastDetails = const [],
  });

  bool get isUp => changePercent >= 0;
}
