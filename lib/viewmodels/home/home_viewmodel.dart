import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:latlong2/latlong.dart';

import 'package:atmus/services/openweather_service.dart';
import 'package:atmus/data/models/city_model.dart';

class HomeViewModel extends GetxController {
  final OpenWeatherService _ow = OpenWeatherService();

  // ---------------------------------------------------------------------------
  // Estado principal
  // ---------------------------------------------------------------------------
  final RxBool loading = false.obs;

  /// JSON bruto retornado pela OpenWeather /weather
  final Rxn<Map<String, dynamic>> weatherJson = Rxn();

  /// "lat,lon" da última consulta efetiva (seleção de cidade ou GPS)
  final RxString lastQuery = ''.obs;

  /// Nome da cidade exibida na UI (reativo)
  final RxString cityName = ''.obs;

  /// Index reativo da Home (algumas páginas mudam tab via selectedIndex.value = 0)
  final RxInt selectedIndex = 0.obs;

  // ---------------------------------------------------------------------------
  // Preferência de unidade de temperatura
  // ---------------------------------------------------------------------------
  /// Interno: "C" (padrão) ou "F"
  final RxString _unidadeTemp = 'C'.obs;

  /// Shim para sua tela de configuração: "Celsius" | "Fahrenheit"
  final RxString unidade = 'Celsius'.obs;

  /// Símbolo usado na UI
  String get unidadeSimbolo => _unidadeTemp.value == 'F' ? '°F' : '°C';

  /// Converte um valor em °C para a unidade atual (C/F). A UI chama home.displayTemp(x)
  double displayTemp(double tempC) =>
      _unidadeTemp.value == 'F' ? (tempC * 9 / 5 + 32) : tempC;

  /// APIs para trocar unidade (aceita ambos formatos)
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

  // ---------------------------------------------------------------------------
  // Compatibilidade GPS
  // ---------------------------------------------------------------------------
  final Rxn<CityModel> _gpsCity = Rxn<CityModel>();
  CityModel? get gpsCity => _gpsCity.value;

  /// Exigido por `mapa_page.dart`: a página chama `ever(home.gpsCoord, ...)`
  final Rxn<LatLng> _gpsCoord = Rxn<LatLng>();
  Rxn<LatLng> get gpsCoord => _gpsCoord;

  // ---------------------------------------------------------------------------
  // NOVO: coordenada global para sincronizar TODOS os mapas
  // ---------------------------------------------------------------------------
  /// Coordenada atual da cidade selecionada (por busca, seed ou GPS).
  /// Use esta Rx em qualquer mapa para ficar sincronizado.
  final Rxn<LatLng> currentCoord = Rxn<LatLng>();

  /// Atualiza a coordenada global (e mantém compat com gpsCoord, se pertinente).
  void setCoord(double lat, double lon, {bool fromGps = false}) {
    final ll = LatLng(lat, lon);
    currentCoord.value = ll;
    if (fromGps) {
      // Mantém compatibilidade com telas antigas que observam gpsCoord
      _gpsCoord.value = ll;
    }
  }

  // ---------------------------------------------------------------------------
  // Campos reativos esperados pela Home (home_page_content.dart)
  // ---------------------------------------------------------------------------
  final RxDouble temperaturaAtual = 0.0.obs; // °C
  final RxDouble temperaturaMax   = 0.0.obs; // °C
  final RxDouble temperaturaMin   = 0.0.obs; // °C
  final RxDouble sensacaoSol      = 0.0.obs; // feels_like °C
  final RxDouble sensacaoChuva    = 0.0.obs; // mm (chuva 1h/3h ou neve)
  final RxString descricaoTempo   = ''.obs;  // descrição (pt_BR)
  final RxString weatherIcon      = ''.obs;  // código do ícone (ex.: "10d")

  // ---------------------------------------------------------------------------
  // Ciclo de vida
  // ---------------------------------------------------------------------------
  @override
  void onInit() {
    super.onInit();
    _restoreUnidade();
    _restoreLastQuery().then((_) async {
      if (lastQuery.value.isNotEmpty) {
        await fetchByLatLon(lastQuery.value);
      } else {
        // Fallback inicial: Garanhuns
        await fetchByLatLon('-8.8828,-36.4966');
      }
    });
  }

  // ---------------------------------------------------------------------------
  // APIs públicas chamadas por outras VMs / páginas
  // ---------------------------------------------------------------------------

