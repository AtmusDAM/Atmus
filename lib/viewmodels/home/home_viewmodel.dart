import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:latlong2/latlong.dart';

import 'package:atmus/data/services/openweather_service.dart';
import 'package:atmus/data/models/city_model.dart';

class HomeViewModel extends GetxController {
  final OpenWeatherService _ow = OpenWeatherService();

  final RxBool loading = false.obs;
  final Rxn<Map<String, dynamic>> weatherJson = Rxn();
  final RxString lastQuery = ''.obs;
  final RxString cityName = ''.obs;
  final RxInt selectedIndex = 0.obs;
  final RxString _unidadeTemp = 'C'.obs;

  final RxString unidade = 'Celsius'.obs;
  String get unidadeSimbolo => _unidadeTemp.value == 'F' ? '°F' : '°C';

  double displayTemp(double tempC) =>
      _unidadeTemp.value == 'F' ? (tempC * 9 / 5 + 32) : tempC;

  void setUnidadeTemp(String u) {
    if (u == 'F' || u == 'C') {
      _unidadeTemp.value = u;
      unidade.value = (u == 'F') ? 'Fahrenheit' : 'Celsius';
      _persistUnidade();
    }
  }

  void setUnidadeLabel(String label) {
    if (label == 'Fahrenheit' || label == 'Celsius') {
      unidade.value = label;
      _unidadeTemp.value = (label == 'Fahrenheit') ? 'F' : 'C';
      _persistUnidade();
    }
  }

  final Rxn<CityModel> _gpsCity = Rxn<CityModel>();
  CityModel? get gpsCity => _gpsCity.value;

  final Rxn<LatLng> _gpsCoord = Rxn<LatLng>();
  Rxn<LatLng> get gpsCoord => _gpsCoord;

  final Rxn<LatLng> currentCoord = Rxn<LatLng>();

  void setCoord(double lat, double lon, {bool fromGps = false}) {
    final ll = LatLng(lat, lon);
    currentCoord.value = ll;
    if (fromGps) {
      _gpsCoord.value = ll;
    }
  }

  final RxDouble temperaturaAtual = 0.0.obs;
  final RxDouble temperaturaMax   = 0.0.obs;
  final RxDouble temperaturaMin   = 0.0.obs;
  final RxDouble sensacaoSol      = 0.0.obs;
  final RxDouble sensacaoChuva    = 0.0.obs;
  final RxString descricaoTempo   = ''.obs;
  final RxString weatherIcon      = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _restoreUnidade();
    _restoreLastQuery().then((_) async {
      if (lastQuery.value.isNotEmpty) {
        await fetchByLatLon(lastQuery.value);
      } else {
        await fetchByLatLon('-8.8828,-36.4966');
      }
    });
  }

  Future<void> fetchByLatLon(String latLon) async {
    final parts = latLon.split(',');
    if (parts.length != 2) return;
    final lat = double.tryParse(parts[0].trim());
    final lon = double.tryParse(parts[1].trim());
    if (lat == null || lon == null) return;

    setCoord(lat, lon);
    await _fetchAndSet(lat, lon);
  }

  Future<void> fetchByCityName(String cityNameQuery) async {
    if (cityNameQuery.trim().isEmpty) return;
    try {
      final results = await _ow.searchCities(cityNameQuery, limit: 1);
      if (results.isEmpty) return;
      final first = results.first;
      final lat = (first['lat'] as num).toDouble();
      final lon = (first['lon'] as num).toDouble();

      setCoord(lat, lon);
      await _fetchAndSet(lat, lon);
    } catch (_) {
    }
  }

  Future<void> applyGpsPosition({
    required double lat,
    required double lon,
    String? resolvedCityName,
  }) async {
    _gpsCity.value = CityModel(
      name: resolvedCityName ?? 'Minha localização',
      lat: lat,
      lon: lon,
    );
    setCoord(lat, lon, fromGps: true);
    await _fetchAndSet(lat, lon, overrideCityName: resolvedCityName);
  }

  void clearGpsOverride() {
    _gpsCity.value = null;
    _gpsCoord.value = null;
  }

  Future<void> _fetchAndSet(double lat, double lon, {String? overrideCityName}) async {
    loading.value = true;
    try {
      final data = await _ow.getCurrentByLatLon(lat, lon);
      weatherJson.value = data;

      final fetchedName = (data['name'] ?? '') as String;
      if ((overrideCityName ?? '').trim().isNotEmpty) {
        cityName.value = overrideCityName!.trim();
      } else if (fetchedName.trim().isNotEmpty) {
        cityName.value = fetchedName.trim();
      } else {
        cityName.value = 'Minha localização';
      }

      final main = (data['main'] as Map?) ?? {};
      final weatherList = (data['weather'] as List?) ?? const [];
      final weather0 = weatherList.isNotEmpty ? (weatherList.first as Map) : {};
      final rain = (data['rain'] as Map?) ?? {};
      final snow = (data['snow'] as Map?) ?? {};

      temperaturaAtual.value = (main['temp'] as num?)?.toDouble() ?? 0.0;
      temperaturaMax.value   = (main['temp_max'] as num?)?.toDouble() ?? temperaturaAtual.value;
      temperaturaMin.value   = (main['temp_min'] as num?)?.toDouble() ?? temperaturaAtual.value;
      sensacaoSol.value      = (main['feels_like'] as num?)?.toDouble() ?? temperaturaAtual.value;

      final double rain1h = (rain['1h'] as num?)?.toDouble() ?? 0.0;
      final double rain3h = (rain['3h'] as num?)?.toDouble() ?? 0.0;
      final double snow1h = (snow['1h'] as num?)?.toDouble() ?? 0.0;
      final double snow3h = (snow['3h'] as num?)?.toDouble() ?? 0.0;
      sensacaoChuva.value = rain1h != 0.0
          ? rain1h
          : (rain3h != 0.0 ? rain3h : (snow1h != 0.0 ? snow1h : snow3h));

      descricaoTempo.value = (weather0['description'] ?? '') as String;
      weatherIcon.value    = (weather0['icon'] ?? '') as String;

      currentCoord.value = LatLng(lat, lon);

      lastQuery.value = '$lat,$lon';
      await _persistLastQuery();
    } finally {
      loading.value = false;
    }
  }

  Future<void> _restoreLastQuery() async {
    final sp = await SharedPreferences.getInstance();
    lastQuery.value = sp.getString('last_query') ?? '';
  }

  Future<void> _persistLastQuery() async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString('last_query', lastQuery.value);
  }

  Future<void> _restoreUnidade() async {
    final sp = await SharedPreferences.getInstance();
    final saved = sp.getString('unidade_temp') ?? 'C';
    _unidadeTemp.value = saved;
    unidade.value = (saved == 'F') ? 'Fahrenheit' : 'Celsius';
  }

  Future<void> _persistUnidade() async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString('unidade_temp', _unidadeTemp.value);
  }

  String get cityNameText => cityName.value;
  double? get tempC =>
      (weatherJson.value?['main']?['temp'] as num?)?.toDouble();
  String get description {
    final list = weatherJson.value?['weather'] as List<dynamic>?;
    if (list == null || list.isEmpty) return '';
    return (list.first['description'] ?? '') as String;
  }
  String get iconUrl {
    final list = weatherJson.value?['weather'] as List<dynamic>?;
    if (list == null || list.isEmpty) return '';
    final icon = (list.first['icon'] ?? '') as String;
    return icon.isEmpty ? '' : 'https://openweathermap.org/img/wn/$icon@2x.png';
  }
}
