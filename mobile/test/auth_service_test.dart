import 'dart:convert';
import 'package:farmtec/core/services/api_client.dart';
import 'package:farmtec/core/services/auth_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({
      'auth_access_token': 'fake_access_token',
      'auth_refresh_token': 'fake_refresh_token',
    });
  });

  test('AuthService restoreSession loads user successfully', () async {
    final client = MockClient((request) async {
      expect(request.url.path, endsWith('/auth/profile/'));
      expect(request.method, 'GET');
      expect(request.headers['Authorization'], 'Bearer fake_access_token');
      
      return http.Response(
        jsonEncode({
          'success': true,
          'data': {
            'id': 1,
            'email': 'farmer@test.com',
            'username': 'farmer_bob',
            'full_name': 'Farmer Bob',
            'phone_number': '1234567890',
            'role': 'Farmer',
            'location': 'Cairo, Egypt'
          }
        }),
        200,
        headers: {'content-type': 'application/json'},
      );
    });

    final apiClient = ApiClient(httpClient: client);
    final authService = AuthService(apiClient: apiClient);

    final restored = await authService.restoreSession();
    expect(restored, isTrue);
    expect(authService.user, isNotNull);
    expect(authService.user!.email, 'farmer@test.com');
    expect(authService.user!.fullName, 'Farmer Bob');
  });

  test('AuthService updateProfile updates user details', () async {
    final client = MockClient((request) async {
      expect(request.url.path, endsWith('/auth/profile/'));
      expect(request.method, 'PUT');
      
      final body = jsonDecode(request.body) as Map<String, dynamic>;
      expect(body['full_name'], 'Bob Updated');
      expect(body['phone_number'], '0987654321');

      return http.Response(
        jsonEncode({
          'success': true,
          'data': {
            'id': 1,
            'email': 'farmer@test.com',
            'username': 'farmer_bob',
            'full_name': 'Bob Updated',
            'phone_number': '0987654321',
            'role': 'Farmer',
            'location': 'Cairo, Egypt'
          }
        }),
        200,
        headers: {'content-type': 'application/json'},
      );
    });

    final apiClient = ApiClient(httpClient: client);
    final authService = AuthService(apiClient: apiClient);

    await authService.updateProfile(
      fullName: 'Bob Updated',
      phoneNumber: '0987654321',
    );

    expect(authService.user, isNotNull);
    expect(authService.user!.fullName, 'Bob Updated');
    expect(authService.user!.phoneNumber, '0987654321');
  });

  test('AuthService changePassword posts request to backend', () async {
    final client = MockClient((request) async {
      expect(request.url.path, endsWith('/auth/change-password/'));
      expect(request.method, 'POST');
      
      final body = jsonDecode(request.body) as Map<String, dynamic>;
      expect(body['old_password'], 'old_pass_123');
      expect(body['new_password'], 'new_pass_456');

      return http.Response(
        jsonEncode({
          'success': true,
          'message': 'Password changed successfully.'
        }),
        200,
        headers: {'content-type': 'application/json'},
      );
    });

    final apiClient = ApiClient(httpClient: client);
    final authService = AuthService(apiClient: apiClient);

    // Call service changePassword, should complete without throwing exception
    await authService.changePassword(
      oldPassword: 'old_pass_123',
      newPassword: 'new_pass_456',
    );
  });
}
