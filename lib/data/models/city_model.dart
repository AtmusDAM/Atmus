class CityModel {
  final String name;
  final int minTemp;
  final int maxTemp;
  final double? lat;
  final double? lon;

  CityModel({
    required this.name,
    required this.minTemp,
    required this.maxTemp,
    this.lat,
    this.lon,
  });

  CityModel copyWith({
    String? name,
    int? minTemp,
    int? maxTemp,
    double? lat,
    double? lon,
  }) {
    return CityModel(
      name: name ?? this.name,
      minTemp: minTemp ?? this.minTemp,
      maxTemp: maxTemp ?? this.maxTemp,
      lat: lat ?? this.lat,
      lon: lon ?? this.lon,
    );
  }

  factory CityModel.fromJson(Map<String, dynamic> json) {
    return CityModel(
      name: json['name'] as String,
      minTemp: json['minTemp'] as int,
      maxTemp: json['maxTemp'] as int,
      lat: (json['lat'] as num?)?.toDouble(),
      lon: (json['lon'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'minTemp': minTemp,
    'maxTemp': maxTemp,
    if (lat != null) 'lat': lat,
    if (lon != null) 'lon': lon,
  };
}
