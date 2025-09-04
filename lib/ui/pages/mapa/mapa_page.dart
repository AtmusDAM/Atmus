import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'package:atmus/presentation/controllers/location_controller.dart';
import 'package:atmus/viewmodels/home/home_viewmodel.dart';
import 'package:atmus/viewmodels/locais/locais_viewmodel.dart';

class MapaPage extends StatefulWidget {
  const MapaPage({super.key});

  @override
  State<MapaPage> createState() => _MapaPageState();
}

class _MapaPageState extends State<MapaPage> {
  final HomeViewModel home = Get.find<HomeViewModel>();
  final LocationController loc = Get.find<LocationController>();
  final LocaisViewModel locais = Get.find<LocaisViewModel>();

  final MapController _mapCtl = MapController();

  final Rx<LatLng> _center = LatLng(-8.0476, -34.8770).obs; // Recife
  final RxDouble _zoom = 10.0.obs;
  final RxString _overlay = 'Nuvens'.obs;

  late final Worker _gpsWorker;
  late final Worker _cityWorker;

  @override
  void initState() {
    super.initState();

    final p = loc.position.value;
    if (p != null) {
      _center.value = LatLng(p.latitude, p.longitude);
    }

    _gpsWorker = ever(loc.position, (pos) {
      if (pos != null) {
        final ll = LatLng(pos.latitude, pos.longitude);
        _center.value = ll;
        _mapCtl.move(ll, _zoom.value);
        setState(() {});
      }
    });

    _cityWorker = ever(locais.selectedCity, (city) {
      if (city != null && city.lat != null && city.lon != null) {
        final ll = LatLng(city.lat!, city.lon!);
        _center.value = ll;
        _zoom.value = 11.5;
        _mapCtl.move(ll, _zoom.value);
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _gpsWorker.dispose();
    _cityWorker.dispose();
    super.dispose();
  }

  Widget _overlayChips() {
    final chips = <String>['Temperatura', 'Radar', 'Nuvens', 'Pressão'];
    return Obx(
          () => Wrap(
        spacing: 8,
        runSpacing: 8,
        children: chips.map((name) {
          final selected = _overlay.value == name;
          return ChoiceChip(
            label: Text(name),
            selected: selected,
            onSelected: (_) {
              _overlay.value = name;
              setState(() {}); // (futuro) trocar layer
            },
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding:
        const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
        child: Column(
          children: [
            // HEADER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => home.selectedIndex.value = 0,
                ),
                Expanded(
                  child: Center(
                    child: Obx(() {
                      String nomeCidade = home.gpsCity.value.trim();
                      if (nomeCidade.isEmpty) {
                        final c = locais.selectedCity.value;
                        nomeCidade =
                        c != null ? "${c.name}, PE" : "Carregando...";
                      }
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.location_on, color: Colors.white),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              nomeCidade,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 18),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.menu, color: Colors.white),
                  onPressed: () => Scaffold.maybeOf(context)?.openDrawer(),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // MAPA
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Obx(
                      () => FlutterMap(
                    mapController: _mapCtl,
                    options: MapOptions(
                      initialCenter: _center.value,
                      initialZoom: _zoom.value,
                      maxZoom: 18,
                      minZoom: 3,
                    ),
                    children: [
                      // <<< tire o `const` aqui
                      TileLayer(
                        urlTemplate:
                        'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                        subdomains: const ['a', 'b', 'c'],
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            width: 40,
                            height: 40,
                            point: _center.value,
                            child: const Icon(
                              Icons.my_location,
                              color: Colors.blueAccent,
                              size: 28,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1B263B),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade800),
              ),
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: _overlayChips(),
            ),
          ],
        ),
      ),
    );
  }
}
