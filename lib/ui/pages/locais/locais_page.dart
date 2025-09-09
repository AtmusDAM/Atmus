import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:atmus/viewmodels/locais/locais_viewmodel.dart';
import 'package:atmus/data/models/city_model.dart';
import 'package:atmus/presentation/controllers/weather_controller.dart';
import 'package:atmus/viewmodels/home/home_viewmodel.dart';
import 'package:atmus/viewmodels/configuracao/configuracao_viewmodel.dart';

class LocaisPage extends StatelessWidget {
  LocaisPage({super.key});

  final LocaisViewModel controller = Get.find<LocaisViewModel>();
  final ThemeController themeController = Get.find<ThemeController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDark = themeController.themeMode.value == ThemeMode.dark;
      final gradientColors = isDark
          ? [
        const Color(0xFF1B263B),
        const Color(0xFF0D1B2A),
        const Color(0xFF1B263B),
      ]
          : [Colors.blue[200]!, Colors.blue[100]!, Colors.blue[200]!];

      return Drawer(
        width: MediaQuery.of(context).size.width * 0.8,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: gradientColors,
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título + fechar
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Locais',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.close,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),

                // Busca
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: TextField(
                    onChanged: controller.filterCities,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black),
                    decoration: InputDecoration(
                      hintText: 'Encontrar local',
                      hintStyle: TextStyle(
                        color: (isDark ? Colors.white : Colors.black).withOpacity(0.6),
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: isDark ? Colors.white.withOpacity(0.7) : Colors.black54,
                        size: 20,
                      ),
                      filled: true,
                      fillColor: isDark
                          ? Colors.white.withOpacity(0.1)
                          : Colors.grey[300]!.withOpacity(0.5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),

                // Botão "Usar minha localização"
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: Material(
                    color: isDark ? const Color(0xFF1B263B) : Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () async {
                        final weatherCtl = Get.find<WeatherController>();
                        if (Scaffold.maybeOf(context)?.isDrawerOpen ?? false) {
                          Navigator.of(context).pop();
                        } else {
                          Get.back();
                        }
                        await weatherCtl.fetchByCurrentLocation();
                        final err = weatherCtl.error.value;
                        if (err != null) {
                          Get.snackbar('Localização', err, snackPosition: SnackPosition.BOTTOM);
                        } else {
                          Get.snackbar('Localização', 'Cidade detectada e clima atualizado.',
                              snackPosition: SnackPosition.BOTTOM);
                        }
                      },
                      child: ListTile(
                        leading: Icon(
                          Icons.my_location,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                        title: Text(
                          'Usar minha localização',
                          style: TextStyle(color: isDark ? Colors.white : Colors.black),
                        ),
                        subtitle: Text(
                          'Detectar automaticamente sua cidade',
                          style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.black54,
                            fontSize: 12,
                          ),
                        ),
                        trailing: Icon(
                          Icons.chevron_right,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Cidades',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                Expanded(
                  child: Obx(() {
                    final List<CityModel> cities = controller.filteredCities;
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withOpacity(0.08)
                            : Colors.grey[200]!.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.shade400,
                          width: 1,
                        ),
                      ),
                      child: ListView.builder(
                        itemCount: cities.length,
                        itemBuilder: (context, index) {
                          final city = cities[index];
                          // Fallback visual para evitar "null null"
                          final minTxt =
                          city.minTemp != null ? city.minTemp!.round().toString() : '–';
                          final maxTxt =
                          city.maxTemp != null ? city.maxTemp!.round().toString() : '–';

                          return Obx(() {
                            final isSelected =
                                controller.selectedCity.value?.name == city.name;
                            return GestureDetector(
                              onTap: () {
                                final home = Get.find<HomeViewModel>();
                                home.clearGpsOverride();
                                controller.selectCity(city);
                                Navigator.of(context).pop();
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.blueAccent.withOpacity(0.3)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        city.isFavorite ? Icons.star : Icons.star_border,
                                        color: city.isFavorite
                                            ? Colors.amber
                                            : isDark
                                            ? Colors.white.withOpacity(0.8)
                                            : Colors.black54,
                                      ),
                                      onPressed: () => controller.toggleFavorite(city),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        city.name,
                                        style: TextStyle(
                                          color: isDark ? Colors.white : Colors.black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      "$minTxt°  $maxTxt°",
                                      style: TextStyle(
                                        color: isDark
                                            ? Colors.white.withOpacity(0.9)
                                            : Colors.black87,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          });
                        },
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      );
    });
  }
}
