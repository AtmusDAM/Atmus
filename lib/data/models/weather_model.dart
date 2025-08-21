class Weather {
  final double temp;
  final double tempMin;
  final double tempMax;
  final double feelsLike;
  final int pressure;
  final int humidity;
  final double windSpeed;
  final double rain1h;
  final String description;
  final String icon;

  Weather({
    required this.temp,
    required this.tempMin,
    required this.tempMax,
    required this.feelsLike,
    required this.pressure,
    required this.humidity,
    required this.windSpeed,
    required this.rain1h,
    required this.description,
    required this.icon,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    final main = json['main'] ?? {};
    final wind = json['wind'] ?? {};
    final rain = json['rain'] ?? {};
    final weather = json['weather'] != null && (json['weather'] as List).isNotEmpty
        ? json['weather'][0]
        : {};

    return Weather(
      temp: (main['temp'] as num?)?.toDouble() ?? 0.0,
      tempMin: (main['temp_min'] as num?)?.toDouble() ?? 0.0,
      tempMax: (main['temp_max'] as num?)?.toDouble() ?? 0.0,
      feelsLike: (main['feels_like'] as num?)?.toDouble() ?? 0.0,
      pressure: (main['pressure'] as num?)?.toInt() ?? 0,
      humidity: (main['humidity'] as num?)?.toInt() ?? 0,
      windSpeed: (wind['speed'] as num?)?.toDouble() ?? 0.0,
      rain1h: (rain['1h'] as num?)?.toDouble() ?? 0.0,
      description: weather['description'] ?? 'Sem dados',
      icon: weather['icon'] ?? '',
    );
  }
}
