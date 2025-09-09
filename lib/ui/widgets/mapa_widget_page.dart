import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'package:atmus/viewmodels/home/home_viewmodel.dart';

class MiniMapaWidget extends StatefulWidget {
  const MiniMapaWidget({super.key});

  @override
  State<MiniMapaWidget> createState() => _MiniMapaWidgetState();
}

class _MiniMapaWidgetState extends State<MiniMapaWidget> {
  final HomeViewModel home = Get.find<HomeViewModel>();

  final MapController _mapCtl = MapController();
  final Rx<LatLng> _center = LatLng(-8.0476, -34.8770).obs; // Recife fallback
  final RxDouble _zoom = 11.0.obs;

  late final Worker _coordWorker;
  late final Worker _gpsCompatWorker;

  // Tenta popular o centro a partir do estado atual do HomeViewModel
  void _hydrateInitialCenter() {
    if (home.currentCoord.value != null) {
      _center.value = home.currentCoord.value!;
      return;
    }
    if (home.gpsCoord.value != null) {
      _center.value = home.gpsCoord.value!;
      return;
    }
    // como fallback, tenta lastQuery: "lat,lon"
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

    // Sincroniza pelo estado novo (fonte de verdade)
    _coordWorker = ever<LatLng?>(home.currentCoord, (ll) {
      if (ll == null) return;
      _center.value = ll;
      _mapCtl.move(ll, _zoom.value);
      setState(() {});
    });

    // Compatibilidade: se alguma parte antiga ainda atualizar só gpsCoord
    _gpsCompatWorker = ever<LatLng?>(home.gpsCoord, (ll) {
      if (ll == null) return;
      _center.value = ll;
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

  @override
  Widget build(BuildContext context) {
    return Obx(() => FlutterMap(
      mapController: _mapCtl,
      options: MapOptions(
        initialCenter: _center.value,
        initialZoom: _zoom.value,
        maxZoom: 18,
        minZoom: 3,
        // mini-mapa geralmente não precisa interação
        interactiveFlags: InteractiveFlag.none,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
          subdomains: const ['a', 'b', 'c'],
        ),
        MarkerLayer(
          markers: [
            Marker(
              point: _center.value,
              width: 36,
              height: 36,
              child: const Icon(Icons.place, color: Colors.redAccent),
            ),
          ],
        ),
      ],
    ));
  }
}
