import 'package:flutter/material.dart';
import 'package:proyecto_flutter/app/widgets/widgets_dashboard.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Ya no lleva Scaffold aquí, porque el Scaffold principal con el fondo y la barra está en MainScreen
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 20), // Bajamos el padding ya que la barra no empuja tanto
        child: Column(
          children: const [
            ContainerDashboardUno(), // Encabezado con fecha y saludo
            SizedBox(height: 16),
            ContainerDashboardDos(), // Tarjetas de estadísticas
            SizedBox(height: 16), // Accesos rápidos
          ],
        ),
      ),
    );
  }
}
