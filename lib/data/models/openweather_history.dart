import 'dart:convert';

double? _asDouble(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v);
  return null;
}

int _asInt(dynamic v) {
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v) ?? 0;
  return 0;
}

double? _extractPointTemp(Map<String, dynamic> j) {
  final main = (j['main'] as Map?)?.cast<String, dynamic>();
  final t1 = _asDouble(j['temp']);
  if (t1 != null) return t1;
  if (main != null) {
    final tMain = _asDouble(main['temp']);
    if (tMain != null) return tMain;
  }
  final tField = j['temperature'];
  if (tField is Map) {
    return _asDouble(tField['value']) ??
        _asDouble(tField['avg']) ??
        _asDouble(tField['mean']) ??
        _asDouble(tField['min']) ??
        _asDouble(tField['max']);
  }
  return _asDouble(tField);
}

({double? tmin, double? tmax}) _extractMinMax(Map<String, dynamic> j) {
  double? tmin;
  double? tmax;

  final main = (j['main'] as Map?)?.cast<String, dynamic>();
  if (main != null) {
    tmin = _asDouble(main['temp_min']) ?? tmin;
    tmax = _asDouble(main['temp_max']) ?? tmax;
  }

  final tField = j['temperature'];
  if (tField is Map) {
    tmin = _asDouble(tField['min']) ?? tmin;
    tmax = _asDouble(tField['max']) ?? tmax;
  }

  return (tmin: tmin, tmax: tmax);
}

class OwHourly {
  final int dt;
  final double? temp;
  final double? tempMin;
  final double? tempMax;
  final double? feelsLike;
  final int? humidity;
  final int? clouds;
  final double? windSpeed;
  final String? weatherMain;
  final String? weatherDesc;

  DateTime get dateTime => DateTime.fromMillisecondsSinceEpoch(dt * 1000, isUtc: true);

  OwHourly({
    required this.dt,
    required this.temp,
    required this.tempMin,
    required this.tempMax,
    required this.feelsLike,
    required this.humidity,
    required this.clouds,
    required this.windSpeed,
    required this.weatherMain,
    required this.weatherDesc,
  });

  factory OwHourly.fromJson(Map<String, dynamic> j) {
    final wList = (j['weather'] as List?) ?? const [];
    final w = wList.isNotEmpty ? (wList.first as Map<String, dynamic>) : const <String, dynamic>{};
    final main = (j['main'] as Map?)?.cast<String, dynamic>() ?? const <String, dynamic>{};

    final dt = _asInt(j['dt'] ?? j['time'] ?? j['ts'] ?? j['timestamp']);
    final point = _extractPointTemp(j);
    final mnmx = _extractMinMax(j);

    final feelsLike = _asDouble(j['feels_like']) ?? _asDouble(main['feels_like']) ?? point;
    final humidity = (j['humidity'] as num?)?.toInt() ?? (main['humidity'] as num?)?.toInt();
    final clouds = (j['clouds'] as num?)?.toInt();
    final windSpeed = _asDouble(j['wind_speed']) ?? _asDouble(j['wind']) ?? _asDouble(j['windSpeed']);
    final weatherMain = (w['main'] ?? j['weather_main'])?.toString();
    final weatherDesc = (w['description'] ?? j['weather_desc'])?.toString();

    return OwHourly(
      dt: dt,
      temp: point,
      tempMin: mnmx.tmin,
      tempMax: mnmx.tmax,
      feelsLike: feelsLike,
      humidity: humidity,
      clouds: clouds,
      windSpeed: windSpeed,
      weatherMain: weatherMain,
      weatherDesc: weatherDesc,
    );
  }
}

class OwDayHistory {
  final DateTime dayUtc;
  final List<OwHourly> hours;

  OwDayHistory({required this.dayUtc, required this.hours});

  double? get minTemp {
    final vals = hours.map((h) => h.tempMin ?? h.temp).whereType<double>().toList();
    if (vals.isEmpty) return null;
    var m = vals.first;
    for (final t in vals.skip(1)) {
      if (t < m) m = t;
    }
    return m;
  }

  double? get maxTemp {
    final vals = hours.map((h) => h.tempMax ?? h.temp).whereType<double>().toList();
    if (vals.isEmpty) return null;
    var m = vals.first;
    for (final t in vals.skip(1)) {
      if (t > m) m = t;
    }
    return m;
  }

  double? get avgTemp {
    final vals = hours.map((h) => h.temp).whereType<double>().toList();
    if (vals.isEmpty) return null;
    var sum = 0.0;
    for (final t in vals) {
      sum += t;
    }
    return sum / vals.length;
  }

  OwHourly? get minAt {
    OwHourly? best;
    for (final h in hours) {
      final t = h.tempMin ?? h.temp;
      if (t == null) continue;
      if (best == null || t < ((best.tempMin ?? best.temp) ?? t + 1)) best = h;
    }
    return best;
  }

  OwHourly? get maxAt {
    OwHourly? best;
    for (final h in hours) {
      final t = h.tempMax ?? h.temp;
      if (t == null) continue;
      if (best == null || t > ((best.tempMax ?? best.temp) ?? t - 1)) best = h;
    }
    return best;
  }

  Map<String, dynamic> toJson() => {
    'dayUtc': dayUtc.toIso8601String(),
    'hours': hours
        .map((h) => {
      'dt': h.dt,
      'temp': h.temp,
      'temp_min': h.tempMin,
      'temp_max': h.tempMax,
      'feels_like': h.feelsLike,
      'humidity': h.humidity,
      'clouds': h.clouds,
      'wind_speed': h.windSpeed,
      'weather_main': h.weatherMain,
      'weather_desc': h.weatherDesc,
    })
        .toList(),
  };

  String toPrettyJson() => const JsonEncoder.withIndent('  ').convert(toJson());
}
