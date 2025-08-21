import 'package:atmus/ui/pages/home/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'previsao_controller.dart';

class PrevisaoPage extends StatelessWidget {
  PrevisaoPage({Key? key}) : super(key: key);

  final PrevisaoController controller = Get.put(PrevisaoController());

  Widget _buildHoraItem(String hora, int temp) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(hora, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 6),
        const Icon(Icons.wb_sunny, color: Colors.yellow, size: 26),
        const SizedBox(height: 6),
        Text("$temp°",
            style: const TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      ],
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
              Text("${tempMinMax[0]}°", style: const TextStyle(color: Colors.grey)),
              const SizedBox(width: 8),
              Text("${tempMinMax[1]}°",
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1B263B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade800,
          width: 1,
        ),
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
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      final controller = Get.find<HomeController>();
                      controller.selectedIndex.value = 0;
                    },
                  ),
                  const Text("Recife, PE",
                      style: TextStyle(color: Colors.white, fontSize: 18)),
                  IconButton(
                    icon: const Icon(Icons.menu, color: Colors.white),
                    onPressed: () {},
                  ),
                ],
              ),

              const SizedBox(height: 24),

              const Text(
                "Previsão do tempo",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2),
              ),

              const SizedBox(height: 12),

              // Card 1: resumo + previsão hora a hora
              Obx(() => _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      controller.resumo.value,
                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 90,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: controller.temperaturasHora.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 16),
                        itemBuilder: (_, index) {
                          final hora = controller.temperaturasHora.keys.elementAt(index);
                          final temp = controller.temperaturasHora[hora]!;
                          return _buildHoraItem(hora, temp);
                        },
                      ),
                    ),
                  ],
                ),
              )),

              const SizedBox(height: 32),

              // Card 2: previsão dias
              Obx(() => _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: controller.temperaturas.entries
                      .map((e) => _buildDiaItem(e.key, e.value))
                      .toList(),
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }
}
