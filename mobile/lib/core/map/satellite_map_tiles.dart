import 'package:flutter/foundation.dart';
import 'package:flutter_map/flutter_map.dart';

import 'mapbox_config.dart';

/// Satellite basemap for farm maps using **Mapbox Satellite** (`satellite-v9`).
class SatelliteMapTiles {
  SatelliteMapTiles._();

  static const userAgent = 'com.farmtec.app';
  static const _stylePath = 'mapbox/satellite-v9';

  static String tileUrlTemplate(String accessToken) =>
      'https://api.mapbox.com/styles/v1/$_stylePath/tiles/256/{z}/{x}/{y}?access_token=$accessToken';

  static List<TileLayer> layers() {
    final token = MapboxConfig.accessToken;
    assert(
      token.isNotEmpty,
      'MAPBOX_ACCESS_TOKEN is not set. Run with '
      '--dart-define=MAPBOX_ACCESS_TOKEN=pk.your_token',
    );

    if (token.isEmpty) {
      if (kDebugMode) {
        debugPrint(
          '[SatelliteMapTiles] MAPBOX_ACCESS_TOKEN missing — satellite tiles will not load.',
        );
      }
      return const [];
    }

    return [
      TileLayer(
        urlTemplate: tileUrlTemplate(token),
        userAgentPackageName: userAgent,
        maxNativeZoom: 22,
        maxZoom: 22,
      ),
    ];
  }
}
