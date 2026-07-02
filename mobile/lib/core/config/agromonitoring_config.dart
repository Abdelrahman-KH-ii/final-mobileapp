/// Agromonitoring (OpenWeather Agro API) key for Sentinel-2 NDVI.
///
/// Override with `--dart-define=AGROMONITORING_API_KEY=other_key` if needed.
abstract final class AgromonitoringConfig {
  static const String apiKey = String.fromEnvironment(
    'AGROMONITORING_API_KEY',
    defaultValue: 'aa6e63eac0283b8f0eebb3a32b82fe07',
  );
  static bool get isConfigured => apiKey.isNotEmpty;
}
