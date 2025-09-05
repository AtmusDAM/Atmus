import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'package:atmus/presentation/controllers/location_controller.dart';
import 'package:atmus/viewmodels/locais/locais_viewmodel.dart';
import 'package:atmus/viewmodels/home/home_viewmodel.dart';

class MiniMapaWidget extends StatefulWidget {
  const MiniMapaWidget({super.key});
  @override
  State<MiniMapaWidget> createState() => _MiniMapaWidgetState();
}

class _MiniMapaWidgetState extends State<MiniMapaWidget> {
  final LocationController loc = Get.find<LocationController>();
  final LocaisViewModel locais = Get.find<LocaisViewModel>();
  final HomeViewModel home = Get.find<HomeViewModel>();

  final MapController _mapCtl = MapController();

  final Rx<LatLng> _center = LatLng(-8.0476, -34.8770).obs;
  final RxDouble _zoom = 9.5.obs;

  late final Worker _gpsWorker;
  late final Worker _cityWorker;
  late final Worker _gpsCoordWorker; // <<< NOVO

  @override
  void initState() {
    super.initState();

    final p = loc.position.value;
    if (p != null) {
      _center.value = LatLng(p.latitude, p.longitude);
    } else {
      final c = locais.selectedCity.value;
      if (c?.lat != null && c?.lon != null) {
        _center.value = LatLng(c!.lat!, c.lon!);
      }
    }

    _gpsWorker = ever(loc.position, (pos) {
      if (pos != null) {
        final ll = LatLng(pos.latitude, pos.longitude);
        _center.value = ll;
        _zoom.value = 12.0;
        _mapCtl.move(ll, _zoom.value);
        setState(() {});
      }
    });

    _cityWorker = ever(locais.selectedCity, (city) {
      if (city != null && city.lat != null && city.lon != null) {
        final ll = LatLng(city.lat!, city.lon!);
        _center.value = ll;
        _zoom.value = 11.0;
        _mapCtl.move(ll, _zoom.value);
        setState(() {});
      }
    });

    // >>> NOVO: quando o WeatherController informar coord. de GPS
    _gpsCoordWorker = ever(home.gpsCoord, (LatLng? ll) {
      if (ll != null) {
        _center.value = ll;
        _zoom.value = 12.0;
        _mapCtl.move(ll, _zoom.value);
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _gpsWorker.dispose();
    _cityWorker.dispose();
    _gpsCoordWorker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
