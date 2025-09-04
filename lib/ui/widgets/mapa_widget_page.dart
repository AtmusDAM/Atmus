import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'package:atmus/presentation/controllers/location_controller.dart';
import 'package:atmus/viewmodels/locais/locais_viewmodel.dart';

class MiniMapaWidget extends StatefulWidget {
  const MiniMapaWidget({super.key});

  @override
  State<MiniMapaWidget> createState() => _MiniMapaWidgetState();
}

class _MiniMapaWidgetState extends State<MiniMapaWidget> {
  final LocationController loc = Get.find<LocationController>();
  final LocaisViewModel locais = Get.find<LocaisViewModel>();

  final MapController _mapCtl = MapController();

  // Começa num fallback (Recife). Depois GPS/cidade substituem.
  final Rx<LatLng> _center = LatLng(-8.0476, -34.8770).obs;
  final RxDouble _zoom = 9.0.obs;

  late final Worker _gpsWorker;
  late final Worker _cityWorker;

  @override
  void initState() {
    super.initState();

    // Usa o GPS atual se já existir
    final p = loc.position.value;
    if (p != null) {
      _center.value = LatLng(p.latitude, p.longitude);
    } else {
      // se já houver cidade selecionada com lat/lon, usa também
      final c = locais.selectedCity.value;
      if (c?.lat != null && c?.lon != null) {
        _center.value = LatLng(c!.lat!, c.lon!);
      }
    }

    // Reagir a atualizações do GPS
    _gpsWorker = ever(loc.position, (pos) {
      if (pos != null) {
        final ll = LatLng(pos.latitude, pos.longitude);
        _center.value = ll;
        _zoom.value = 12.0;
        _mapCtl.move(ll, _zoom.value);
        setState(() {}); // atualiza o marcador
      }
    });

    // Reagir à troca de cidade no drawer (precisa de lat/lon no CityModel)
    _cityWorker = ever(locais.selectedCity, (city) {
      if (city != null && city.lat != null && city.lon != null) {
        final ll = LatLng(city.lat!, city.lon!);
        _center.value = ll;
        _zoom.value = 11.0;
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

  @override
  Widget build(BuildContext context) {
    // Obx para que o marker redesenhe quando _center mudar
    return Obx(
          () => FlutterMap(
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
          MarkerLayer(
            markers: [
              Marker(
                width: 34,
                height: 34,
                point: _center.value,
                child: const Icon(
                  Icons.location_on,
                  color: Colors.redAccent,
                  size: 26,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
