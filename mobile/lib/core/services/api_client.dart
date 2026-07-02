import 'dart:convert';

import 'package:farmtec/core/config/api_config.dart';
import 'package:farmtec/core/exceptions/api_exception.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// HTTP client for Django mobile API (`/api/mobile/`).
class ApiClient {
  ApiClient({http.Client? httpClient}) : _http = httpClient ?? http.Client();

  final http.Client _http;

  static const _accessKey = 'auth_access_token';
  static const _refreshKey = 'auth_refresh_token';

  Future<String?> get accessToken async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessKey);
  }

  Future<void> saveTokens({required String access, required String refresh}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessKey, access);
    await prefs.setString(_refreshKey, refresh);
  }

  Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessKey);
    await prefs.remove(_refreshKey);
  }

  Future<bool> get isAuthenticated async {
    final token = await accessToken;
    return token != null && token.isNotEmpty;
  }

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, String>? query,
    bool auth = true,
  }) async {
    final uri = _uri(path, query);
    final response = await _send(() async {
      final headers = await _headers(auth: auth);
      return _http.get(uri, headers: headers).timeout(const Duration(seconds: 30));
    });
    return _parseMobileEnvelope(response);
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
    bool auth = true,
  }) async {
    final uri = _uri(path);
    final response = await _send(() async {
      final headers = await _headers(auth: auth);
      return _http
          .post(uri, headers: headers, body: jsonEncode(body ?? {}))
          .timeout(const Duration(seconds: 60));
    });
    return _parseMobileEnvelope(response);
  }

  Future<Map<String, dynamic>> put(
    String path, {
    Map<String, dynamic>? body,
    bool auth = true,
  }) async {
    final uri = _uri(path);
    final response = await _send(() async {
      final headers = await _headers(auth: auth);
      return _http
          .put(uri, headers: headers, body: jsonEncode(body ?? {}))
          .timeout(const Duration(seconds: 30));
    });
    return _parseMobileEnvelope(response);
  }

  Future<void> delete(String path, {bool auth = true}) async {
    final uri = _uri(path);
    final response = await _send(() async {
      final headers = await _headers(auth: auth);
      return _http.delete(uri, headers: headers).timeout(const Duration(seconds: 30));
    });
    if (response.statusCode == 204) return;
    _parseMobileEnvelope(response);
  }

  Future<Map<String, dynamic>> postMultipart(
    String path, {
    required String fileField,
    required List<int> fileBytes,
    required String filename,
    Map<String, String>? fields,
    bool auth = true,
  }) async {
    final uri = _uri(path);
    final response = await _send(() async {
      final request = http.MultipartRequest('POST', uri);
      final headers = await _headers(auth: auth, json: false);
      request.headers.addAll(headers);
      if (fields != null) request.fields.addAll(fields);
      request.files.add(http.MultipartFile.fromBytes(
        fileField,
        fileBytes,
        filename: filename,
      ));
      final streamed = await request.send().timeout(const Duration(seconds: 90));
      return http.Response.fromStream(streamed);
    });
    return _parseMobileEnvelope(response);
  }

  Future<Map<String, dynamic>> postRaw(
    String path, {
    required Map<String, dynamic> body,
    bool auth = true,
  }) async {
    final uri = _uri(path);
    final response = await _send(() async {
      final headers = await _headers(auth: auth);
      return _http
          .post(uri, headers: headers, body: jsonEncode(body))
          .timeout(const Duration(seconds: 60));
    });
    return _parseAuthOrMobileEnvelope(response);
  }

  Uri _uri(String path, [Map<String, String>? query]) {
    final url = path.startsWith('http') ? path : ApiConfig.mobilePath(path);
    return Uri.parse(url).replace(queryParameters: query);
  }

  Future<Map<String, String>> _headers({
    required bool auth,
    bool json = true,
  }) async {
    final headers = <String, String>{};
    if (json) headers['Content-Type'] = 'application/json';
    if (auth) {
      final token = await accessToken;
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  Future<http.Response> _send(
    Future<http.Response> Function() request,
  ) async {
    var response = await request();
    if (response.statusCode == 401) {
      final refreshed = await _tryRefreshToken();
      if (refreshed) response = await request();
    }
    return response;
  }

  Future<bool> _tryRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    final refresh = prefs.getString(_refreshKey);
    if (refresh == null || refresh.isEmpty) return false;

    try {
      final response = await _http.post(
        Uri.parse(ApiConfig.mobilePath('auth/token/refresh/')),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh': refresh}),
      );
      if (response.statusCode != 200) return false;
      final body = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      final access = body['access'] as String?;
      if (access == null) return false;
      await prefs.setString(_accessKey, access);
      return true;
    } catch (_) {
      return false;
    }
  }

  Map<String, dynamic> _parseMobileEnvelope(http.Response response) {
    final status = response.statusCode;
    Map<String, dynamic> body;
    try {
      body = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    } catch (_) {
      throw ApiException('Invalid server response ($status)', statusCode: status);
    }

    if (status >= 200 && status < 300) {
      if (body['success'] == false) {
        throw ApiException(_errorMessage(body), statusCode: status);
      }
      return body;
    }

    throw ApiException(_errorMessage(body), statusCode: status);
  }

  Map<String, dynamic> _parseAuthOrMobileEnvelope(http.Response response) {
    final status = response.statusCode;
    Map<String, dynamic> body;
    try {
      body = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    } catch (_) {
      throw ApiException('Invalid server response ($status)', statusCode: status);
    }

    if (status >= 200 && status < 300) {
      if (body['success'] == false) {
        throw ApiException(_errorMessage(body), statusCode: status);
      }
      return body;
    }

    throw ApiException(_errorMessage(body), statusCode: status);
  }

  String _errorMessage(Map<String, dynamic> body) {
    final error = body['error'];
    if (error is String) return error;
    if (error is Map) return error.toString();
    if (error is List) return error.join(', ');
    return 'Request failed';
  }

  void dispose() => _http.close();
}
