import 'package:flutter/material.dart';
import 'package:proyecto_flutter/app/screens/dashboard_screen.dart';
import 'package:proyecto_flutter/app/screens/lista_empleados_screen.dart';
import 'package:proyecto_flutter/app/widgets/custom_bottom_nav_bar.dart';
import 'package:proyecto_flutter/app/widgets/container_crear_empleado_1.dart';
import 'package:proyecto_flutter/app/widgets/container_crear_empleado_2.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> _screens = [
      const DashboardPage(), // 0: Inicio
      ListaEmpleadosPage(
        onReturnToDashboard: () {
          setState(() {
            _currentIndex = 0;
          });
        },
      ), // 1: Empleados
      const Center(child: Text('Capacitaciones')), // 2: Capacitaciones
      // 3: Crear Empleado (antes estaba en crear_empleado_screen.dart)
      Scaffold(
        backgroundColor: const Color(0xFFF4F4F4),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 80),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: const [
                ContainerCrearEmpleadoUno(),
                SizedBox(height: 16),
                ContainerCrearEmpleadoDos(),
              ],
            ),
          ),
        ),
      ),
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
