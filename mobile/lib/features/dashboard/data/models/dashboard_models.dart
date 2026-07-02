// Dashboard data models

class WeatherModel {
  final double tempC;
  final String condition;
  final int humidity;
  final int precipitation;
  final double windKph;
  final double soilTempC;
  final String growthStatus;

  const WeatherModel({
    required this.tempC,
    required this.condition,
    required this.humidity,
    required this.precipitation,
    required this.windKph,
    required this.soilTempC,
    required this.growthStatus,
  });
}

class SoilMetricModel {
  final String label;
  final String value;
  final double? progress;

  const SoilMetricModel({
    required this.label,
    required this.value,
    this.progress,
  });
}

class ProcessModel {
  final String label;
  final String status;
  final double progress;

  const ProcessModel({
    required this.label,
    required this.status,
    required this.progress,
  });
}

class AIRecommendationModel {
  final String text;
  const AIRecommendationModel({required this.text});
}
