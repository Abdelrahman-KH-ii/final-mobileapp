import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SoilHealthService extends ChangeNotifier {
  static bool isInEgyptLocation(double lat, double lng) {
    return lat >= 22.0 && lat <= 32.0 && lng >= 24.0 && lng <= 37.0;
  }

  static double scoreFromPayload(dynamic decoded) {
    if (decoded is Map<String, dynamic>) {
      final payload = decoded['data'] ?? decoded['result'] ?? decoded;
      if (payload is Map<String, dynamic>) {
        final raw = payload['overall_score'] ?? payload['score'] ?? payload['soil_score'];
        if (raw is num) {
          return raw.toDouble().clamp(0.0, 100.0);
        }
      }
    }
    return 0.0;
  }
  static const _cacheKey = 'soil_health_cache_v1';
  static const _endpoint = 'https://youssef-d1aa-soil-health.hf.space/api/soil-health/';

  final Map<String, double> _memoryCache = {};

  Future<double> getScoreForLocation({
    required double lat,
    required double lng,
    bool forceRefresh = false,
  }) async {
    final normalizedLat = double.parse(lat.toStringAsFixed(4));
    final normalizedLng = double.parse(lng.toStringAsFixed(4));
    final key = '${normalizedLat.toStringAsFixed(4)},${normalizedLng.toStringAsFixed(4)}';

    if (!forceRefresh) {
      final cached = _memoryCache[key];
      if (cached != null) {
        return cached;
      }

      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_cacheKey);
      if (raw != null) {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic> && decoded.containsKey(key)) {
          final value = decoded[key];
          if (value is num) {
            final score = value.toDouble().clamp(0.0, 100.0);
            _memoryCache[key] = score;
            return score;
          }
        }
      }
    }

    if (!SoilHealthService.isInEgyptLocation(normalizedLat, normalizedLng)) {
      await _cacheValue(key, 0.0);
      return 0.0;
    }

    try {
      final response = await http
          .post(
            Uri.parse(_endpoint),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'lat': normalizedLat, 'lon': normalizedLng}),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(utf8.decode(response.bodyBytes));
        final score = _extractScore(decoded);
        await _cacheValue(key, score);
        return score;
      }
    } catch (_) {}

    await _cacheValue(key, 0.0);
    return 0.0;
  }

  double _extractScore(dynamic decoded) => SoilHealthService.scoreFromPayload(decoded);

  Future<void> _cacheValue(String key, double score) async {
    _memoryCache[key] = score;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cacheKey);
    final Map<String, dynamic> cache = raw != null ? jsonDecode(raw) as Map<String, dynamic> : {};
    cache[key] = score;
    await prefs.setString(_cacheKey, jsonEncode(cache));
  }
}
