import 'dart:math' as math;

import 'package:farmtec/core/map/field_boundary.dart';
import 'package:latlong2/latlong.dart';

/// Splits a field polygon into a regular grid of sub-polygons for zonal NDVI.
class FieldGrid {
  FieldGrid._();

  static const defaultRows = 3;
  static const defaultCols = 3;

  /// Grid cell polygons inside [boundary] (open rings, counter-clockwise).
  static List<List<LatLng>> cells(
    FieldBoundary boundary, {
    int rows = defaultRows,
    int cols = defaultCols,
  }) {
    final open = boundary.drawRing;
    if (open.length != 4) {
      return _fallbackGrid(boundary.center, boundary.hectares, rows, cols);
    }

    final center = boundary.center;
    final local = open.map((p) => _toLocalMeters(center, p)).toList();

    var minX = local.first.x;
    var maxX = local.first.x;
    var minY = local.first.y;
    var maxY = local.first.y;
    for (final p in local) {
      minX = math.min(minX, p.x);
      maxX = math.max(maxX, p.x);
      minY = math.min(minY, p.y);
      maxY = math.max(maxY, p.y);
    }

    final stepX = (maxX - minX) / cols;
    final stepY = (maxY - minY) / rows;
    final result = <List<LatLng>>[];

    for (var row = 0; row < rows; row++) {
      for (var col = 0; col < cols; col++) {
        final x0 = minX + col * stepX;
        final x1 = minX + (col + 1) * stepX;
        final y0 = minY + row * stepY;
        final y1 = minY + (row + 1) * stepY;

        final cellLocal = [
          _Point(x0, y0),
          _Point(x1, y0),
          _Point(x1, y1),
          _Point(x0, y1),
        ];

        result.add(
          cellLocal.map((p) => _fromLocalMeters(center, p)).toList(),
        );
      }
    }

    return result;
  }

  static List<List<LatLng>> _fallbackGrid(
    LatLng center,
    double hectares,
    int rows,
    int cols,
  ) {
    final boundary = FieldBoundary.fromCenter(
      lat: center.latitude,
      lng: center.longitude,
      hectares: hectares / (rows * cols),
      orientationSeed: 'cell',
    );
    return List.generate(rows * cols, (_) => boundary.drawRing);
  }

  static _Point _toLocalMeters(LatLng origin, LatLng point) {
    final metersPerDegLat = 111320.0;
    final metersPerDegLng = 111320.0 *
        math.cos(origin.latitude * math.pi / 180).abs().clamp(0.2, 1.0);
    return _Point(
      (point.longitude - origin.longitude) * metersPerDegLng,
      (point.latitude - origin.latitude) * metersPerDegLat,
    );
  }

  static LatLng _fromLocalMeters(LatLng origin, _Point local) {
    final metersPerDegLat = 111320.0;
    final metersPerDegLng = 111320.0 *
        math.cos(origin.latitude * math.pi / 180).abs().clamp(0.2, 1.0);
    return LatLng(
      origin.latitude + local.y / metersPerDegLat,
      origin.longitude + local.x / metersPerDegLng,
    );
  }
}

class _Point {
  const _Point(this.x, this.y);
  final double x;
  final double y;
}
