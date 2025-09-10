import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:atmus/secrets.dart' as S;
import 'package:atmus/secrets_openweather.dart' as OW;

import 'package:atmus/data/models/openweather_history.dart';

class OpenWeatherAuthError implements Exception {
  final String message;
  OpenWeatherAuthError(this.message);
  @override
  String toString() => 'OpenWeatherAuthError: $message';
}

class OpenWeatherClientError implements Exception {
  final int status;
  final String body;
  OpenWeatherClientError(this.status, this.body);
  @override
  String toString() => 'OpenWeatherClientError($status): $body';
}

class OpenWeatherService {
  final http.Client _client;
  final String _host = 'api.openweathermap.org';
  final bool preferV3;

  OpenWeatherService({http.Client? client, bool? preferOneCall3})
      : _client = client ?? http.Client(),
        preferV3 = preferOneCall3 ?? OW.openWeatherPreferV3;

  String get _apiKey {
    final k = S.Secrets.weatherApiKey;
    if (k.isNotEmpty) return k;
    return OW.openWeatherApiKey;
  }

  Uri _v3(String path, Map<String, String> q) => Uri.https(_host, '/data/3.0/$path', q);
  Uri _v25(String path, Map<String, String> q) => Uri.https(_host, '/data/2.5/$path', q);
  Uri _geo(String path, Map<String, String> q) => Uri.https(_host, '/geo/1.0/$path', q);

