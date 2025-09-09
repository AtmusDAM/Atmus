import 'dart:async';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:atmus/data/models/city_model.dart';
import 'package:atmus/services/openweather_service.dart';
import 'package:atmus/viewmodels/home/home_viewmodel.dart';

class LocaisViewModel extends GetxController {
  final OpenWeatherService _svc;

  LocaisViewModel({OpenWeatherService? service})
      : _svc = service ?? OpenWeatherService();

  // ---------------- Fonte da verdade ----------------
  final RxList<CityModel> _all = <CityModel>[].obs;

  // Lista para UI
  final RxList<CityModel> filteredCities = <CityModel>[].obs;

  // Busca e estado
  final RxString _query = ''.obs;
  final RxBool loading = false.obs;
  Timer? _debounce;

  /// Key reativa para “resetar” o TextField de busca
  final RxInt searchRev = 0.obs;

  // Seleção atual
  final Rxn<CityModel> selectedCity = Rxn<CityModel>();

  // Cidades seed (MUTÁVEL para podermos refletir favoritos restaurados)
  final List<CityModel> _seed = <CityModel>[
    const CityModel(name: 'Garanhuns'),
    const CityModel(name: 'Recife'),
    const CityModel(name: 'São Paulo'),
    const CityModel(name: 'Rio de Janeiro'),
  ];

  @override
  void onInit() {
    super.onInit();
    _boot();
    ever<String>(_query, _onQueryChanged);
  }

  Future<void> _boot() async {
    // 1) Restaurar favoritos → retorna extras (não-seed)
    final extras = await _restoreFavorites();

    // 2) Popular _all com seeds (já possivelmente marcados como favoritos) + extras
    _all.assignAll(_seed);
    if (extras.isNotEmpty) _all.addAll(extras);

    // 3) Aplica filtro (mostra só favoritos) e hidrata dados em background
    _applyFilter();
    _warmupSeedTemps();
  }

  // ---------------- BUSCA ----------------
  void onSearchChanged(String text) => _query.value = text;
  void filterCities(String text) => onSearchChanged(text);

