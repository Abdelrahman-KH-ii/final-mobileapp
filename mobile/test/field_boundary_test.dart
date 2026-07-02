import 'package:farmtec/core/map/field_boundary.dart';
import 'package:farmtec/core/map/field_grid.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

void main() {
  test('parseHectares reads ha suffix and plain numbers', () {
    expect(FieldBoundary.parseHectares('42.2 ha'), 42.2);
    expect(FieldBoundary.parseHectares('10'), 10);
    expect(FieldBoundary.parseHectares(''), 5.0);
  });

  test('field boundary ring has four corners and closes', () {
    final boundary = FieldBoundary.fromCenter(
      lat: 30.0,
      lng: 31.0,
      hectares: 10,
      orientationSeed: 'farm_a',
    );

    expect(boundary.ring.length, 5);
    expect(boundary.ring.first.latitude, closeTo(boundary.ring.last.latitude, 1e-9));
    expect(boundary.drawRing.length, 4);
  });

  test('grid splits field into nine cells', () {
    final boundary = FieldBoundary.fromCenter(
      lat: 30.0,
      lng: 31.0,
      hectares: 9,
      orientationSeed: 'farm_b',
    );

    final cells = FieldGrid.cells(boundary);
    expect(cells.length, 9);
    for (final cell in cells) {
      expect(cell.length, 4);
    }
  });

  test('boundary center is near farm coordinates', () {
    const lat = 30.05;
    const lng = 31.12;
    final boundary = FieldBoundary.fromCenter(
      lat: lat,
      lng: lng,
      hectares: 5,
      orientationSeed: 'farm_c',
    );

    expect(boundary.center.latitude, closeTo(lat, 0.01));
    expect(boundary.center.longitude, closeTo(lng, 0.01));
  });
}
