import 'dart:convert';

class CityModel {
  final String name;
  final bool isFavorite;
  final double? minTemp;
  final double? maxTemp;
  final double? lat;
  final double? lon;
  final String? state;   // OpenWeather usa "state"
  final String? country; // código ISO, ex.: "BR"
  final bool isFromSearch;

  const CityModel({
    required this.name,
    this.isFavorite = false,
    this.minTemp,
    this.maxTemp,
    this.lat,
    this.lon,
    this.state,
    this.country,
    this.isFromSearch = false,
  });

  CityModel copyWith({
    String? name,
    bool? isFavorite,
    double? minTemp,
    double? maxTemp,
    double? lat,
    double? lon,
    String? state,
    String? country,
    bool? isFromSearch,
  }) {
    return CityModel(
      name: name ?? this.name,
      isFavorite: isFavorite ?? this.isFavorite,
      minTemp: minTemp ?? this.minTemp,
      maxTemp: maxTemp ?? this.maxTemp,
      lat: lat ?? this.lat,
      lon: lon ?? this.lon,
      state: state ?? this.state,
      country: country ?? this.country,
      isFromSearch: isFromSearch ?? this.isFromSearch,
    );
  }

  factory CityModel.fromOpenWeatherGeocode(Map<String, dynamic> m) {
    return CityModel(
      name: (m['name'] ?? '') as String,
      state: (m['state'] as String?) ?? '',
      country: (m['country'] as String?) ?? '',
      lat: (m['lat'] as num?)?.toDouble(),
      lon: (m['lon'] as num?)?.toDouble(),
      isFromSearch: true,
    );
  }

  String serialize() {
    final map = {
      'name': name,
      'isFavorite': isFavorite,
      'minTemp': minTemp,
      'maxTemp': maxTemp,
      'lat': lat,
      'lon': lon,
      'state': state,
      'country': country,
    };
    return jsonEncode(map);
  }

  static CityModel deserialize(String s) {
    final m = jsonDecode(s) as Map<String, dynamic>;
    return CityModel(
      name: (m['name'] ?? '') as String,
      isFavorite: (m['isFavorite'] ?? false) as bool,
      minTemp: (m['minTemp'] as num?)?.toDouble(),
      maxTemp: (m['maxTemp'] as num?)?.toDouble(),
      lat: (m['lat'] as num?)?.toDouble(),
      lon: (m['lon'] as num?)?.toDouble(),
      state: m['state'] as String?,
      country: m['country'] as String?,
      isFromSearch: false,
    );
  }

  factory CityModel.fromJson(Map<String, dynamic> json) {
    return CityModel(
      name: (json['name'] ?? '') as String,
      state: (json['state'] as String?) ?? '',
      country: (json['country'] as String?) ?? '',
      lat: (json['lat'] as num?)?.toDouble(),
      lon: (json['lon'] as num?)?.toDouble(),
      isFromSearch: true,
    );
  }
}
