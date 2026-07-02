class Farm {
  final String id;
  final String name;
  final String crop;
  final String area;
  final String health;
  final String lastScan;
  final double lat;
  final double lng;
  final DateTime? plantedAt;
  final String soilType;
  final String climateZone;

  // Environment and Soil attributes from backend
  final double? nitrogen;
  final double? phosphorus;
  final double? potassium;
  final double? ph;
  final double? temperature;
  final double? humidity;
  final double? soilMoisture;

  const Farm({
    required this.id,
    required this.name,
    required this.crop,
    required this.area,
    required this.health,
    required this.lastScan,
    this.lat = 0,
    this.lng = 0,
    this.plantedAt,
    this.soilType = '',
    this.climateZone = '',
    this.nitrogen,
    this.phosphorus,
    this.potassium,
    this.ph,
    this.temperature,
    this.humidity,
    this.soilMoisture,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'crop': crop,
        'area': area,
        'health': health,
        'lastScan': lastScan,
        'lat': lat,
        'lng': lng,
        'soilType': soilType,
        'climateZone': climateZone,
        if (plantedAt != null) 'plantedAt': plantedAt!.toIso8601String(),
        if (nitrogen != null) 'nitrogen': nitrogen,
        if (phosphorus != null) 'phosphorus': phosphorus,
        if (potassium != null) 'potassium': potassium,
        if (ph != null) 'ph': ph,
        if (temperature != null) 'temperature': temperature,
        if (humidity != null) 'humidity': humidity,
        if (soilMoisture != null) 'soilMoisture': soilMoisture,
      };

  factory Farm.fromJson(Map<String, dynamic> json) => Farm.fromApiJson(json);

  factory Farm.fromApiJson(Map<String, dynamic> json) => Farm(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        crop: json['crop']?.toString() ?? 'Wheat',
        area: json['area']?.toString() ?? '0 ha',
        health: json['health']?.toString() ?? 'healthy',
        lastScan: (json['lastScan'] ?? json['last_scan'] ?? '').toString(),
        lat: _toDouble(json['lat'] ?? json['latitude']),
        lng: _toDouble(json['lng'] ?? json['longitude']),
        soilType: json['soil_type']?.toString() ?? json['soilType']?.toString() ?? '',
        climateZone: json['climate_zone']?.toString() ?? json['climateZone']?.toString() ?? '',
        plantedAt: _parseDate(json['plantedAt'] ?? json['planted_at']),
        nitrogen: _toDoubleOrNull(json['nitrogen']),
        phosphorus: _toDoubleOrNull(json['phosphorus']),
        potassium: _toDoubleOrNull(json['potassium']),
        ph: _toDoubleOrNull(json['ph']),
        temperature: _toDoubleOrNull(json['temperature']),
        humidity: _toDoubleOrNull(json['humidity']),
        soilMoisture: _toDoubleOrNull(json['soil_moisture'] ?? json['soilMoisture']),
      );

  Map<String, dynamic> toApiPayload() => {
        'name': name,
        'crop': crop,
        'area': area,
        'health': health,
        'lastScan': lastScan,
        'lat': lat,
        'lng': lng,
        'soil_type': soilType,
        'climate_zone': climateZone,
        if (plantedAt != null) 'plantedAt': plantedAt!.toIso8601String(),
        if (nitrogen != null) 'nitrogen': nitrogen,
        if (phosphorus != null) 'phosphorus': phosphorus,
        if (potassium != null) 'potassium': potassium,
        if (ph != null) 'ph': ph,
        if (temperature != null) 'temperature': temperature,
        if (humidity != null) 'humidity': humidity,
        if (soilMoisture != null) 'soil_moisture': soilMoisture,
        'location': name,
      };

  static double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }

  static double? _toDoubleOrNull(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null || value.toString().isEmpty) return null;
    return DateTime.tryParse(value.toString());
  }
}
