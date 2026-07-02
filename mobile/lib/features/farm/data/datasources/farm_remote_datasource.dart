import 'package:farmtec/core/services/api_client.dart';
import 'package:farmtec/features/farm/domain/entities/farm.dart';

class FarmRemoteDataSource {
  FarmRemoteDataSource({ApiClient? apiClient})
      : _api = apiClient ?? ApiClient();

  final ApiClient _api;

  Future<List<Farm>> fetchFarms() async {
    final response = await _api.get('farms/');
    final data = response['data'] as List<dynamic>;
    return data
        .map((item) => Farm.fromApiJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Farm> createFarm(Map<String, dynamic> payload) async {
    final response = await _api.post('farms/', body: payload);
    return Farm.fromApiJson(response['data'] as Map<String, dynamic>);
  }

  Future<Farm> updateFarm(String id, Map<String, dynamic> payload) async {
    final response = await _api.put('farms/$id/', body: payload);
    return Farm.fromApiJson(response['data'] as Map<String, dynamic>);
  }

  Future<void> deleteFarm(String id) async {
    await _api.delete('farms/$id/');
  }

  Future<Map<String, dynamic>> fetchDashboard() async {
    final response = await _api.get('dashboard/');
    return Map<String, dynamic>.from(response['data'] as Map);
  }
}
