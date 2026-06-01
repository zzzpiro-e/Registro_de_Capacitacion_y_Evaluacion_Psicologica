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

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const DashboardPage(), // 0: Inicio
      ListaEmpleadosPage(
        onReturnToDashboard: () => setState(() => _currentIndex = 0),
      ), // 1: Empleados
      const SizedBox.shrink(), // 2: Crear (placeholder invisible)
      CapacitacionesPage(
        onReturnToDashboard: () => setState(() => _currentIndex = 0),
      ), // 3: Capacitaciones
      const PerfilRRHHScreen(), // 4: Perfil
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      body: Stack(
        children: [
          IndexedStack(index: _currentIndex, children: _screens),

          // Fondo semitransparente para cerrar burbujas al tocar fuera
          if (_showBurbujas)
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () => setState(() => _showBurbujas = false),
                child: Container(color: Colors.black.withOpacity(0.05)),
              ),
            ),

          // Burbujas flotantes
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
          if (index == 2) {
            // Alternar burbujas de creación
            setState(() => _showBurbujas = !_showBurbujas);
          } else {
            // Cambiar pestaña y cerrar burbujas
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