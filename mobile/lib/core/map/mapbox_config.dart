/// Mapbox access token for satellite basemap tiles.
///
/// Override at build time with
/// `--dart-define=MAPBOX_ACCESS_TOKEN=pk.other_token` if needed.
abstract final class MapboxConfig {
  static const String accessToken = String.fromEnvironment(
    'MAPBOX_ACCESS_TOKEN',
    defaultValue: '',
  );

  static bool get isConfigured => accessToken.isNotEmpty;
}