import 'package:atmus/viewmodels/home/home_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:atmus/data/services/api_service.dart';
import 'package:atmus/viewmodels/locais/locais_viewmodel.dart';

class MapaPage extends StatefulWidget {
  const MapaPage({Key? key}) : super(key: key);

  @override
  State<MapaPage> createState() => _MapaPageState();
}

class _MapaPageState extends State<MapaPage> {
  final controller = Get.find<HomeViewModel>();
  final LocaisViewModel locaisController = Get.find<LocaisViewModel>();
  final String apiKey = ApiService.apiKey;

  String selectedLayer = "clouds_new";

  final Map<String, String> layers = {
    "Temperatura": "temp_new",
    "Radar": "precipitation_new",
    "Nuvens": "clouds_new",
    "Pressão": "pressure_new",
  };

  LatLng _getCityLatLng() {
    final cidade = locaisController.selectedCity.value;
    if (cidade != null) {
      switch (cidade.name) {
        case "Recife":
          return LatLng(-8.05, -34.9);
        case "Salvador":
          return LatLng(-12.97, -38.5);
        case "Fortaleza":
          return LatLng(-3.7, -38.5);
        case "Crato":
          return LatLng(-7.23, -39.3);
        case "Garanhuns":
          return LatLng(-8.88, -36.49);
        case "Carpina":
          return LatLng(-7.82, -35.29);
        default:
          return LatLng(-8.05, -34.9);
      }
    }
    return LatLng(-8.05, -34.9);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      final homeController = Get.find<HomeViewModel>();
                      homeController.selectedIndex.value = 0;
                    },
                  ),
                  Expanded(
                    child: Center(
                      child: Obx(() {
                        final cidade = controller.locaisController.selectedCity.value;
                        final nomeCidade =
                        cidade != null ? "${cidade.name}, PE" : "Carregando...";
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.location_on, color: Colors.white),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                nomeCidade,
                                style: const TextStyle(color: Colors.white, fontSize: 18),
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
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B263B),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade800, width: 1),
                  ),
                  child: Stack(
                    children: [
                      Obx(() {
                        final centerLatLng = _getCityLatLng();
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: FlutterMap(
                            options: MapOptions(
                              center: centerLatLng,
                              zoom: 6.0,
                              maxZoom: 18.0,
                              minZoom: 2.0,
                            ),
                            children: [
                              TileLayer(
                                urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                                subdomains: ['a', 'b', 'c'],
                                userAgentPackageName: 'com.example.atmus',
                              ),
                              Opacity(
                                opacity: 0.6,
                                child: TileLayer(
                                  urlTemplate:
                                  "https://tile.openweathermap.org/map/$selectedLayer/{z}/{x}/{y}.png?appid=$apiKey",
                                  userAgentPackageName: 'com.example.atmus',
                                ),
                              ),
                            ],
                          ),
                        );
                      }),

                      Positioned(
                        bottom: 16,
                        left: 16,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1B263B).withOpacity(0.9),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 8,
                            runSpacing: 8,
                            children: layers.keys.map((layerName) {
                              return ChoiceChip(
                                label: Text(
                                  layerName,
                                  style: const TextStyle(color: Colors.white),
                                ),
                                selected: selectedLayer == layers[layerName],
                                onSelected: (_) {
                                  setState(() {
                                    selectedLayer = layers[layerName]!;
                                  });
                                },
                                selectedColor: Colors.blueAccent,
                                backgroundColor: Colors.grey[700],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
