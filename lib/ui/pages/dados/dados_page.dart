import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:atmus/viewmodels/home/home_viewmodel.dart';
import 'package:atmus/viewmodels/dados/dados_viewmodel.dart';
import 'package:atmus/viewmodels/configuracao/configuracao_viewmodel.dart';

class DadosPage extends StatelessWidget {
  DadosPage({super.key});

  final DadosViewModel controller = Get.find<DadosViewModel>();
  final HomeViewModel home = Get.find<HomeViewModel>();
  final ThemeController themeController = Get.find<ThemeController>();

  Widget _buildCard(String title, String value, IconData icon, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1B263B) : Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: isDark ? Colors.grey.shade800 : Colors.grey.shade400,
              width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isDark ? Colors.white : Colors.black, size: 24),
            const SizedBox(height: 8),
            Text(title,
                style: TextStyle(
                    color: isDark ? Colors.grey : Colors.grey[700], fontSize: 12)),
            const SizedBox(height: 4),
            Text(value,
                style: TextStyle(
                    color: isDark ? Colors.white : Colors.black, fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildPrecipitacao(String periodo, String porcentagem, IconData icon, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1B263B) : Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade400, width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, color: isDark ? Colors.white : Colors.black, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(periodo,
                style: TextStyle(color: isDark ? Colors.white : Colors.black)),
          ),
          Text(porcentagem, style: TextStyle(color: isDark ? Colors.white : Colors.black)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDark = themeController.themeMode.value == ThemeMode.dark;
      final bgColor = isDark ? const Color(0xFF0D1B2A) : Colors.white;

      return SafeArea(
        child: Container(
          color: bgColor,
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
                      icon: Icon(Icons.menu, color: isDark ? Colors.white : Colors.black),
                      onPressed: () => Scaffold.maybeOf(context)?.openDrawer(),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                Text(
                  "Dados +",
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),

                const SizedBox(height: 24),

                // Linha 1: Pressão / Umidade
                Obx(() => Row(
                  children: [
                    _buildCard(
                      "Pressão",
                      "${controller.pressao.value} mb",
                      Icons.speed,
                      isDark,
                    ),
                    const SizedBox(width: 8),
                    _buildCard(
                      "Umidade",
                      "${controller.umidade.value}%",
                      Icons.water_drop,
                      isDark,
                    ),
                  ],
                )),

                const SizedBox(height: 12),

                // Linha 2: Vento / UV
                Obx(() => Row(
                  children: [
                    _buildCard(
                      "Vento",
                      "${controller.vento.value.toStringAsFixed(1)} m/s",
                      Icons.air,
                      isDark,
                    ),
                    const SizedBox(width: 8),
                    _buildCard(
                      "Índice UV",
                      controller.indiceUV.value,
                      Icons.wb_sunny,
                      isDark,
                    ),
                  ],
                )),

                const SizedBox(height: 32),

                Text(
                  "Precipitação",
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 16),

                Obx(() => Column(
                  children: [
                    _buildPrecipitacao(
                        "Manhã", "${controller.precipitacaoManha.value}%", Icons.wb_sunny, isDark),
                    _buildPrecipitacao(
                        "Tarde", "${controller.precipitacaoTarde.value}%", Icons.cloud, isDark),
                    _buildPrecipitacao(
                        "Noite", "${controller.precipitacaoNoite.value}%", Icons.nights_stay, isDark),
                  ],
                )),
              ],
            ),
          ),
        ),
      );
    });
  }
}
