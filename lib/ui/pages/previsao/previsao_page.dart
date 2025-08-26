import 'package:atmus/viewmodels/home/home_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:atmus/viewmodels/previsao/previsao_viewmodel.dart';

class PrevisaoPage extends StatelessWidget {
  PrevisaoPage({Key? key}) : super(key: key);

  final PrevisaoViewModel controller = Get.put(PrevisaoViewModel());

  Widget _getWeatherIcon(String iconCode) {
    if (iconCode.isEmpty) {
      return const Icon(Icons.wb_sunny, color: Colors.yellow, size: 22);
    }
    return Image.network(
      'http://openweathermap.org/img/wn/$iconCode@2x.png',
      width: 22,
      height: 22,
      errorBuilder: (context, error, StackTrace) {
        return const Icon(Icons.wb_sunny, color: Colors.yellow, size: 22);
      },
    );
  }

  Widget _buildHoraItem(String hora, int temp, String iconCode) {
    return Container(
      width: 60,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            hora,
            style: const TextStyle(color: Colors.white70, fontSize: 11),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          _getWeatherIcon(iconCode),
          const SizedBox(height: 4),
          Text(
            "$temp°",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiaItem(String dia, List<int> tempMinMax) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(dia, style: const TextStyle(color: Colors.white)),
          Row(
            children: [
              Text(
                "${tempMinMax[0]}°",
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(width: 8),
              Text(
                "${tempMinMax[1]}°",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1B263B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade800, width: 1),
      ),
      padding: const EdgeInsets.all(16),
      child: child,
    );
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
                  const Flexible(
                    child: Text(
                      "Recife, PE",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                      overflow: TextOverflow.ellipsis,
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Previsão do tempo",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Card 1: resumo + previsão hora a hora
                    _buildCard(
                      child: Obx(
                        () => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              controller.resumo.value,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              height: 85,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: controller.temperaturasHora.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(width: 12),
                                itemBuilder: (_, index) {
                                  final hora = controller.temperaturasHora.keys
                                      .elementAt(index);
                                  final temp =
                                      controller.temperaturasHora[hora]!;
                                  final iconCode =
                                      controller.iconesHora[hora] ?? '';
                                  return _buildHoraItem(hora, temp, iconCode);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Card 2: previsão dias
                    _buildCard(
                      child: Obx(
                        () => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: controller.temperaturas.entries
                              .map((e) => _buildDiaItem(e.key, e.value))
                              .toList(),
                        ),
                      ),
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
  }
}
