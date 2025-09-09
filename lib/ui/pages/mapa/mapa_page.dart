import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'package:atmus/data/services/api_service.dart';
import 'package:atmus/viewmodels/home/home_viewmodel.dart';
import 'package:atmus/viewmodels/configuracao/configuracao_viewmodel.dart';

class MapaPage extends StatefulWidget {
  const MapaPage({super.key});
  @override
  State<MapaPage> createState() => _MapaPageState();
}

class _MapaPageState extends State<MapaPage> {
  final HomeViewModel home = Get.find<HomeViewModel>();
  final ThemeController themeController = Get.find<ThemeController>();

  final MapController _mapCtl = MapController();
  final Rx<LatLng> _center = LatLng(-8.0476, -34.8770).obs;
  final RxDouble _zoom = 11.0.obs;
  final RxString _overlay = 'Nuvens'.obs;

  late final Worker _coordWorker;
  late final Worker _gpsCompatWorker;

  void _hydrateInitialCenter() {
    if (home.currentCoord.value != null) {
      _center.value = home.currentCoord.value!;
      return;
    }
    if (home.gpsCoord.value != null) {
      _center.value = home.gpsCoord.value!;
      return;
    }
    final q = home.lastQuery.value;
    final parts = q.split(',');
    if (parts.length == 2) {
      final lat = double.tryParse(parts[0].trim());
      final lon = double.tryParse(parts[1].trim());
      if (lat != null && lon != null) {
        _center.value = LatLng(lat, lon);
      }
    }
  }

  @override
  void initState() {
    super.initState();

    _hydrateInitialCenter();

    _coordWorker = ever<LatLng?>(home.currentCoord, (ll) {
      if (ll == null) return;
      _center.value = ll;
      _zoom.value = 12.0;
      _mapCtl.move(ll, _zoom.value);
      setState(() {});
    });

    _gpsCompatWorker = ever<LatLng?>(home.gpsCoord, (ll) {
      if (ll == null) return;
      _center.value = ll;
      _zoom.value = 12.0;
      _mapCtl.move(ll, _zoom.value);
      setState(() {});
    });
  }

  @override
  void dispose() {
    _coordWorker.dispose();
    _gpsCompatWorker.dispose();
    super.dispose();
  }

  Widget _overlayChips(bool isDark) {
    final chips = <String>['Temperatura', 'Radar', 'Nuvens', 'Pressão'];
    return Obx(() => Wrap(
      spacing: 8,
      runSpacing: 8,
      children: chips.map((name) {
        final selected = _overlay.value == name;
        return ChoiceChip(
          label: Text(
            name,
            style: TextStyle(
              color: selected
                  ? Colors.white
                  : (isDark ? Colors.white70 : Colors.black87),
            ),
          ),
          selected: selected,
          selectedColor: Colors.blueAccent,
          backgroundColor: isDark ? Colors.white12 : Colors.grey[300],
          onSelected: (_) => _overlay.value = name,
        );
      }).toList(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDark = themeController.themeMode.value == ThemeMode.dark;
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
          child: Column(
            children: [
              // HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back,
                        color: isDark ? Colors.white : Colors.black),
                    onPressed: () => home.selectedIndex.value = 0,
                  ),
                  Expanded(
                    child: Center(
                      child: Obx(() => Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.location_on,
                              color: isDark ? Colors.white : Colors.black),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              home.cityName.value.isEmpty
                                  ? 'Carregando...'
                                  : home.cityName.value,
                              style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black,
                                  fontSize: 18),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      )),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.menu,
                        color: isDark ? Colors.white : Colors.black),
                    onPressed: () => Scaffold.maybeOf(context)?.openDrawer(),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // MAPA
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Obx(() => FlutterMap(
                    mapController: _mapCtl,
                    options: MapOptions(
                      initialCenter: _center.value,
                      initialZoom: _zoom.value,
                      maxZoom: 18,
                      minZoom: 3,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                        subdomains: const ['a', 'b', 'c'],
                      ),
                      Obx(() {
                        final layer = _overlay.value;
                        if (layer.isEmpty) return const SizedBox.shrink();
                        final layerMap = {
                          'Temperatura': 'temp_new',
                          'Radar': 'precipitation_new',
                          'Nuvens': 'clouds_new',
                          'Pressão': 'pressure_new',
                        };
                        final url =
                            'https://tile.openweathermap.org/map/${layerMap[layer]}/{z}/{x}/{y}.png?appid=${ApiService.apiKey}';
                        return TileLayer(
                          urlTemplate: url,
                          backgroundColor: Colors.transparent,
                        );
                      }),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _center.value,
                            width: 40,
                            height: 40,
                            child: const Icon(
                              Icons.my_location,
                              color: Colors.blueAccent,
                              size: 28,
                            ),
                          ),
                        ],
                      ),
                    ],
                  )),
                ),
              ),

              const SizedBox(height: 12),

              // Overlays
              Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1B263B) : Colors.grey[200],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? Colors.grey.shade800 : Colors.grey.shade400,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: _overlayChips(isDark),
              ),
            ],
          ),
        ),
      );
    });
  }
}
