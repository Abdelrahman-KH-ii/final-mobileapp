import 'package:farmtec/core/services/agromonitoring_client.dart';
import 'package:farmtec/core/services/ndvi_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

class _FakeAgroClient extends AgromonitoringClient {
  _FakeAgroClient(this._ndviByKey);

  final Map<String, double> _ndviByKey;
  int callCount = 0;

  @override
  bool get isConfigured => true;

  @override
  Future<String> ensurePolygon({
    required String cacheKey,
    required String name,
    required List<LatLng> ring,
  }) async {
    callCount++;
    return cacheKey;
  }

  @override
  Future<double> fetchLatestNdviMean(String polyId) async {
    return _ndviByKey[polyId] ?? 0.55;
  }
}

void main() {
  test('NdviService returns zones with polygons and valid NDVI', () async {
    final service = NdviService(client: _FakeAgroClient({}));

    final result = await service.analyze(
      farmId: 'farm_1',
      lat: 30.0444,
      lng: 31.2357,
      area: '9 ha',
    );

    expect(result.zones.length, 9);
    expect(result.fieldBoundary.length, 4);
    expect(result.averageNdvi, inInclusiveRange(0.0, 1.0));
    for (final zone in result.zones) {
      expect(zone.polygon.length, 4);
      expect(zone.ndvi, inInclusiveRange(-0.2, 1.0));
    }
  });

  test('NdviService average reflects zone values', () async {
    final client = _FakeAgroClient({'z0': 0.4, 'z1': 0.8});
    final service = NdviService(client: client);

    final result = await service.analyze(
      farmId: 'farm_2',
      lat: 30.0,
      lng: 31.0,
      area: '9 ha',
    );

    expect(result.averageNdvi, closeTo(0.55, 0.01));
  });

  test('color bands cover healthy and stressed values', () {
    expect(NdviService.colorBandIndex(0.7), 3);
    expect(NdviService.colorBandIndex(0.3), 0);
  });
}
