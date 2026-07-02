import 'dart:math' as math;

import 'package:latlong2/latlong.dart';

/// Farm field outline derived from GPS center and registered area (hectares).
class FieldBoundary {
  FieldBoundary({
    required this.ring,
    required this.hectares,
  });

  /// Closed ring (first point repeated at end).
  final List<LatLng> ring;

  final double hectares;

  /// Open ring for map drawing (no duplicate closing vertex).
  List<LatLng> get drawRing {
    if (ring.length < 2) return ring;
    if (ring.first == ring.last) return ring.sublist(0, ring.length - 1);
    return ring;
  }

  LatLng get center {
    final open = drawRing;
    if (open.isEmpty) return const LatLng(0, 0);
    var lat = 0.0;
    var lng = 0.0;
    for (final p in open) {
      lat += p.latitude;
      lng += p.longitude;
    }
    return LatLng(lat / open.length, lng / open.length);
  }

  /// Parses values like `42.2 ha`, `10`, or `15.5`.
  static double parseHectares(String area) {
    final match = RegExp(r'([\d.]+)').firstMatch(area.trim());
    if (match == null) return 5.0;
    final value = double.tryParse(match.group(1)!);
    if (value == null || value <= 0) return 5.0;
    return value.clamp(0.1, 3000.0);
  }

  /// Builds a geodesically sized rectangle around [lat]/[lng].
  static FieldBoundary fromCenter({
    required double lat,
    required double lng,
    required double hectares,
    required String orientationSeed,
    double aspectRatio = 1.35,
  }) {
    final areaM2 = hectares * 10000;
    final widthM = math.sqrt(areaM2 / aspectRatio);
    final heightM = areaM2 / widthM;
    final rotation = _rotationFromSeed(orientationSeed);

    final halfW = widthM / 2;
    final halfH = heightM / 2;
    final corners = <LatLng>[
      _offsetMeters(lat, lng, -halfW, -halfH, rotation),
      _offsetMeters(lat, lng, halfW, -halfH, rotation),
      _offsetMeters(lat, lng, halfW, halfH, rotation),
      _offsetMeters(lat, lng, -halfW, halfH, rotation),
    ];

    final closed = [...corners, corners.first];
    return FieldBoundary(ring: closed, hectares: hectares);
  }

  static double _rotationFromSeed(String seed) {
    var hash = 0;
    for (final code in seed.codeUnits) {
      hash = (hash * 31 + code) & 0x7fffffff;
    }
    return (hash % 180) * math.pi / 180;
  }

  static LatLng _offsetMeters(
    double lat,
    double lng,
    double eastM,
    double northM,
    double rotationRad,
  ) {
    final cosR = math.cos(rotationRad);
    final sinR = math.sin(rotationRad);
    final rotatedEast = eastM * cosR - northM * sinR;
    final rotatedNorth = eastM * sinR + northM * cosR;

    final metersPerDegLat = 111320.0;
    final metersPerDegLng = 111320.0 * math.cos(lat * math.pi / 180).abs().clamp(0.2, 1.0);

    return LatLng(
      lat + rotatedNorth / metersPerDegLat,
      lng + rotatedEast / metersPerDegLng,
    );
  }
}
