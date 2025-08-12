import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ConfiguracaoPage extends StatelessWidget {
  ConfiguracaoPage({Key? key}) : super(key: key);

  Widget _buildCard(String title, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF1B263B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade800, width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white),
        ],
      ),
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
              // Cabeçalho com setinha, texto Recife e menu
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Get.back(),
                  ),
                  const Text(
                    "Recife",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.menu, color: Colors.white),
                    onPressed: () {},
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Título principal
              const Text(
                "Configuração",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),

              const SizedBox(height: 24),

              // Seção Unidades
              _buildCard("Unidades", () {
                // Ação ao tocar
              }),

              // Seção Modo de exibição
              _buildCard("Modo de exibição", () {
                // Ação ao tocar
              }),

              const SizedBox(height: 24),

              // Personalização
              const Text(
                "Personalização",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                ),
              ),

              const SizedBox(height: 16),

              _buildCard("Noite: 70%", () {
                // Ação ao tocar
              }),

              const SizedBox(height: 24),

              // Notificações
              const Text(
                "Notificações",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                ),
              ),

              const SizedBox(height: 16),

              _buildCard("Gerenciar as notificações", () {
                // Ação ao tocar
              }),

              const SizedBox(height: 24),

              // Local
              const Text(
                "Local",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                ),
              ),

              const SizedBox(height: 16),

              _buildCard("Acesso à localização", () {
                // Ação ao tocar
              }),

              _buildCard("Local padrão", () {
                // Ação ao tocar
              }),
            ],
          ),
        ),
      ),
    );
  }
}
