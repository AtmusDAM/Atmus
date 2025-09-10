class Forecast {
  final String city;
  final List<ForecastItem> items;

  Forecast({required this.city, required this.items});

  factory Forecast.fromJson(Map<String, dynamic> json) {
    final city = (json['city']?['name'] ?? '').toString();
    final list = (json['list'] is List) ? json['list'] as List : const [];

    final parsed = list.map((e) {
      final m = (e as Map<String, dynamic>);
      final main = (m['main'] is Map) ? m['main'] as Map<String, dynamic> : const {};
      final weatherList = (m['weather'] is List) ? m['weather'] as List : const [];
      final first = weatherList.isNotEmpty ? weatherList.first as Map<String, dynamic> : const {};
      final wind = (m['wind'] is Map) ? m['wind'] as Map<String, dynamic> : const {};
      final rain = (m['rain'] is Map) ? m['rain'] as Map<String, dynamic> : const {};

      double _toD(dynamic v) => (v is num) ? v.toDouble() : 0.0;
      int _toI(dynamic v) => (v is num) ? v.toInt() : 0;

      final iconCode = (first['icon'] ?? '').toString();
      final iconUrl = iconCode.isEmpty ? '' : 'https://openweathermap.org/img/wn/$iconCode@2x.png';

      return ForecastItem(
        dateTimeText: (m['dt_txt'] ?? '').toString(),           // "YYYY-MM-DD HH:mm:ss"
        timestamp: (m['dt'] is num) ? (m['dt'] as num).toInt() : 0,
        tempC: _toD(main['temp']),
        tempMinC: _toD(main['temp_min']),
        tempMaxC: _toD(main['temp_max']),
        feelsLikeC: _toD(main['feels_like']),
        humidity: _toI(main['humidity']),
        pressure: _toI(main['pressure']),
        windMs: _toD(wind['speed']),
        rain3hMm: _toD(rain['3h']), // OpenWeather traz "pop" (0..1) na previsão 3h:
        pop: _toD(m['pop']),
        description: (first['description'] ?? '').toString(),
        iconUrl: iconUrl,
      );
    }).toList();

    return Forecast(city: city, items: parsed);
  }

  List<DailySummary> get dailySummaries {
    final Map<String, List<ForecastItem>> byDay = {};
    for (final it in items) {
      final dayKey = it.dateKey;
      byDay.putIfAbsent(dayKey, () => []).add(it);
    }

    final summaries = <DailySummary>[];
    byDay.forEach((day, list) {
      double min = double.infinity;
      double max = -double.infinity;
      double rain = 0.0;
      double windAvg = 0.0;
      int humAvg = 0;
      String icon = '';
      String desc = '';

      for (final it in list) {
        if (it.tempMinC < min) min = it.tempMinC;
        if (it.tempMaxC > max) max = it.tempMaxC;
        rain += it.rain3hMm;
        windAvg += it.windMs;
        humAvg += it.humidity;
      }
      windAvg = list.isEmpty ? 0 : windAvg / list.length;
      humAvg = list.isEmpty ? 0 : (humAvg / list.length).round();

      final mid = list.firstWhere(
            (e) => e.dateTimeText.endsWith('12:00:00'),
        orElse: () => list.first,
      );
      icon = mid.iconUrl;
      desc = mid.description;

      summaries.add(DailySummary(
        day: day,
        tempMinC: (min.isFinite ? min : 0.0),
        tempMaxC: (max.isFinite ? max : 0.0),
        rainMm: rain,
        windAvgMs: windAvg,
        humidityAvg: humAvg,
        iconUrl: icon,
        description: desc,
      ));
    });

    summaries.sort((a, b) => a.day.compareTo(b.day));
    return summaries;
  }

  DailySummary? todaySummary() {
    if (items.isEmpty) return null;
    final todayKey = items.first.dateKey;
    return dailySummaries.firstWhere(
          (d) => d.day == todayKey,
      orElse: () => dailySummaries.isNotEmpty ? dailySummaries.first : null as DailySummary,
    );
  }
}

class ForecastItem {
  final String dateTimeText;
  final int timestamp;       //

  final double tempC;
  final double tempMinC;
  final double tempMaxC;
  final double feelsLikeC;

  final int humidity;
  final int pressure;   // hPa
  final double windMs;
  final double rain3hMm;
  final double pop;     // probabilidade (0..1)

  final String description;
  final String iconUrl;

  ForecastItem({
    required this.dateTimeText,
    required this.timestamp,
    required this.tempC,
    required this.tempMinC,
    required this.tempMaxC,
    required this.feelsLikeC,
    required this.humidity,
    required this.pressure,
    required this.windMs,
    required this.rain3hMm,
    required this.pop,
    required this.description,
    required this.iconUrl,
  });

  DateTime get dateTime =>
      DateTime.fromMillisecondsSinceEpoch(timestamp * 1000, isUtc: true).toLocal();

  double get temp => tempC;


  String get icon => iconUrl;

  String get dateKey => dateTimeText.isNotEmpty ? dateTimeText.substring(0, 10) : '';
}

class DailySummary {
  final String day;
  final double tempMinC;
  final double tempMaxC;
  final double rainMm;
  final double windAvgMs;
  final int humidityAvg;
  final String iconUrl;
  final String description;

  DailySummary({
    required this.day,
    required this.tempMinC,
    required this.tempMaxC,
    required this.rainMm,
    required this.windAvgMs,
    required this.humidityAvg,
    required this.iconUrl,
    required this.description,
  });
}
