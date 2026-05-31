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

  // 🔹 Declaramos la lista de pantallas como una variable de estado
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    // 🔹 Inicializamos las pantallas una sola vez al cargar el widget
    _screens = [
      const DashboardPage(), // 0: Inicio
      ListaEmpleadosPage(
        onReturnToDashboard: () => setState(() => _currentIndex = 0),
      ), // 1: Empleados
      const SizedBox(), // 2: Crear (Espacio vacío/fantasma manejado por burbujas)
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
          // 🔹 IndexedStack ahora sí conservará el estado real de tus vistas
          IndexedStack(index: _currentIndex, children: _screens),

          // 🔹 Capa interactiva para cerrar las burbujas si el usuario toca fuera de ellas
          if (_showBurbujas)
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () => setState(() => _showBurbujas = false),
                child: Container(
                  color: Colors.black.withOpacity(
                    0.05,
                  ), // Un sutil oscurecimiento opcional
                ),
              ),
            ),

          // 🔹 Burbujas flotantes
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
            // Alternar visibilidad de las burbujas de creación
            setState(() => _showBurbujas = !_showBurbujas);
          } else {
            // Cambiar de pestaña y asegurarse de cerrar las burbujas
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