  /// Chamado por várias partes: string "lat,lon"
  Future<void> fetchByLatLon(String latLon) async {
    final parts = latLon.split(',');
    if (parts.length != 2) return;
    final lat = double.tryParse(parts[0].trim());
    final lon = double.tryParse(parts[1].trim());
    if (lat == null || lon == null) return;

    // Atualiza coord imediatamente para mapas reagirem rápido
    setCoord(lat, lon);
    await _fetchAndSet(lat, lon);
  }

  /// Alguns lugares ainda chamam por nome; fazemos geocoding e buscamos por coordenadas
  Future<void> fetchByCityName(String cityNameQuery) async {
    if (cityNameQuery.trim().isEmpty) return;
    try {
      final results = await _ow.searchCities(cityNameQuery, limit: 1);
      if (results.isEmpty) return;
      final first = results.first;
      final lat = (first['lat'] as num).toDouble();
      final lon = (first['lon'] as num).toDouble();

      // Coord global para sincronizar mapas
      setCoord(lat, lon);
      await _fetchAndSet(lat, lon);
    } catch (_) {
      // silencioso para não quebrar UI
    }
  }

  /// Usado pelo WeatherController ao obter o GPS
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
    // Atualiza ambas coordenadas reativas (compat + global)
    setCoord(lat, lon, fromGps: true);
    await _fetchAndSet(lat, lon, overrideCityName: resolvedCityName);
  }

  /// Usado pela tela de Locais quando o usuário “desgruda” do GPS
  void clearGpsOverride() {
    _gpsCity.value = null;
    _gpsCoord.value = null; // limpa coord do mapa (compat)
    // Não limpamos currentCoord para não apagar o foco atual dos mapas;
    // a próxima seleção de cidade irá atualizá-la.
  }

  // ---------------------------------------------------------------------------
  // Helpers internos
  // ---------------------------------------------------------------------------
  Future<void> _fetchAndSet(double lat, double lon, {String? overrideCityName}) async {
    loading.value = true;
    try {
      final data = await _ow.getCurrentByLatLon(lat, lon);
      weatherJson.value = data;

      // Atualiza o nome para a UI reativa
      final fetchedName = (data['name'] ?? '') as String;
      if ((overrideCityName ?? '').trim().isNotEmpty) {
        cityName.value = overrideCityName!.trim();
      } else if (fetchedName.trim().isNotEmpty) {
        cityName.value = fetchedName.trim();
      } else {
        cityName.value = 'Minha localização';
      }

      // Extrai campos esperados pela Home
      final main = (data['main'] as Map?) ?? {};
      final weatherList = (data['weather'] as List?) ?? const [];
      final weather0 = weatherList.isNotEmpty ? (weatherList.first as Map) : {};
      final rain = (data['rain'] as Map?) ?? {};
      final snow = (data['snow'] as Map?) ?? {};

      temperaturaAtual.value = (main['temp'] as num?)?.toDouble() ?? 0.0;
      temperaturaMax.value   = (main['temp_max'] as num?)?.toDouble() ?? temperaturaAtual.value;
      temperaturaMin.value   = (main['temp_min'] as num?)?.toDouble() ?? temperaturaAtual.value;
      sensacaoSol.value      = (main['feels_like'] as num?)?.toDouble() ?? temperaturaAtual.value;

      // chuva (mm) — rain.1h, rain.3h, depois neve se houver
      final double rain1h = (rain['1h'] as num?)?.toDouble() ?? 0.0;
      final double rain3h = (rain['3h'] as num?)?.toDouble() ?? 0.0;
      final double snow1h = (snow['1h'] as num?)?.toDouble() ?? 0.0;
      final double snow3h = (snow['3h'] as num?)?.toDouble() ?? 0.0;
      sensacaoChuva.value = rain1h != 0.0
          ? rain1h
          : (rain3h != 0.0 ? rain3h : (snow1h != 0.0 ? snow1h : snow3h));

      descricaoTempo.value = (weather0['description'] ?? '') as String;
      weatherIcon.value    = (weather0['icon'] ?? '') as String;

      // Mantém coord global coerente (caso backend retorne coords “corrigidas”)
      currentCoord.value = LatLng(lat, lon);

      // Atualiza lastQuery e persiste
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

  // ---------------------------------------------------------------------------
  // Leitores convenientes (se alguma página usar)
  // ---------------------------------------------------------------------------
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
