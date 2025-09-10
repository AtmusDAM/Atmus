import 'package:atmus/ui/pages/configuracao/configuracao_page.dart';
import 'package:atmus/ui/widgets/mapa_widget_page.dart';
import 'package:atmus/viewmodels/configuracao/configuracao_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:atmus/viewmodels/home/home_viewmodel.dart';

class HomePageContent extends StatelessWidget {
  HomePageContent({super.key});

  final HomeViewModel controller = Get.find<HomeViewModel>();
  final ThemeController themeController = Get.find<ThemeController>();

  Widget _getWeatherIcon(String icon, bool isDark) {
    if (icon.isEmpty) {
      return Icon(Icons.cloud, color: isDark ? Colors.white : Colors.black, size: 48);
    }
    final isUrl = icon.startsWith('http');
    final url = isUrl ? icon : 'https://openweathermap.org/img/wn/$icon@2x.png';
    return Image.network(
      url,
      width: 50,
      height: 50,
      errorBuilder: (_, __, ___) =>
          Icon(Icons.cloud, color: isDark ? Colors.white : Colors.black, size: 48),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDark = themeController.themeMode.value == ThemeMode.dark;
      final bgColor = isDark ? const Color(0xFF0D1B2A) : Colors.white;
      final containerColor = isDark ? const Color(0xFF1B263B) : Colors.grey[200]!;
      final textColor = isDark ? Colors.white : Colors.black;
      final subTextColor = isDark ? Colors.grey[300]! : Colors.grey[700]!;
      final borderColor = isDark ? Colors.grey.shade800 : Colors.grey.shade400;

      return Scaffold(
        backgroundColor: bgColor,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 24, bottom: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Icons.settings, color: textColor),
                      onPressed: () {
                        Get.to(() => const ConfiguracaoPage());
                      },
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Obx(() {
                            final nomeCidade = controller.cityName.value;
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.location_on, color: textColor),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    nomeCidade.isEmpty ? 'Carregando...' : nomeCidade,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(color: textColor),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            );
                          }),
                          const SizedBox(height: 8),
                          Obx(
                                () => FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                "${controller.displayTemp(controller.temperaturaAtual.value).toStringAsFixed(0)} ${controller.unidadeSimbolo}",
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Obx(
                                () => Text(
                              controller.descricaoTempo.value,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: subTextColor),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.menu, color: textColor),
                      onPressed: () {
                        Scaffold.of(context).openDrawer();
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Container principal
                Container(
                  decoration: BoxDecoration(
                    color: containerColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor, width: 1),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Agora", style: TextStyle(color: textColor)),
                              const SizedBox(height: 4),
                              Text(
                                "Atualizado há 5min",
                                style: TextStyle(color: subTextColor, fontSize: 12),
                              ),
                            ],
                          ),
                          Obx(() => _getWeatherIcon(controller.weatherIcon.value, isDark)),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Máxima", style: TextStyle(color: subTextColor, fontSize: 12)),
                              const SizedBox(height: 4),
                              Obx(() => Text(
                                "${controller.displayTemp(controller.temperaturaMax.value).toStringAsFixed(1)} ${controller.unidadeSimbolo}",
                                style: TextStyle(color: textColor, fontSize: 16),
                              )),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Mínima", style: TextStyle(color: subTextColor, fontSize: 12)),
                              const SizedBox(height: 4),
                              Obx(() => Text(
                                "${controller.displayTemp(controller.temperaturaMin.value).toStringAsFixed(1)} ${controller.unidadeSimbolo}",
                                style: TextStyle(color: textColor, fontSize: 16),
                              )),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Sensação e precipitação
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: containerColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: borderColor, width: 1),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.wb_sunny, color: textColor),
                            const SizedBox(height: 8),
                            Text("Sensação", style: TextStyle(color: subTextColor, fontSize: 12)),
                            Obx(() => Text(
                              "${controller.displayTemp(controller.sensacaoSol.value).toStringAsFixed(1)} ${controller.unidadeSimbolo}",
                              style: TextStyle(color: textColor),
                            )),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(left: 8),
                        decoration: BoxDecoration(
                          color: containerColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: borderColor, width: 1),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.water_drop, color: textColor),
                            const SizedBox(height: 8),
                            Text("Precipitação", style: TextStyle(color: subTextColor, fontSize: 12)),
                            Obx(() => Text(
                              "${controller.sensacaoChuva.value.toStringAsFixed(1)} mm",
                              style: TextStyle(color: textColor),
                            )),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Mapa
                SizedBox(
                  height: 350,
                  width: double.infinity,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: MiniMapaWidget(),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
