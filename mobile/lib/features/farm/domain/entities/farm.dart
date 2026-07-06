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
      };
}
