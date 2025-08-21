import 'package:atmus/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MiniMapaWidget extends StatelessWidget {
  final String apiKey = ApiService.apiKey;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa Meteorológico'),
        backgroundColor: const Color(0xFF1B263B),
      ),
      backgroundColor: const Color(0xFF0D1B2A),
      body: FlutterMap(
        options: MapOptions(
          center: LatLng(-8.0, -35.0),
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
            opacity: 0.5,
            child: TileLayer(
              urlTemplate:
              "https://tile.openweathermap.org/map/clouds_new/{z}/{x}/{y}.png?appid=$apiKey",
              userAgentPackageName: 'com.example.atmus',
            ),
          ),
        ],
      ),
    );
  }
}
