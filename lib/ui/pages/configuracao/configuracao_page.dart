import 'package:atmus/viewmodels/configuracao/configuracao_viewmodel.dart';
import 'package:atmus/viewmodels/home/home_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ConfiguracaoPage extends StatefulWidget {
  const ConfiguracaoPage({Key? key}) : super(key: key);

  @override
  State<ConfiguracaoPage> createState() => _ConfiguracaoPageState();
}

class _ConfiguracaoPageState extends State<ConfiguracaoPage> {
  final HomeViewModel homeController = Get.find<HomeViewModel>();
  final ThemeController themeController = Get.find<ThemeController>();

  String notificacoes = "Permitir";
  String localizacao = "Permitir";

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDark = themeController.themeMode.value == ThemeMode.dark;
      final bgColor = isDark ? const Color(0xFF0D1B2A) : Colors.white;
      final textColor = isDark ? Colors.white : Colors.black;
      final subTextColor = isDark ? Colors.grey[300]! : Colors.grey[700]!;
      final borderColor = isDark ? Colors.grey.shade800 : Colors.grey.shade400;

      return Scaffold(
        backgroundColor: bgColor,
        body: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: textColor),
                      onPressed: () => Get.back(),
                    ),
                    Text(
                      "Configuração",
                      style: TextStyle(
                        color: textColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.menu, color: textColor),
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
                      const SizedBox(height: 24),

                      // Unidades
                      Text(
                        "Unidades",
                        style: TextStyle(
                          color: textColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Obx(() => RadioListTile<String>(
                        title: Text("Celsius", style: TextStyle(color: textColor)),
                        value: "Celsius",
                        groupValue: homeController.unidade.value,
                        onChanged: (value) => homeController.unidade.value = value!,
                        activeColor: Colors.blue,
                      )),
                      Obx(() => RadioListTile<String>(
                        title: Text("Fahrenheit", style: TextStyle(color: textColor)),
                        value: "Fahrenheit",
                        groupValue: homeController.unidade.value,
                        onChanged: (value) => homeController.unidade.value = value!,
                        activeColor: Colors.blue,
                      )),

                      const SizedBox(height: 24),

                      // Modo de exibição
                      Text(
                        "Modo de exibição",
                        style: TextStyle(
                          color: textColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Obx(() => RadioListTile<ThemeMode>(
                        title: Text("Claro", style: TextStyle(color: textColor)),
                        value: ThemeMode.light,
                        groupValue: themeController.themeMode.value,
                        onChanged: (value) => themeController.changeTheme(value!),
                        activeColor: Colors.blue,
                      )),
                      Obx(() => RadioListTile<ThemeMode>(
                        title: Text("Escuro", style: TextStyle(color: textColor)),
                        value: ThemeMode.dark,
                        groupValue: themeController.themeMode.value,
                        onChanged: (value) => themeController.changeTheme(value!),
                        activeColor: Colors.blue,
                      )),

                      const SizedBox(height: 24),

                      // Personalização
                      Text(
                        "Personalização",
                        style: TextStyle(
                          color: textColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Noite: 70%",
                        style: TextStyle(color: subTextColor, fontSize: 16),
                      ),

                      const SizedBox(height: 24),

                      // Notificações
                      Text(
                        "Notificações",
                        style: TextStyle(
                          color: textColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1,
                        ),
                      ),
                      RadioListTile<String>(
                        title: Text("Permitir", style: TextStyle(color: textColor)),
                        value: "Permitir",
                        groupValue: notificacoes,
                        onChanged: (value) => setState(() => notificacoes = value!),
                        activeColor: Colors.blue,
                      ),
                      RadioListTile<String>(
                        title: Text("Não permitir", style: TextStyle(color: textColor)),
                        value: "Não permitir",
                        groupValue: notificacoes,
                        onChanged: (value) => setState(() => notificacoes = value!),
                        activeColor: Colors.blue,
                      ),

                      const SizedBox(height: 24),

                      // Local
                      Text(
                        "Local",
                        style: TextStyle(
                          color: textColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1,
                        ),
                      ),
                      RadioListTile<String>(
                        title: Text("Permitir acesso à localização", style: TextStyle(color: textColor)),
                        value: "Permitir",
                        groupValue: localizacao,
                        onChanged: (value) => setState(() => localizacao = value!),
                        activeColor: Colors.blue,
                      ),
                      RadioListTile<String>(
                        title: Text("Não permitir acesso", style: TextStyle(color: textColor)),
                        value: "Não permitir",
                        groupValue: localizacao,
                        onChanged: (value) => setState(() => localizacao = value!),
                        activeColor: Colors.blue,
                      ),

                      const SizedBox(height: 24),
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
