class ForecastItem {
  final DateTime dateTime;
  final double temp;
  final String description;
  final String icon;
  final double pop; // Probability of precipitation

  ForecastItem({
    required this.dateTime,
    required this.temp,
    required this.description,
    required this.icon,
    required this.pop,
  });

  factory ForecastItem.fromJson(Map<String, dynamic> json) {
    final main = json['main'] ?? {};
    final weather = json['weather'] != null && (json['weather'] as List).isNotEmpty
        ? json['weather'][0]
        : {};

    return ForecastItem(
      dateTime: DateTime.parse(json['dt_txt'] ?? ''),
      temp: (main['temp'] as num?)?.toDouble() ?? 0.0,
      description: weather['description'] ?? 'Sem dados',
      icon: weather['icon'] ?? '',
      pop: (json['pop'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class Forecast {
  final List<ForecastItem> items;

  Forecast({required this.items});

  factory Forecast.fromJson(Map<String, dynamic> json) {
    final List<dynamic> list = json['list'] ?? [];
    final items = list.map((item) => ForecastItem.fromJson(item)).toList();
    return Forecast(items: items);
  }
}
