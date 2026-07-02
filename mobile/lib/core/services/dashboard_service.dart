import 'package:farmtec/core/services/api_client.dart';

class DashboardService {
  DashboardService({ApiClient? apiClient}) : _api = apiClient ?? ApiClient();

  final ApiClient _api;

  Future<Map<String, dynamic>> fetchDashboard() async {
    final response = await _api.get('dashboard/');
    return Map<String, dynamic>.from(response['data'] as Map);
  }
}
