import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:atmus/viewmodels/home/home_viewmodel.dart';
import 'package:atmus/viewmodels/previsao/previsao_viewmodel.dart';
import 'package:atmus/viewmodels/configuracao/configuracao_viewmodel.dart';
import 'package:intl/intl.dart';

class PrevisaoPage extends StatelessWidget {
  const PrevisaoPage({super.key});

  Widget _getWeatherIcon(String icon, bool isDark) {
    if (icon.isEmpty) {
      return Icon(Icons.wb_sunny, color: isDark ? Colors.yellow : Colors.orange, size: 22);
    }
    final isUrl = icon.startsWith('http');
    final url = isUrl ? icon : 'https://openweathermap.org/img/wn/$icon@2x.png';
    return Image.network(
      url,
      width: 22,
      height: 22,
      errorBuilder: (context, error, stackTrace) =>
          Icon(Icons.wb_sunny, color: isDark ? Colors.yellow : Colors.orange, size: 22),
    );
  }

  Widget _buildHoraItem(String hora, double temp, String iconCode, HomeViewModel home, bool isDark) {
    final displayTemp = home.displayTemp(temp).round();
    final symbol = home.unidadeSimbolo;

    return SizedBox(
      width: 60,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(hora,
              style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontSize: 11),
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          _getWeatherIcon(iconCode, isDark),
          const SizedBox(height: 4),
          Text("$displayTemp$symbol",
              style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildDiaItem(String dia, List<double> tempMinMax, HomeViewModel home, bool isDark) {
    final min = home.displayTemp(tempMinMax[0]).round();
    final max = home.displayTemp(tempMinMax[1]).round();
    final symbol = home.unidadeSimbolo;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(dia, style: TextStyle(color: isDark ? Colors.white : Colors.black)),
          Row(
            children: [
              Text("$min$symbol", style: TextStyle(color: isDark ? Colors.grey : Colors.grey[700])),
              const SizedBox(width: 8),
              Text("$max$symbol",
                  style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _card({required Widget child, required bool isDark}) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1B263B) : Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.grey.shade400, width: 1),
      ),
      padding: const EdgeInsets.all(16),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final home = Get.find<HomeViewModel>();
    final controller = Get.put(PrevisaoViewModel(), permanent: false);
    final themeController = Get.find<ThemeController>();

    return Obx(() {
      final isDark = themeController.themeMode.value == ThemeMode.dark;
      final bgColor = isDark ? const Color(0xFF0D1B2A) : Colors.white;

      return SafeArea(
        child: Container(
          color: bgColor,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
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
                                    color: isDark ? Colors.white : Colors.black, fontSize: 18),
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
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Previsão do tempo",
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 12),

                      _card(
                        isDark: isDark,
                        child: Obx(() {
                          if (controller.isLoading.value) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }
                          if (controller.error.value != null) {
                            return Text(
                              controller.error.value!,
                              style: const TextStyle(color: Colors.redAccent),
                            );
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                controller.resumo.value,
                                style: TextStyle(
                                    color: isDark ? Colors.white70 : Colors.black54, fontSize: 14),
                              ),
                              const SizedBox(height: 24),
                              SizedBox(
                                height: 85,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: controller.temperaturasHora.length,
                                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                                  itemBuilder: (_, index) {
                                    final hora = controller.temperaturasHora.keys.elementAt(index);
                                    final temp = controller.temperaturasHora[hora]!.toDouble();
                                    final iconCode = controller.iconesHora[hora] ?? '';
                                    return _buildHoraItem(hora, temp, iconCode, home, isDark);
                                  },
                                ),
                              ),
                            ],
                          );
                        }),
                      ),

                      const SizedBox(height: 24),

                      _card(
                        isDark: isDark,
                        child: Obx(() {
                          if (controller.isLoading.value && controller.temperaturas.isEmpty) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: controller.temperaturas.entries.map((e) {
                              final minMax = e.value.map((v) => v.toDouble()).toList();
                              return _buildDiaItem(e.key, minMax, home, isDark);
                            }).toList(),
                          );
                        }),
                      ),

                      const SizedBox(height: 24),

                      // Card 3: alertas climáticos
                      _card(
                        isDark: isDark,
                        child: Obx(() {
                          if (controller.isLoading.value && controller.alerts.isEmpty) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }

                          if (controller.alerts.isEmpty) {
                            return Row(
                              children: [
                                Icon(Icons.check_circle, color: Colors.green, size: 22),
                                const SizedBox(width: 8),
                                Text("Nenhum alerta climático no momento",
                                    style: TextStyle(
                                        color: isDark ? Colors.white70 : Colors.black87,
                                        fontSize: 14)),
                              ],
                            );
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: controller.alerts.map((alert) {
                              final start =
                              DateTime.fromMillisecondsSinceEpoch(alert['start'] * 1000);
                              final end =
                              DateTime.fromMillisecondsSinceEpoch(alert['end'] * 1000);

                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 6),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.warning, color: Colors.redAccent, size: 22),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            alert['event'] ?? 'Alerta climático',
                                            style: TextStyle(
                                                color: isDark ? Colors.white : Colors.black,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(alert['description'] ?? '',
                                        style: TextStyle(
                                            color: isDark ? Colors.white70 : Colors.black87,
                                            fontSize: 13)),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Válido de ${DateFormat('dd/MM HH:mm').format(start)} até ${DateFormat('dd/MM HH:mm').format(end)}",
                                      style: TextStyle(
                                          color: Colors.orangeAccent, fontSize: 12),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          );
                        }),
                      ),

                      const SizedBox(height: 23),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
