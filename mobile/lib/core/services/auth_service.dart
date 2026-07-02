import 'package:farmtec/core/exceptions/api_exception.dart';
import 'package:farmtec/core/services/api_client.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthUser {
  const AuthUser({
    required this.id,
    required this.email,
    required this.username,
    this.fullName,
    this.phoneNumber,
    this.location,
    this.role,
  });

  final int id;
  final String email;
  final String username;
  final String? fullName;
  final String? phoneNumber;
  final String? location;
  final String? role;

  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
        id: json['id'] as int,
        email: json['email']?.toString() ?? '',
        username: json['username']?.toString() ?? '',
        fullName: json['full_name']?.toString(),
        phoneNumber: json['phone_number']?.toString(),
        location: json['location']?.toString(),
        role: json['role']?.toString(),
      );
}

class AuthService extends ChangeNotifier {
  AuthService({ApiClient? apiClient}) : _api = apiClient ?? ApiClient();

  final ApiClient _api;

  AuthUser? _user;
  bool _loading = false;
  String? _error;

  AuthUser? get user => _user;
  bool get isLoading => _loading;
  String? get error => _error;
  ApiClient get apiClient => _api;

  Future<bool> restoreSession() async {
    if (!await _api.isAuthenticated) return false;
    try {
      final response = await _api.get('auth/profile/');
      final data = response['data'] as Map<String, dynamic>;
      _user = AuthUser.fromJson(data);
      _error = null;
      notifyListeners();
      return true;
    } catch (_) {
      await _api.clearTokens();
      _user = null;
      notifyListeners();
      return false;
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    try {
      final response = await _api.postRaw(
        'auth/login/',
        body: {'email': email.trim(), 'password': password},
        auth: false,
      );
      await _api.saveTokens(
        access: response['access'] as String,
        refresh: response['refresh'] as String,
      );
      _user = AuthUser.fromJson(response['user'] as Map<String, dynamic>);
      _error = null;
    } on ApiException catch (e) {
      _error = e.message;
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> register({
    required String email,
    required String username,
    required String password,
    String? phoneNumber,
    String? fullName,
    String? location,
  }) async {
    _setLoading(true);
    try {
      final response = await _api.postRaw(
        'auth/register/',
        body: {
          'email': email.trim(),
          'username': username.trim(),
          'password': password,
          if (phoneNumber != null && phoneNumber.isNotEmpty)
            'phone_number': phoneNumber.trim(),
          if (fullName != null && fullName.isNotEmpty) 'full_name': fullName.trim(),
          if (location != null && location.isNotEmpty) 'location': location.trim(),
        },
        auth: false,
      );
      await _api.saveTokens(
        access: response['access'] as String,
        refresh: response['refresh'] as String,
      );
      _user = AuthUser.fromJson(response['user'] as Map<String, dynamic>);
      _error = null;
    } on ApiException catch (e) {
      _error = e.message;
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateProfile({
    String? username,
    String? phoneNumber,
    String? fullName,
    String? location,
  }) async {
    _setLoading(true);
    try {
      final response = await _api.put(
        'auth/profile/',
        body: {
          if (username != null) 'username': username.trim(),
          if (phoneNumber != null) 'phone_number': phoneNumber.trim(),
          if (fullName != null) 'full_name': fullName.trim(),
          if (location != null) 'location': location.trim(),
        },
      );
      final data = response['data'] as Map<String, dynamic>;
      _user = AuthUser.fromJson(data);
      _error = null;
      notifyListeners();
    } on ApiException catch (e) {
      _error = e.message;
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    _setLoading(true);
    try {
      await _api.post(
        'auth/change-password/',
        body: {
          'old_password': oldPassword,
          'new_password': newPassword,
        },
      );
      _error = null;
    } on ApiException catch (e) {
      _error = e.message;
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final refresh = prefs.getString('auth_refresh_token');
      if (refresh != null) {
        await _api.post('auth/logout/', body: {'refresh': refresh});
      }
    } catch (_) {
      // Best-effort logout; clear local session regardless.
    } finally {
      await _api.clearTokens();
      _user = null;
      notifyListeners();
    }
  }

  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }
}
