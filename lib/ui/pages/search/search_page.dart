import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'city_search_controller.dart';

class SearchPage extends GetView<CitySearchController> {
  const SearchPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar cidade'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: controller.citySearchController,
              onChanged: controller.search,
              decoration: const InputDecoration(
                hintText: 'Digite o nome da cidade',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: Obx(
                  () => controller.isLoading.value
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                itemCount: controller.searchResults.length,
                itemBuilder: (context, index) {
                  final city = controller.searchResults[index];
                  return ListTile(
                    title: Text(city.name),
                    subtitle: Text('${city.state ?? ''} - ${city.country ?? ''}'),
                    onTap: () => controller.selectCity(city),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
