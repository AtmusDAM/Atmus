import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:atmus/viewmodels/home/home_viewmodel.dart';
import 'package:atmus/viewmodels/dados/dados_viewmodel.dart';

class DadosPage extends StatelessWidget {
  DadosPage({super.key});

  // Use as instâncias já registradas (não crie novas aqui)
  final DadosViewModel controller = Get.find<DadosViewModel>();
  final HomeViewModel home = Get.find<HomeViewModel>();

  Widget _buildCard(String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1B263B),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade800, width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildPrecipitacao(String periodo, String porcentagem, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1B263B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade800, width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(periodo, style: const TextStyle(color: Colors.white))),
          Text(porcentagem, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                        // Prioridade: cidade do GPS; se vazia, usa a escolhida
                        String nomeCidade = home.gpsCity.value.trim();
                        if (nomeCidade.isEmpty) {
                          final c = controller.locaisController.selectedCity.value;
                          nomeCidade = c != null ? "${c.name}, PE" : "Carregando...";
                        }
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
                    onPressed: () => Scaffold.maybeOf(context)?.openDrawer(),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              const Text(
                "Dados+",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),

              const SizedBox(height: 24),

              // Linha 1: Pressão / Umidade (INT)
              Obx(
                    () => Row(
                  children: [
                    _buildCard(
                      "Pressão",
                      "${controller.pressao.value} mb",
                      Icons.speed,
                    ),
                    const SizedBox(width: 8),
                    _buildCard(
                      "Umidade",
                      "${controller.umidade.value}%",
                      Icons.water_drop,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Linha 2: Vento (DOUBLE) / UV
              Obx(
                    () => Row(
                  children: [
                    _buildCard(
                      "Vento",
                      "${controller.vento.value.toStringAsFixed(1)} m/s",
                      Icons.air,
                    ),
                    const SizedBox(width: 8),
                    _buildCard(
                      "Índice UV",
                      controller.indiceUV.value,
                      Icons.wb_sunny,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              const Text(
                "Precipitação",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              // Manhã / Tarde / Noite (INT)
              Obx(
                    () => Column(
                  children: [
                    _buildPrecipitacao(
                      "Manhã",
                      "${controller.precipitacaoManha.value}%",
                      Icons.wb_sunny,
                    ),
                    _buildPrecipitacao(
                      "Tarde",
                      "${controller.precipitacaoTarde.value}%",
                      Icons.cloud,
                    ),
                    _buildPrecipitacao(
                      "Noite",
                      "${controller.precipitacaoNoite.value}%",
                      Icons.nights_stay,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