  Future<Map<String, dynamic>> getCurrentByLatLon(
      double lat,
      double lon, {
        String units = 'metric',
        String lang = 'pt_br',
      }) async {
    if (_apiKey.isEmpty) throw Exception('OpenWeather API key ausente.');
    final uri = _v25('weather', {
      'lat': '$lat',
      'lon': '$lon',
      'units': units,
      'lang': lang,
      'appid': _apiKey,
    });
    final res = await _client.get(uri);
    if (res.statusCode == 401 || res.statusCode == 403) {
      throw OpenWeatherAuthError(_extractMessage(res.body) ?? 'Invalid API key or permissions.');
    }
    if (res.statusCode != 200) {
      throw OpenWeatherClientError(res.statusCode, res.body);
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> searchCities(String query, {int limit = 10}) async {
    if (_apiKey.isEmpty) throw Exception('OpenWeather API key ausente.');
    final uri = _geo('direct', {'q': query, 'limit': '$limit', 'appid': _apiKey});
    final res = await _client.get(uri);
    if (res.statusCode != 200) {
      throw OpenWeatherClientError(res.statusCode, res.body);
    }
    final list = jsonDecode(res.body) as List<dynamic>;
    return list.cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> reverseGeocode(double lat, double lon, {int limit = 1}) async {
    if (_apiKey.isEmpty) throw Exception('OpenWeather API key ausente.');
    final uri = _geo('reverse', {'lat': '$lat', 'lon': '$lon', 'limit': '$limit', 'appid': _apiKey});
    final res = await _client.get(uri);
    if (res.statusCode != 200) {
      throw OpenWeatherClientError(res.statusCode, res.body);
    }
    final list = jsonDecode(res.body) as List<dynamic>;
    return list.cast<Map<String, dynamic>>();
  }

  // ---------------- Histórico: 1 dia ----------------

  Future<OwDayHistory> getOneDayHistory({
    required double lat,
    required double lon,
    required DateTime dayUtc,
    String lang = 'pt_br',
  }) async {
    if (preferV3) {
      try {
        // v3: multi-amostragem (ex.: a cada 3h) + agregação
        return await _getOneDayHistoryV3MultiSample(
          lat: lat,
          lon: lon,
          dayUtc: dayUtc,
          lang: lang,
          strideHours: 3, // ajuste para 6 se quiser reduzir chamadas
        );
      } on OpenWeatherAuthError {
        // fallback para 2.5 (se disponível na sua conta)
        return await _getOneDayHistoryV25(
          lat: lat,
          lon: lon,
          dt: _noonEpoch(dayUtc),
          lang: lang,
          dayUtc: dayUtc,
        );
      }
    } else {
      return await _getOneDayHistoryV25(
        lat: lat,
        lon: lon,
        dt: _noonEpoch(dayUtc),
        lang: lang,
        dayUtc: dayUtc,
      );
    }
  }

  int _noonEpoch(DateTime dayUtc) =>
      (DateTime.utc(dayUtc.year, dayUtc.month, dayUtc.day, 12).millisecondsSinceEpoch / 1000).round();

  // v3 com multi-amostragem
  Future<OwDayHistory> _getOneDayHistoryV3MultiSample({
    required double lat,
    required double lon,
    required DateTime dayUtc,
    required String lang,
    int strideHours = 3,
  }) async {
    final hours = <OwHourly>[];
    final seen = <int>{};
    final base = DateTime.utc(dayUtc.year, dayUtc.month, dayUtc.day);

    final samples = <int>[];
    for (int h = 0; h < 24; h += strideHours) {
      samples.add(h);
    }

    for (final h in samples) {
      final ts = base.add(Duration(hours: h)).millisecondsSinceEpoch ~/ 1000;
      final uri = _v3('onecall/timemachine', {
        'lat': lat.toStringAsFixed(6),
        'lon': lon.toStringAsFixed(6),
        'dt': ts.toString(),
        'appid': _apiKey,
        'units': 'metric',
        'lang': lang,
      });

      http.Response resp;
      try {
        resp = await _client.get(uri);
      } catch (_) {
        continue;
      }

      try {
        final parsed = await _fromResponse(
          resp,
          dayUtc,
          authHint: 'Ative "One Call by Call (3.0)" para esta chave.',
        );
        for (final h1 in parsed.hours) {
          if (seen.add(h1.dt)) hours.add(h1);
        }
      } on OpenWeatherAuthError {
        rethrow; // deixa o caller cair no fallback 2.5
      } catch (_) {
        // ignora falhas pontuais de alguma hora
      }
    }

    hours.sort((a, b) => a.dt.compareTo(b.dt));
    return OwDayHistory(dayUtc: DateTime.utc(dayUtc.year, dayUtc.month, dayUtc.day), hours: hours);
  }

  // v2.5: em muitas contas retorna o array "hourly" do dia inteiro de uma vez
  Future<OwDayHistory> _getOneDayHistoryV25({
    required double lat,
    required double lon,
    required int dt,
    required String lang,
    required DateTime dayUtc,
  }) async {
    final uri = _v25('onecall/timemachine', {
      'lat': lat.toStringAsFixed(6),
      'lon': lon.toStringAsFixed(6),
      'dt': dt.toString(),
      'appid': _apiKey,
      'units': 'metric',
      'lang': lang,
    });
    final resp = await _client.get(uri);
    return _fromResponse(resp, dayUtc, authHint: 'Habilite o histórico (One Call 2.5) para esta chave.');
  }

  // ---------------- Histórico: 5 dias ----------------

  Future<List<OwDayHistory>> getPast5DaysHistory({
    required double lat,
    required double lon,
    String lang = 'pt_br',
    DateTime? nowUtc,
  }) async {
    final now = nowUtc ?? DateTime.now().toUtc();
    final days = List.generate(5, (i) {
      final d = now.subtract(Duration(days: i + 1));
      return DateTime.utc(d.year, d.month, d.day);
    });

    final out = <OwDayHistory>[];
    for (final d in days) {
      out.add(await getOneDayHistory(lat: lat, lon: lon, dayUtc: d, lang: lang));
    }
    return out;
  }

  // ---------------- Parsing comum ----------------

  List<Map<String, dynamic>> _extractHourly(Map<String, dynamic> jsonMap) {
    final vHourly = jsonMap['hourly'];
    if (vHourly is List) return vHourly.cast<Map<String, dynamic>>();
    final vData = jsonMap['data'];
    if (vData is List) return vData.cast<Map<String, dynamic>>();
    return const [];
  }

  Future<OwDayHistory> _fromResponse(
      http.Response resp,
      DateTime dayUtc, {
        String? authHint,
      }) async {
    if (resp.statusCode == 401 || resp.statusCode == 403) {
      throw OpenWeatherAuthError(_extractMessage(resp.body) ?? (authHint ?? 'Unauthorized.'));
    }
    if (resp.statusCode != 200) {
      throw OpenWeatherClientError(resp.statusCode, resp.body);
    }

    final Map<String, dynamic> data = json.decode(resp.body);
    final raw = _extractHourly(data);
    final hours = raw.map((e) => OwHourly.fromJson(e)).toList();

    return OwDayHistory(
      dayUtc: DateTime.utc(dayUtc.year, dayUtc.month, dayUtc.day),
      hours: hours,
    );
  }

  // ---------------- Util ----------------

  Future<({double? tmin, double? tmax})> getMinMaxNext24h(
      double lat,
      double lon, {
        String units = 'metric',
        String lang = 'pt_br',
      }) async {
    if (_apiKey.isEmpty) throw Exception('OpenWeather API key ausente.');
    final uri = _v25('forecast', {
      'lat': '$lat',
      'lon': '$lon',
      'units': units,
      'lang': lang,
      'appid': _apiKey,
    });
    final res = await _client.get(uri);
    if (res.statusCode != 200) {
      throw OpenWeatherClientError(res.statusCode, res.body);
    }
    final jsonMap = jsonDecode(res.body) as Map<String, dynamic>;
    final list = (jsonMap['list'] as List?)?.cast<Map<String, dynamic>>() ?? const [];
    if (list.isEmpty) return (tmin: null, tmax: null);

    final first8 = list.take(8); // ~24h
    double? minT;
    double? maxT;
    for (final item in first8) {
      final main = (item['main'] as Map?) ?? {};
      final double? t =
          (main['temp_min'] as num?)?.toDouble() ?? (main['temp'] as num?)?.toDouble();
      final double? tmaxItem =
          (main['temp_max'] as num?)?.toDouble() ?? (main['temp'] as num?)?.toDouble();
      if (t != null) minT = (minT == null) ? t : (t < minT ? t : minT);
      if (tmaxItem != null) maxT = (maxT == null) ? tmaxItem : (tmaxItem > maxT ? tmaxItem : maxT);
    }
    return (tmin: minT, tmax: maxT);
  }

  String? _extractMessage(String body) {
    try {
      final m = json.decode(body);
      if (m is Map && m['message'] != null) return m['message'].toString();
    } catch (_) {}
    return null;
  }
}