  void _onQueryChanged(String q) {
    _debounce?.cancel();
    if (q.trim().isEmpty) {
      _removeSearchResults(); // limpa histórico não-favorito
      _applyFilter();         // exibe apenas favoritos
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 400), () => _searchOnline(q));
  }

  Future<void> _searchOnline(String q) async {
    // Guard para evitar aplicar resultado atrasado
    final myQuery = q.trim().toLowerCase();

    loading.value = true;
    try {
      final raw = await _svc.searchCities(q, limit: 15);

      if (_query.value.trim().toLowerCase() != myQuery) return;

      // Dedup por (name|state|country)
      final seen = <String>{};
      final online = <CityModel>[];
      for (final m in raw) {
        final c = CityModel.fromOpenWeatherGeocode(m); // isFromSearch = true
        final key =
            '${c.name.toLowerCase()}|${(c.state ?? '').toLowerCase()}|${(c.country ?? '').toLowerCase()}';
        if (seen.add(key)) online.add(c);
      }

      // Hidrata coordenadas + min/max
      await Future.wait(online.map(_fetchTempsAndCoordsIfNeeded));

      if (_query.value.trim().toLowerCase() != myQuery) return;

      // Remove apenas resultados de busca não-favoritos e insere os novos
      _removeSearchResults();
      _all.addAll(online);
      _applyFilter(); // com busca ativa, mostramos todos os resultados
    } finally {
      loading.value = false;
    }
  }

  /// Remove SOMENTE resultados de busca que não são favoritos
  void _removeSearchResults() {
    _all.removeWhere((e) => e.isFromSearch && !e.isFavorite);
  }

  // ---------------- ADIÇÃO ----------------
  Future<void> addCity(CityModel city) async {
    final hydrated = await _fetchTempsAndCoordsIfNeeded(city);
    _mergeIntoAll(hydrated);
    _applyFilter();
    if (hydrated.isFavorite) await _persistFavorites();
  }

  Future<void> addCityFromJson(Map<String, dynamic> json) async {
    final city = CityModel.fromJson(json);
    await addCity(city);
  }

  void _mergeIntoAll(CityModel c) {
    final idx = _all.indexWhere((x) => _samePlace(x, c));
    if (idx < 0) {
      _all.add(c);
    } else {
      _all[idx] = _all[idx].copyWith(
        name: c.name,
        lat: c.lat ?? _all[idx].lat,
        lon: c.lon ?? _all[idx].lon,
        state: c.state ?? _all[idx].state,
        country: c.country ?? _all[idx].country,
        minTemp: c.minTemp ?? _all[idx].minTemp,
        maxTemp: c.maxTemp ?? _all[idx].maxTemp,
        isFavorite: c.isFavorite || _all[idx].isFavorite,
        // se virou favorito, integra a lista principal (não é "só de busca")
        isFromSearch: (c.isFavorite || _all[idx].isFavorite)
            ? false
            : (c.isFromSearch || _all[idx].isFromSearch),
      );
    }
  }

  // ---------------- FAVORITOS ----------------
  Future<void> toggleFavorite(CityModel city) async {
    final idx = _all.indexWhere((c) => _samePlace(c, city));
    if (idx >= 0) {
      final cur = _all[idx];
      final willBeFavorite = !cur.isFavorite;

      if (willBeFavorite) {
        // Marcou estrela → integra lista principal
        _all[idx] = cur.copyWith(isFavorite: true, isFromSearch: false);
      } else {
        // Tirou estrela
        if (cur.isFromSearch || !_isSeed(cur)) {
          // Se veio da busca (histórico) OU não é seed → remove da fonte
          _all.removeAt(idx);
        } else {
          // É seed → mantém na fonte, mas some da UI porque não é favorito
          _all[idx] = cur.copyWith(isFavorite: false);
        }
      }

      _applyFilter();
      await _persistFavorites();
    }
  }

  bool _isSeed(CityModel c) {
    return _seed.any((s) => _samePlace(s, c));
  }

  bool _samePlace(CityModel a, CityModel b) {
    if (a.lat != null && a.lon != null && b.lat != null && b.lon != null) {
      return a.lat == b.lat && a.lon == b.lon;
    }
    return a.name.toLowerCase().trim() == b.name.toLowerCase().trim() &&
        (a.state ?? '').toLowerCase().trim() ==
            (b.state ?? '').toLowerCase().trim() &&
        (a.country ?? '').toLowerCase().trim() ==
            (b.country ?? '').toLowerCase().trim();
  }

  Future<void> _persistFavorites() async {
    final sp = await SharedPreferences.getInstance();
    final favs =
    _all.where((c) => c.isFavorite).map((c) => c.serialize()).toList();
    await sp.setStringList('fav_cities', favs);
  }

  /// Restaura favoritos; retorna a lista de favoritos que **não** são seeds.
  Future<List<CityModel>> _restoreFavorites() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getStringList('fav_cities') ?? [];
    final favs = raw.map(CityModel.deserialize).toList();

    final extras = <CityModel>[];
    for (final fav in favs) {
      final fixed = fav.copyWith(isFromSearch: false); // favorito nunca é “só busca”
      final seedIdx = _seed.indexWhere((s) => _samePlace(s, fixed));

      if (seedIdx >= 0) {
        final s = _seed[seedIdx];
        _seed[seedIdx] = s.copyWith(
          isFavorite: true,
          lat: fixed.lat ?? s.lat,
          lon: fixed.lon ?? s.lon,
          state: fixed.state ?? s.state,
          country: fixed.country ?? s.country,
          minTemp: fixed.minTemp ?? s.minTemp,
          maxTemp: fixed.maxTemp ?? s.maxTemp,
          isFromSearch: false,
        );
      } else {
        extras.add(fixed);
      }
    }
    return extras;
  }

  // ---------------- SELEÇÃO ----------------
  Future<void> selectCity(CityModel city) async {
    selectedCity.value = city;

    try {
      final home = Get.find<HomeViewModel>();
      if (city.lat != null && city.lon != null) {
        await home.fetchByLatLon('${city.lat},${city.lon}');
      } else {
        await home.fetchByCityName(city.name);
      }
    } catch (_) {}
  }

  // ---------------- FILTRO (regra principal) ----------------
  void _applyFilter() {
    final q = _query.value.trim().toLowerCase();

    if (q.isEmpty) {
      // EXIGÊNCIA: mostrar APENAS favoritos quando não há busca
      filteredCities.assignAll(_all.where((c) => c.isFavorite));
    } else {
      // Com busca ativa, mostrar resultados (favoritos + não-favoritos)
      filteredCities.assignAll(_all.where((c) {
        final inName = c.name.toLowerCase().contains(q);
        final inState = (c.state ?? '').toLowerCase().contains(q);
        final inCountry = (c.country ?? '').toLowerCase().contains(q);
        return inName || inState || inCountry;
      }));
    }
  }

  // ---------------- Hidratação de coord + min/max ----------------
  Future<void> _warmupSeedTemps() async {
    unawaited(Future(() async {
      for (final c in List<CityModel>.from(_all)) {
        if (c.lat == null || c.lon == null || c.minTemp == null || c.maxTemp == null) {
          final updated = await _fetchTempsAndCoordsIfNeeded(c);
          final idx = _all.indexWhere((x) => identical(x, c));
          if (idx >= 0) _all[idx] = updated;
        }
      }
      _applyFilter();
    }));
  }

  Future<CityModel> _fetchTempsAndCoordsIfNeeded(CityModel city) async {
    double? lat = city.lat;
    double? lon = city.lon;

    try {
      if (lat == null || lon == null) {
        final geo = await _svc.searchCities(city.name, limit: 1);
        if (geo.isNotEmpty) {
          lat = (geo.first['lat'] as num?)?.toDouble();
          lon = (geo.first['lon'] as num?)?.toDouble();
        }
      }

      if (lat != null && lon != null) {
        final cur = await _svc.getCurrentByLatLon(lat, lon);
        final main = (cur['main'] as Map?) ?? {};
        final double? tmin = (main['temp_min'] as num?)?.toDouble();
        final double? tmax = (main['temp_max'] as num?)?.toDouble();

        return city.copyWith(
          lat: lat,
          lon: lon,
          minTemp: tmin,
          maxTemp: tmax,
        );
      }
    } catch (_) {
      // silencioso
    }

    return city;
  }

  // ---------------- Limpeza do campo de busca ----------------
  /// Limpa busca, remove resultados não-favoritos e volta a exibir apenas favoritos.
  /// Além disso, incrementa `searchRev` para forçar o TextField a ser remontado vazio.
  void clearSearch() {
    _debounce?.cancel();
    _query.value = '';
    _removeSearchResults();
    _applyFilter();
    searchRev.value++; // força rebuild do TextField (Key muda)
  }
}
