import 'dart:async';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:atmus/data/models/city_model.dart';
import 'package:atmus/data/services/openweather_service.dart';
import 'package:atmus/viewmodels/home/home_viewmodel.dart';

class LocaisViewModel extends GetxController {
  final OpenWeatherService _svc;

  LocaisViewModel({OpenWeatherService? service})
      : _svc = service ?? OpenWeatherService();

  final RxList<CityModel> _all = <CityModel>[].obs;
  final RxList<CityModel> filteredCities = <CityModel>[].obs;

  final RxString _query = ''.obs;
  final RxBool loading = false.obs;
  Timer? _debounce;

  final RxInt searchRev = 0.obs;

  final Rxn<CityModel> selectedCity = Rxn<CityModel>();

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
    final extras = await _restoreFavorites();
    _all.assignAll(_seed);
    if (extras.isNotEmpty) _all.addAll(extras);
    _applyFilter();
    _warmupSeedTemps();
  }

  void onSearchChanged(String text) => _query.value = text;
  void filterCities(String text) => onSearchChanged(text);

  void _onQueryChanged(String q) {
    _debounce?.cancel();
    if (q.trim().isEmpty) {
      _removeSearchResults();
      _applyFilter();
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 400), () => _searchOnline(q));
  }

  Future<void> _searchOnline(String q) async {
    final myQuery = q.trim().toLowerCase();
    loading.value = true;
    try {
      final raw = await _svc.searchCities(q, limit: 15);
      if (_query.value.trim().toLowerCase() != myQuery) return;

      final seen = <String>{};
      final online = <CityModel>[];
      for (final m in raw) {
        final c = CityModel.fromOpenWeatherGeocode(m);
        final key =
            '${c.name.toLowerCase()}|${(c.state ?? '').toLowerCase()}|${(c.country ?? '').toLowerCase()}';
        if (seen.add(key)) online.add(c);
      }

      final hydrated = await Future.wait(online.map(_fetchTempsAndCoordsIfNeeded));
      if (_query.value.trim().toLowerCase() != myQuery) return;

      _removeSearchResults();
      _all.addAll(hydrated);
      _applyFilter();
    } finally {
      loading.value = false;
    }
  }

  void _removeSearchResults() {
    _all.removeWhere((e) => e.isFromSearch && !e.isFavorite);
  }

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
        isFromSearch: (c.isFavorite || _all[idx].isFavorite)
            ? false
            : (c.isFromSearch || _all[idx].isFromSearch),
      );
    }
  }

  Future<void> toggleFavorite(CityModel city) async {
    final idx = _all.indexWhere((c) => _samePlace(c, city));
    if (idx >= 0) {
      final cur = _all[idx];
      final willBeFavorite = !cur.isFavorite;

      if (willBeFavorite) {
        _all[idx] = cur.copyWith(isFavorite: true, isFromSearch: false);
      } else {
        if (cur.isFromSearch || !_isSeed(cur)) {
          _all.removeAt(idx);
        } else {
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

  Future<List<CityModel>> _restoreFavorites() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getStringList('fav_cities') ?? [];
    final favs = raw.map(CityModel.deserialize).toList();

    final extras = <CityModel>[];
    for (final fav in favs) {
      final fixed = fav.copyWith(isFromSearch: false);
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

  Future<void> selectCity(CityModel city) async {
    CityModel hydrated = city;
    if (city.lat == null || city.lon == null) {
      hydrated = await _fetchTempsAndCoordsIfNeeded(city);
    }
    selectedCity.value = hydrated;
    try {
      final home = Get.find<HomeViewModel>();
      if (hydrated.lat != null && hydrated.lon != null) {
        await home.fetchByLatLon('${hydrated.lat},${hydrated.lon}');
      } else {
        await home.fetchByCityName(hydrated.name);
      }
    } catch (_) {}
  }

  void _applyFilter() {
    final q = _query.value.trim().toLowerCase();
    if (q.isEmpty) {
      filteredCities.assignAll(_all.where((c) => c.isFavorite));
    } else {
      filteredCities.assignAll(_all.where((c) {
        final inName = c.name.toLowerCase().contains(q);
        final inState = (c.state ?? '').toLowerCase().contains(q);
        final inCountry = (c.country ?? '').toLowerCase().contains(q);
        return inName || inState || inCountry;
      }));
    }
  }

  Future<void> _warmupSeedTemps() async {
    unawaited(Future(() async {
      for (final c in List<CityModel>.from(_all)) {
        final needs = (c.lat == null || c.lon == null) ||
            (c.minTemp == null || c.maxTemp == null) ||
            (c.minTemp != null && c.maxTemp != null && c.minTemp == c.maxTemp);
        if (needs) {
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
        final double? tNow = (main['temp'] as num?)?.toDouble();
        double? tmin = (main['temp_min'] as num?)?.toDouble();
        double? tmax = (main['temp_max'] as num?)?.toDouble();

        try {
          final dyn = _svc as dynamic;
          final r = await dyn.getMinMaxNext24h(lat, lon);
          if (r != null) {
            final double? fMin =
            (r is Map) ? (r['tmin'] as num?)?.toDouble() : (r.tmin as num?)?.toDouble();
            final double? fMax =
            (r is Map) ? (r['tmax'] as num?)?.toDouble() : (r.tmax as num?)?.toDouble();
            if (fMin != null) tmin = fMin;
            if (fMax != null) tmax = fMax;
          }
        } catch (_) {}

        return city.copyWith(
          lat: lat,
          lon: lon,
          minTemp: tmin ?? tNow,
          maxTemp: tmax ?? tNow,
        );
      }
    } catch (_) {}

    return city;
  }

  void clearSearch() {
    _debounce?.cancel();
    _query.value = '';
    _removeSearchResults();
    _applyFilter();
    searchRev.value++;
  }

  CityModel? get currentCity => selectedCity.value;

  ({double lat, double lon})? get selectedLatLon {
    final c = selectedCity.value;
    if (c?.lat != null && c?.lon != null) {
      return (lat: c!.lat!, lon: c.lon!);
    }
    return null;
  }

  Future<({double lat, double lon})?> ensureSelectedCoords() async {
    final c = selectedCity.value;
    if (c == null) return null;
    if (c.lat != null && c.lon != null) return (lat: c.lat!, lon: c.lon!);
    final hydrated = await _fetchTempsAndCoordsIfNeeded(c);
    selectedCity.value = hydrated;
    if (hydrated.lat != null && hydrated.lon != null) {
      return (lat: hydrated.lat!, lon: hydrated.lon!);
    }
    return null;
  }

  Future<void> selectByCoords(double lat, double lon, {String name = 'GPS'}) async {
    final city = CityModel(
      name: name,
      lat: lat,
      lon: lon,
      isFavorite: false,
      isFromSearch: false,
    );
    final hydrated = await _fetchTempsAndCoordsIfNeeded(city);
    selectedCity.value = hydrated;
    try {
      final home = Get.find<HomeViewModel>();
      await home.fetchByLatLon('$lat,$lon');
    } catch (_) {}
  }
}
