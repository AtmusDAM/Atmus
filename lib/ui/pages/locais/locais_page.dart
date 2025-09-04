import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:atmus/viewmodels/locais/locais_viewmodel.dart';
import 'package:atmus/data/models/city_model.dart';

// Chama GPS via WeatherController
import 'package:atmus/presentation/controllers/weather_controller.dart';

// <<< NOVO: precisamos do HomeViewModel para limpar override do GPS
import 'package:atmus/viewmodels/home/home_viewmodel.dart';

class LocaisPage extends StatelessWidget {
  LocaisPage({super.key});

  // Use a instância já registrada no main.dart (evita duplicar controller)
  final LocaisViewModel controller = Get.find<LocaisViewModel>();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.8,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1B263B),
              Color(0xFF0D1B2A),
              Color(0xFF1B263B),
            ],
            stops: [0.0, 0.5, 1.0],
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
                    const Expanded(
                      child: Text(
                        'Locais',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),

              // Busca
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.search, color: Colors.white.withOpacity(0.7), size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        onChanged: (value) => controller.filterCities(value),
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                        decoration: InputDecoration(
                          hintText: 'Encontrar local',
                          hintStyle: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 16,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ===== BOTÃO "USAR MINHA LOCALIZAÇÃO" =====
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: Material(
                  color: const Color(0xFF1B263B),
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () async {
                      final weatherCtl = Get.find<WeatherController>();

                      // Fecha o drawer antes do processo (feedback aparece por trás)
                      if (Scaffold.maybeOf(context)?.isDrawerOpen ?? false) {
                        Navigator.of(context).pop();
                      } else {
                        Get.back();
                      }

                      await weatherCtl.fetchByCurrentLocation();

                      final err = weatherCtl.error.value;
                      if (err != null) {
                        Get.snackbar('Localização', err,
                            snackPosition: SnackPosition.BOTTOM);
                      } else {
                        Get.snackbar(
                          'Localização',
                          'Cidade detectada e clima atualizado.',
                          snackPosition: SnackPosition.BOTTOM,
                        );
                        // Se quiser navegar para outra aba, faça aqui.
                        // Get.find<HomeViewModel>().selectedIndex.value = 0;
                      }
                    },
                    child: const ListTile(
                      leading: Icon(Icons.my_location, color: Colors.white),
                      title: Text('Usar minha localização',
                          style: TextStyle(color: Colors.white)),
                      subtitle: Text('Detectar automaticamente sua cidade',
                          style: TextStyle(color: Colors.white70, fontSize: 12)),
                      trailing: Icon(Icons.chevron_right, color: Colors.white70),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // ===== FIM DO BOTÃO =====

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Cidades',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Lista de cidades
              Expanded(
                child: Obx(() {
                  final List<CityModel> cities = controller.filteredCities;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: ListView.builder(
                      itemCount: cities.length,
                      itemBuilder: (context, index) {
                        final city = cities[index];
                        return Obx(() {
                          final isSelected =
                              controller.selectedCity.value?.name == city.name;
                          return GestureDetector(
                            onTap: () {
                              // <<< NOVO: ao escolher manualmente, a cidade manual tem prioridade
                              final home = Get.find<HomeViewModel>();
                              home.clearGpsOverride();              // 1) limpa GPS
                              controller.selectCity(city);          // 2) seleciona cidade
                              Navigator.of(context).pop();          // 3) fecha gaveta

                              // (HomeViewModel escuta selectedCity e dispara:
                              //  - cityName para todas as telas,
                              //  - refresh do clima atual,
                              //  - cityChanged para Previsão/Dados+,
                              //  - recentra mapas se CityModel tiver lat/lon.)
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 14),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.blueAccent.withOpacity(0.3)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    isSelected ? Icons.star : Icons.location_on,
                                    color: Colors.white.withOpacity(0.8),
                                    size: 18,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      city.name,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    "${city.minTemp}° ${city.maxTemp}°",
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
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
  }
}
