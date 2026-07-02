import 'dart:ui' show Color;

import 'package:farmtec/core/map/field_boundary.dart';
import 'package:farmtec/core/map/field_grid.dart';
import 'package:farmtec/core/services/agromonitoring_client.dart';
import 'package:latlong2/latlong.dart';

/// Vegetation index zone with a field sub-polygon and measured NDVI.
class NdviZoneData {
  final List<LatLng> polygon;
  final double ndvi;

  const NdviZoneData({
    required this.polygon,
    required this.ndvi,
  });
}

class NdviAnalysisResult {
  final List<NdviZoneData> zones;
  final List<LatLng> fieldBoundary;
  final double averageNdvi;
  final DateTime? sceneDate;

  const NdviAnalysisResult({
    required this.zones,
    required this.fieldBoundary,
    required this.averageNdvi,
    this.sceneDate,
  });

  String get healthStatus {
    if (averageNdvi >= 0.6) return 'healthy';
    if (averageNdvi >= 0.4) return 'warning';
    return 'critical';
  }
}

/// Fetches Sentinel-2/Landsat NDVI for grid cells inside the farm boundary.
class NdviService {
  NdviService({AgromonitoringClient? client})
      : _client = client ?? AgromonitoringClient();

  final AgromonitoringClient _client;

  static const _evalscriptHint =
      'Configure AGROMONITORING_API_KEY — free at agromonitoring.com';

  Future<NdviAnalysisResult> analyze({
    required String farmId,
    required double lat,
    required double lng,
    required String area,
  }) async {
    if (!_client.isConfigured) {
      throw const AgromonitoringException(_evalscriptHint);
    }

    final hectares = FieldBoundary.parseHectares(area);
    final boundary = FieldBoundary.fromCenter(
      lat: lat,
      lng: lng,
      hectares: hectares,
      orientationSeed: farmId,
    );

    final cellRings = FieldGrid.cells(boundary);

    final zones = await Future.wait(
      List.generate(cellRings.length, (i) async {
        final ring = cellRings[i];
        final row = i ~/ FieldGrid.defaultCols;
        final col = i % FieldGrid.defaultCols;
        final cacheKey =
            '${farmId}_${lat.toStringAsFixed(5)}_${lng.toStringAsFixed(5)}_${hectares.toStringAsFixed(2)}_${row}_$col';

        final polyId = await _client.ensurePolygon(
          cacheKey: cacheKey,
          name: 'farmtec_${farmId}_$row$col',
          ring: ring,
        );

        final ndvi = await _client.fetchLatestNdviMean(polyId);
        return NdviZoneData(polygon: ring, ndvi: ndvi);
      }),
    );

    if (zones.isEmpty) {
      throw const AgromonitoringException('No NDVI zones computed for this field');
    }

    final averageNdvi =
        zones.map((z) => z.ndvi).reduce((a, b) => a + b) / zones.length;

    return NdviAnalysisResult(
      zones: zones,
      fieldBoundary: boundary.drawRing,
      averageNdvi: averageNdvi,
    );
  }

  /// Map NDVI value to legend / overlay color.
  static Color colorForNdvi(double value) {
    if (value >= 0.62) return const Color(0xFF1B8F3A);
    if (value >= 0.48) return const Color(0xFF67B346);
    if (value >= 0.36) return const Color(0xFFFF9800);
    return const Color(0xFFF44336);
  }

  /// Color band index for tests: 0=red, 1=orange, 2=light green, 3=dark green.
  static int colorBandIndex(double value) {
    if (value >= 0.62) return 3;
    if (value >= 0.48) return 2;
    if (value >= 0.36) return 1;
    return 0;
  }
}
