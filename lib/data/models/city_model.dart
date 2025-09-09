class CityModel {
  final String name;
  final int? minTemp;
  final int? maxTemp;
  final double? lat;
  final double? lon;
  final String? country;
  final String? state;

  CityModel({
    required this.name,
    this.minTemp,
    this.maxTemp,
    this.lat,
    this.lon,
    this.country,
    this.state,
  });

  CityModel copyWith({
    String? name,
    int? minTemp,
    int? maxTemp,
    double? lat,
    double? lon,
    String? country,
    String? state,
  }) {
    return CityModel(
      name: name ?? this.name,
      minTemp: minTemp ?? this.minTemp,
      maxTemp: maxTemp ?? this.maxTemp,
      lat: lat ?? this.lat,
      lon: lon ?? this.lon,
      country: country ?? this.country,
      state: state ?? this.state,
    );
  }

  factory CityModel.fromJson(Map<String, dynamic> json) {
    return CityModel(
      name: json['name'] as String,
      minTemp: json['minTemp'] as int?,
      maxTemp: json['maxTemp'] as int?,
      lat: (json['lat'] as num?)?.toDouble(),
      lon: (json['lon'] as num?)?.toDouble(),
      country: json['country'] as String?,
      state: json['state'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'minTemp': minTemp,
    'maxTemp': maxTemp,
    if (lat != null) 'lat': lat,
    if (lon != null) 'lon': lon,
    if (country != null) 'country': country,
    if (state != null) 'state': state,
  };
}
