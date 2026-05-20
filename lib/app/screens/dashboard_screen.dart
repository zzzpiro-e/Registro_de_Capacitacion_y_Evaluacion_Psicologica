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
        currentIndex: 0, // 🔹 índice de la pantalla actual
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushNamed(context, 'dashboard'); // Inicio
              break;
            case 1:
              Navigator.pushNamed(context, 'empleados'); // Empleados
              break;
            case 2:
              Navigator.pushNamed(context, 'capacitaciones'); // Capacitaciones
              break;
            case 3:
              Navigator.pushNamed(context, 'crear'); // Crear
              break;
          }
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
