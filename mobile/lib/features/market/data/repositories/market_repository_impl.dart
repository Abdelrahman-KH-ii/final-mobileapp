import 'package:farmtec/features/market/data/models/commodity_model.dart';
import 'package:farmtec/features/market/domain/repositories/market_repository.dart';

class MarketRepositoryImpl implements MarketRepository {
  @override
  Future<List<CommodityModel>> fetchCommodities() async {
    // Return exactly the 7 commodities in the screenshot
    return const [
      CommodityModel(
        name: 'Green Fodder',
        unit: '/t',
        price: 235.88,
        changePercent: 38.11,
        sparkData: [170.0, 180.0, 175.0, 195.0, 200.0, 220.0, 235.88],
        category: 'Crops',
      ),
      CommodityModel(
        name: 'Jowar (Sorghum)',
        unit: '/t',
        price: 3015.05,
        changePercent: -17.52,
        sparkData: [3654.0, 3600.0, 3500.0, 3300.0, 3200.0, 3080.0, 3015.05],
        category: 'Grains',
      ),
      CommodityModel(
        name: 'Maize',
        unit: '/t',
        price: 1927.52,
        changePercent: -2.55,
        sparkData: [1978.0, 1950.0, 1930.0, 1960.0, 1955.0, 1940.0, 1927.52],
        category: 'Grains',
      ),
      CommodityModel(
        name: 'Mango',
        unit: '/t',
        price: 4727.53,
        changePercent: 19.57,
        sparkData: [3954.0, 4100.0, 4050.0, 4300.0, 4400.0, 4650.0, 4727.53],
        category: 'Fruits',
      ),
      CommodityModel(
        name: 'Potato',
        unit: '/t',
        price: 1607.44,
        changePercent: 38.61,
        sparkData: [1159.0, 1250.0, 1300.0, 1420.0, 1400.0, 1530.0, 1607.44],
        category: 'Vegetables',
      ),
      CommodityModel(
        name: 'Rice',
        unit: '/t',
        price: 3930.10,
        changePercent: 1.29,
        sparkData: [3880.0, 3850.0, 3860.0, 3840.0, 3870.0, 3890.0, 3930.10],
        category: 'Grains',
      ),
      CommodityModel(
        name: 'Tomato',
        unit: '/t',
        price: 2680.89,
        changePercent: -4.40,
        sparkData: [2804.0, 2750.0, 2760.0, 2710.0, 2730.0, 2695.0, 2680.89],
        category: 'Vegetables',
      ),
    ];
  }
}
