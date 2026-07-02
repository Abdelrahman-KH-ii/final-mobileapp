import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherData {
  final double temperature;
  final int humidity;
  final double precipitation;
  final double windSpeed;
  final int weatherCode;
  final String description;
  final List<DailyForecast> forecast;

  const WeatherData({
    required this.temperature,
    required this.humidity,
    required this.precipitation,
    required this.windSpeed,
    required this.weatherCode,
    required this.description,
    required this.forecast,
  });
}

class DailyForecast {
  final DateTime date;
  final double maxTemp;
  final double minTemp;
  final int weatherCode;
  final String description;

  const DailyForecast({
    required this.date,
    required this.maxTemp,
    required this.minTemp,
    required this.weatherCode,
    required this.description,
  });
}

class WeatherService {
  static const _baseUrl = 'https://api.open-meteo.com/v1/forecast';

  // WMO Weather Code → description + icon
  static const _weatherCodes = <int, List<String>>{
    0: ['Clear Sky', '☀️'],
    1: ['Mainly Clear', '🌤️'],
    2: ['Partly Cloudy', '⛅'],
    3: ['Overcast', '☁️'],
    45: ['Fog', '🌫️'],
    48: ['Rime Fog', '🌫️'],
    51: ['Light Drizzle', '🌦️'],
    53: ['Moderate Drizzle', '🌦️'],
    55: ['Dense Drizzle', '🌧️'],
    61: ['Slight Rain', '🌦️'],
    63: ['Moderate Rain', '🌧️'],
    65: ['Heavy Rain', '🌧️'],
    71: ['Slight Snow', '🌨️'],
    73: ['Moderate Snow', '🌨️'],
    75: ['Heavy Snow', '❄️'],
    80: ['Slight Showers', '🌦️'],
    81: ['Moderate Showers', '🌧️'],
    82: ['Violent Showers', '⛈️'],
    95: ['Thunderstorm', '⛈️'],
    96: ['Thunderstorm + Hail', '⛈️'],
    99: ['Thunderstorm + Heavy Hail', '⛈️'],
  };

  static String getDescription(int code) =>
      _weatherCodes[code]?[0] ?? 'Unknown';

  static String getEmoji(int code) =>
      _weatherCodes[code]?[1] ?? '🌡️';

  static String getDescriptionAr(int code) {
    const arCodes = <int, String>{
      0: 'صافٍ',
      1: 'صافٍ غالباً',
      2: 'غائم جزئياً',
      3: 'غائم بالكامل',
      45: 'ضبابي',
      48: 'ضباب متجمد',
      51: 'رذاذ خفيف',
      53: 'رذاذ معتدل',
      55: 'رذاذ كثيف',
      61: 'مطر خفيف',
      63: 'مطر معتدل',
      65: 'مطر غزير',
      71: 'ثلوج خفيفة',
      73: 'ثلوج معتدلة',
      75: 'ثلوج كثيفة',
      80: 'زخات خفيفة',
      81: 'زخات معتدلة',
      82: 'زخات عنيفة',
      95: 'عاصفة رعدية',
      96: 'عاصفة رعدية مع بَرَد',
      99: 'عاصفة رعدية شديدة',
    };
    return arCodes[code] ?? 'غير معروف';
  }

  static Future<WeatherData?> fetchWeather(double lat, double lng) async {
    try {
      final uri = Uri.parse('$_baseUrl?'
          'latitude=$lat'
          '&longitude=$lng'
          '&current=temperature_2m,relative_humidity_2m,precipitation,wind_speed_10m,weather_code'
          '&daily=temperature_2m_max,temperature_2m_min,weather_code'
          '&timezone=auto'
          '&forecast_days=5');

      final response = await http.get(uri).timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body);
      final current = data['current'];
      final daily = data['daily'];

      final List<DailyForecast> forecasts = [];
      final dates = daily['time'] as List;
      final maxTemps = daily['temperature_2m_max'] as List;
      final minTemps = daily['temperature_2m_min'] as List;
      final codes = daily['weather_code'] as List;

      for (int i = 0; i < dates.length; i++) {
        final code = (codes[i] as num).toInt();
        forecasts.add(DailyForecast(
          date: DateTime.parse(dates[i]),
          maxTemp: (maxTemps[i] as num).toDouble(),
          minTemp: (minTemps[i] as num).toDouble(),
          weatherCode: code,
          description: getDescription(code),
        ));
      }

      final weatherCode = (current['weather_code'] as num).toInt();

      return WeatherData(
        temperature: (current['temperature_2m'] as num).toDouble(),
        humidity: (current['relative_humidity_2m'] as num).toInt(),
        precipitation: (current['precipitation'] as num).toDouble(),
        windSpeed: (current['wind_speed_10m'] as num).toDouble(),
        weatherCode: weatherCode,
        description: getDescription(weatherCode),
        forecast: forecasts,
      );
    } catch (e) {
      return null;
    }
  }
}
