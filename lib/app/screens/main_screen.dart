import 'package:flutter/material.dart';
import 'package:proyecto_flutter/app/screens/dashboard_screen.dart';
import 'package:proyecto_flutter/app/screens/lista_empleados_screen.dart';
import 'package:proyecto_flutter/app/widgets/custom_bottom_nav_bar.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // Esta variable guardará cuál pestaña está activa
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    // 🔹 Definimos la lista aquí adentro para poder pasarle el setState dinámico al hijo
    final List<Widget> _screens = [
      const DashboardPage(), // Posición 0: Inicio
      ListaEmpleadosPage(
        onReturnToDashboard: () {
          setState(() {
            _currentIndex = 0; // 🔹 Cambia automáticamente a la pestaña de Inicio
          });
        },
      ), // Posición 1: Empleados
      const Center(child: Text('Capacitaciones')), // Posición 2
      const Center(child: Text('Crear')),          // Posición 3
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}