// lib/ui/pages/historico/historico_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../viewmodels/historico/historico_viewmodel.dart';

class HistoricoPage extends StatelessWidget {
  final double lat;
  final double lon;
  final String? titulo;

  const HistoricoPage({
    super.key,
    required this.lat,
    required this.lon,
    this.titulo,
  });

  String _fmt(double? v) {
    if (v == null || v.isNaN || v.isInfinite) return '—';
    return '${v.toStringAsFixed(1)}°C';
  }

  @override
  Widget build(BuildContext context) {
    final tag = 'historico_${lat}_$lon';
    final vm = Get.put(HistoricoViewModel(), tag: tag);

    Future.microtask(() {
      if (vm.histories.isEmpty && !vm.isLoading.value) {
        vm.loadPast5Days(lat: lat, lon: lon);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(titulo ?? 'Histórico (últimos 5 dias)'),
      ),
      body: Obx(() {
        if (vm.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (vm.error.value != null) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Text('Erro: ${vm.error.value}'),
            ),
          );
        }
        if (vm.histories.isEmpty) {
          return const Center(child: Text('Nenhum dado de histórico.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: vm.histories.length,
          itemBuilder: (context, i) {
            final day = vm.histories[i];
            final date = day.dayUtc;

            final samples = [
              if (day.hours.isNotEmpty)
                day.hours[(day.hours.length * 0.25).floor()],
              if (day.hours.length > 2)
                day.hours[(day.hours.length * 0.5).floor()],
              if (day.hours.length > 3)
                day.hours[(day.hours.length * 0.75).floor()],
            ];

            return Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Mín: ${_fmt(day.minTemp)}   '
                          'Máx: ${_fmt(day.maxTemp)}   '
                          'Média: ${_fmt(day.avgTemp)}',
                    ),
                    if (day.hours.isEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Sem horas disponíveis para este dia (limite de 5 dias passados / janela UTC).',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                    const SizedBox(height: 8),
                    if (samples.isNotEmpty)
                      Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        children: samples.map((h) {
                          final hh = h.dateTime.toLocal().hour.toString().padLeft(2, '0');
                          final main = (h.weatherMain ?? '').trim();
                          final tStr = _fmt(h.temp);
                          final label = [
                            '$hh:00',
                            if (main.isNotEmpty) main,
                            tStr,
                          ].join('  ');
                          return Chip(label: Text(label));
                        }).toList(),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.cloud_download),
        label: const Text('Atualizar'),
        onPressed: () => vm.loadPast5Days(lat: lat, lon: lon),
      ),
    );
  }
}
