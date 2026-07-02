import 'package:farmtec/core/services/api_client.dart';
import 'package:farmtec/core/services/market_api_service.dart';
import 'package:farmtec/features/market/data/models/commodity_model.dart';
import 'package:farmtec/features/market/domain/repositories/market_repository.dart';

class MarketRepositoryImpl implements MarketRepository {
  MarketRepositoryImpl({MarketApiService? apiService, ApiClient? apiClient})
      : _api = apiService ?? MarketApiService(apiClient: apiClient);

  final MarketApiService _api;

  @override
  Future<List<CommodityModel>> fetchCommodities() async {
    final names = await _api.fetchCommodityNames();
    if (names.isEmpty) {
      throw Exception('No commodity data available');
    }

    final commodities = <CommodityModel>[];
    for (final name in names) {
      try {
        final forecast = await _api.fetchForecast(name);
        if (forecast.isEmpty) continue;

        final prices = forecast
            .map((row) => (row['price'] as num?)?.toDouble())
            .whereType<double>()
            .toList();
        if (prices.isEmpty) continue;

        final first = prices.first;
        final last = prices.last;
        final change =
            first != 0 ? ((last - first) / first) * 100 : 0.0;

        commodities.add(
          CommodityModel(
            name: name,
            unit: '/t',
            price: last,
            changePercent: change,
            sparkData: prices,
            category: _categoryFor(name),
            forecastDetails: forecast,
          ),
        );
      } catch (_) {
        continue;
      }
    }

    if (commodities.isEmpty) {
      throw Exception('Failed to load market forecasts');
    }

    return commodities;
  }

  String _categoryFor(String name) {
    final key = name.toLowerCase();
    if (key.contains('mango')) return 'Fruits';
    if (key.contains('tomato') || key.contains('potato')) return 'Vegetables';
    if (key.contains('fodder')) return 'Crops';
    if (key.contains('wheat') ||
        key.contains('rice') ||
        key.contains('maize') ||
        key.contains('corn') ||
        key.contains('jowar') ||
        key.contains('sorghum')) {
      return 'Grains';
    }
    return 'Crops';
  }
}
