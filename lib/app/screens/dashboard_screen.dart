import 'package:flutter/material.dart';
import 'package:proyecto_flutter/app/widgets/widgets_dashboard.dart';
import 'package:proyecto_flutter/app/widgets/custom_bottom_nav_bar.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),

      // --- Barra inferior personalizada (única) ---
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 0,
        onTap: (index) {
          // 🔹 Aquí puedes agregar navegación entre secciones
        },
      ),

      // --- Contenido principal con scroll ---
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 80), // espacio para la barra inferior
          child: Column(
            children: const [
              ContainerDashboardUno(),   // Encabezado con fecha y saludo
              SizedBox(height: 16),
              ContainerDashboardDos(),   // Tarjetas de estadísticas
              SizedBox(height: 16),
              ContainerDashboardTres(),  // Accesos rápidos
            ],
          ),
        ),
      ),
    );
  }
}
