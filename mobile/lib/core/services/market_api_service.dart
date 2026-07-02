import 'package:farmtec/core/services/api_client.dart';

class MarketApiService {
  MarketApiService({ApiClient? apiClient}) : _api = apiClient ?? ApiClient();

  final ApiClient _api;

  Future<List<String>> fetchCommodityNames() async {
    final response = await _api.get('ai/forecast/');
    final data = response['data'] as Map<String, dynamic>;
    final commodities = data['commodities'] as List<dynamic>? ?? [];
    return commodities.map((e) => e.toString()).toList();
  }

  Future<List<Map<String, dynamic>>> fetchForecast(String commodity) async {
    final response = await _api.get(
      'ai/forecast/',
      query: {'commodity': commodity},
    );
    final data = response['data'] as Map<String, dynamic>;
    final forecast = data['forecast'] as List<dynamic>? ?? [];
    return forecast
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }
}
