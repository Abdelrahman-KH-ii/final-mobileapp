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

  // Additional metadata
  final String location;
  final String soilType;
  final String climateZone;

  // Soil/satellite properties from data_pipeline script
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
    this.location = '',
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

  /// Serialize to JSON for local storage (SharedPreferences).
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'crop': crop,
        'area': area,
        'health': health,
        'lastScan': lastScan,
        'lat': lat,
        'lng': lng,
        if (plantedAt != null) 'plantedAt': plantedAt!.toIso8601String(),
        'location': location,
        'soilType': soilType,
        'climateZone': climateZone,
        if (nitrogen != null) 'nitrogen': nitrogen,
        if (phosphorus != null) 'phosphorus': phosphorus,
        if (potassium != null) 'potassium': potassium,
        if (ph != null) 'ph': ph,
        if (temperature != null) 'temperature': temperature,
        if (humidity != null) 'humidity': humidity,
        if (soilMoisture != null) 'soilMoisture': soilMoisture,
      };

  /// Deserialize from local storage JSON (id is always a String here).
  factory Farm.fromJson(Map<String, dynamic> json) => Farm(
        id: json['id']?.toString() ?? '',
        name: json['name'] ?? '',
        crop: json['crop'] ?? '',
        area: json['area'] ?? '',
        health: json['health'] ?? 'healthy',
        lastScan: json['lastScan'] ?? '',
        lat: (json['lat'] ?? 0).toDouble(),
        lng: (json['lng'] ?? 0).toDouble(),
        plantedAt: json['plantedAt'] != null && json['plantedAt'].toString().isNotEmpty
            ? DateTime.tryParse(json['plantedAt'].toString())
            : null,
        location: json['location']?.toString() ?? '',
        soilType: json['soilType']?.toString() ?? '',
        climateZone: json['climateZone']?.toString() ?? '',
        nitrogen: json['nitrogen'] != null ? (json['nitrogen'] as num).toDouble() : null,
        phosphorus: json['phosphorus'] != null ? (json['phosphorus'] as num).toDouble() : null,
        potassium: json['potassium'] != null ? (json['potassium'] as num).toDouble() : null,
        ph: json['ph'] != null ? (json['ph'] as num).toDouble() : null,
        temperature: json['temperature'] != null ? (json['temperature'] as num).toDouble() : null,
        humidity: json['humidity'] != null ? (json['humidity'] as num).toDouble() : null,
        soilMoisture: json['soilMoisture'] != null ? (json['soilMoisture'] as num).toDouble() : null,
      );

  /// Deserialize from the Django mobile API response.
  /// The backend returns id as an integer; MobileFarmSerializer aliases
  /// latitude→lat, longitude→lng, last_scan→lastScan, planted_at→plantedAt.
  factory Farm.fromApiJson(Map<String, dynamic> json) => Farm(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        crop: json['crop']?.toString() ?? '',
        area: json['area']?.toString() ?? '0 ha',
        health: json['health']?.toString() ?? 'healthy',
        lastScan: json['lastScan']?.toString() ?? '',
        lat: double.tryParse(json['lat']?.toString() ?? '0') ?? 0.0,
        lng: double.tryParse(json['lng']?.toString() ?? '0') ?? 0.0,
        plantedAt: json['plantedAt'] != null && json['plantedAt'].toString().isNotEmpty
            ? DateTime.tryParse(json['plantedAt'].toString())
            : null,
        location: json['location']?.toString() ?? '',
        soilType: json['soil_type']?.toString() ?? '',
        climateZone: json['climate_zone']?.toString() ?? '',
        nitrogen: json['nitrogen'] != null ? double.tryParse(json['nitrogen'].toString()) : null,
        phosphorus: json['phosphorus'] != null ? double.tryParse(json['phosphorus'].toString()) : null,
        potassium: json['potassium'] != null ? double.tryParse(json['potassium'].toString()) : null,
        ph: json['ph'] != null ? double.tryParse(json['ph'].toString()) : null,
        temperature: json['temperature'] != null ? double.tryParse(json['temperature'].toString()) : null,
        humidity: json['humidity'] != null ? double.tryParse(json['humidity'].toString()) : null,
        soilMoisture: json['soil_moisture'] != null ? double.tryParse(json['soil_moisture'].toString()) : null,
      );

  /// Build the payload sent to the Django API when creating/updating a farm.
  Map<String, dynamic> toApiJson() => {
        'name': name,
        'crop': crop,
        'area': area,
        'health': health,
        'lastScan': lastScan,
        'lat': lat,
        'lng': lng,
        if (plantedAt != null) 'plantedAt': plantedAt!.toIso8601String(),
        'location': location,
        'soil_type': soilType,
        'climate_zone': climateZone,
        if (nitrogen != null) 'nitrogen': nitrogen,
        if (phosphorus != null) 'phosphorus': phosphorus,
        if (potassium != null) 'potassium': potassium,
        if (ph != null) 'ph': ph,
        if (temperature != null) 'temperature': temperature,
        if (humidity != null) 'humidity': humidity,
        if (soilMoisture != null) 'soil_moisture': soilMoisture,
      };
}
