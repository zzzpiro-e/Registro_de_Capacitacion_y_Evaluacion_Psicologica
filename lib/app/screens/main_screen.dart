import 'package:flutter/material.dart';
import 'package:proyecto_flutter/app/screens/dashboard_screen.dart';
import 'package:proyecto_flutter/app/screens/lista_empleados_screen.dart';
import 'package:proyecto_flutter/app/screens/capacitaciones_screen.dart';
import 'package:proyecto_flutter/app/widgets/custom_bottom_nav_bar.dart';
import 'package:proyecto_flutter/app/widgets/crear_burbujas.dart';
import 'package:proyecto_flutter/app/screens/perfil_rrhh_screens.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  bool _showBurbujas = false;

  @override
  Widget build(BuildContext context) {
    final List<Widget> _screens = [
      const DashboardPage(),   // 0: Inicio
      ListaEmpleadosPage(onReturnToDashboard: () => setState(() => _currentIndex = 0)), // 1: Empleados
      const SizedBox(),        // 2: Crear (no es pantalla, se maneja con burbujas)
      CapacitacionesPage(onReturnToDashboard: () => setState(() => _currentIndex = 0)), // 3: Capacitaciones
      const PerfilRRHHScreen(), // 4: Perfil
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),
          if (_showBurbujas)
            CrearBurbujas(
              onCrearEmpleado: () {
                setState(() => _showBurbujas = false);
                Navigator.pushNamed(context, 'crear_empleado');
              },
              onCrearCapacitacion: () {
                setState(() => _showBurbujas = false);
                Navigator.pushNamed(context, 'crear_capacitacion');
              },
            ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 2) { // Crear
            setState(() => _showBurbujas = !_showBurbujas);
          } else {
            setState(() {
              _currentIndex = index;
              _showBurbujas = false;
            });
          }
        },
      ),
    );
  }
}
