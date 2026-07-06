/// Mapbox access token for satellite basemap tiles.
///
/// Override at build time with
/// `--dart-define=MAPBOX_ACCESS_TOKEN=pk.other_token` if needed.
abstract final class MapboxConfig {
  static const String accessToken = String.fromEnvironment(
    'MAPBOX_ACCESS_TOKEN',
    defaultValue:
        'pk.eyJ1IjoiaGV5ZHVkZTE4MCIsImEiOiJjbXA5Y3Q4cHAwaDFlMnByMDAxOHFzcDdhIn0.10adT5SI3YqlCZsQ22FQTw',
  );

  static bool get isConfigured => accessToken.isNotEmpty;
}