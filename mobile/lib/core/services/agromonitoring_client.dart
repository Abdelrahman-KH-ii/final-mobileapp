import 'dart:convert';

import 'package:farmtec/core/config/agromonitoring_config.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// HTTP client for Agromonitoring polygon + NDVI history APIs.
class AgromonitoringClient {
  AgromonitoringClient({http.Client? httpClient})
      : _http = httpClient ?? http.Client();

  static const _base = 'https://api.agromonitoring.com/agro/1.0';
  static const _polyCachePrefix = 'agro_poly_';

  final http.Client _http;

  bool get isConfigured => AgromonitoringConfig.isConfigured;

  /// Registers [ring] (open or closed) and returns the remote polygon id.
  Future<String> ensurePolygon({
    required String cacheKey,
    required String name,
    required List<LatLng> ring,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString('$_polyCachePrefix$cacheKey');
    if (cached != null && cached.isNotEmpty) return cached;

    final id = await _createPolygon(name: name, ring: ring);
    await prefs.setString('$_polyCachePrefix$cacheKey', id);
    return id;
  }

  Future<String> _createPolygon({
    required String name,
    required List<LatLng> ring,
  }) async {
    final coords = _toGeoJsonRing(ring);
    final body = jsonEncode({
      'name': name,
      'geo_json': {
        'type': 'Feature',
        'properties': <String, dynamic>{},
        'geometry': {
          'type': 'Polygon',
          'coordinates': [coords],
        },
      },
    });

    final uri = Uri.parse('$_base/polygons').replace(
      queryParameters: {
        'appid': AgromonitoringConfig.apiKey,
        'duplicated': 'true',
      },
    );

    final response = await _http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode != 201) {
      throw AgromonitoringException(
        'Failed to register field polygon (${response.statusCode})',
      );
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final id = json['id'] as String?;
    if (id == null || id.isEmpty) {
      throw const AgromonitoringException('Polygon id missing in API response');
    }
    return id;
  }

  /// Latest cloud-filtered mean NDVI for [polyId] (Sentinel-2 preferred).
  Future<double> fetchLatestNdviMean(String polyId) async {
    final now = DateTime.now().toUtc();
    final start = now.subtract(const Duration(days: 90));

    final uri = Uri.parse('$_base/ndvi/history').replace(
      queryParameters: {
        'appid': AgromonitoringConfig.apiKey,
        'polyid': polyId,
        'start': '${start.millisecondsSinceEpoch ~/ 1000}',
        'end': '${now.millisecondsSinceEpoch ~/ 1000}',
      },
    );

    final response = await _http.get(uri);
    if (response.statusCode != 200) {
      throw AgromonitoringException(
        'NDVI history request failed (${response.statusCode})',
      );
    }

    final list = jsonDecode(response.body) as List<dynamic>;
    if (list.isEmpty) {
      throw const AgromonitoringException(
        'No satellite NDVI scenes yet for this field — try again in a few days',
      );
    }

    Map<String, dynamic>? best;
    var bestDt = 0;

    bool isGoodScene(Map<String, dynamic> entry) {
      final cloud = (entry['cl'] as num?)?.toDouble() ?? 100;
      final coverage = (entry['dc'] as num?)?.toDouble() ?? 0;
      return cloud <= 35 && coverage >= 5;
    }

    bool isSentinel(Map<String, dynamic> entry) {
      final source = '${entry['source']}'.toLowerCase();
      return source.contains('s2') || source.contains('sentinel');
    }

    Map<String, dynamic>? pickBest(Iterable<dynamic> items, bool Function(Map<String, dynamic>) filter) {
      Map<String, dynamic>? pick;
      var maxDt = 0;
      for (final item in items) {
        final entry = item as Map<String, dynamic>;
        if (!filter(entry)) continue;
        final data = entry['data'] as Map<String, dynamic>?;
        final mean = (data?['mean'] as num?)?.toDouble();
        if (mean == null) continue;
        final dt = (entry['dt'] as num?)?.toInt() ?? 0;
        if (dt >= maxDt) {
          maxDt = dt;
          pick = entry;
        }
      }
      return pick;
    }

    best = pickBest(
      list,
      (e) => isSentinel(e) && isGoodScene(e),
    );
    best ??= pickBest(list, isGoodScene);
    best ??= pickBest(list, (_) => true);

    final mean = (best?['data'] as Map<String, dynamic>?)?['mean'] as num?;
    if (mean == null) {
      throw const AgromonitoringException(
        'No usable NDVI values in satellite response',
      );
    }

    return mean.toDouble().clamp(-0.2, 1.0);
  }

  List<List<double>> _toGeoJsonRing(List<LatLng> ring) {
    final open = ring.isNotEmpty && ring.first == ring.last
        ? ring.sublist(0, ring.length - 1)
        : ring;

    final coords =
        open.map((p) => [p.longitude, p.latitude]).toList(growable: true);

    if (coords.isEmpty) {
      throw const AgromonitoringException('Empty field polygon');
    }

    final first = coords.first;
    final last = coords.last;
    if (first[0] != last[0] || first[1] != last[1]) {
      coords.add([first[0], first[1]]);
    }
    return coords;
  }

  void dispose() => _http.close();
}

class AgromonitoringException implements Exception {
  const AgromonitoringException(this.message);
  final String message;

  @override
  String toString() => message;
}
