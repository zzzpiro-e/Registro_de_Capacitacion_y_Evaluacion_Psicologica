import 'package:flutter/material.dart';
import 'package:proyecto_flutter/app/screens/psicologo_dashboard_screen.dart';
import 'package:proyecto_flutter/app/screens/psicologo_derivaciones_screen.dart';
import 'package:proyecto_flutter/app/screens/psicologo_historial_screen.dart';
import 'package:proyecto_flutter/app/widgets/custom_psicologo_bottom_nav_bar.dart';
import 'package:proyecto_flutter/app/widgets/container_perfil_psicologo_1.dart';
import 'package:proyecto_flutter/app/widgets/container_perfil_psicologo_2.dart';
import 'package:proyecto_flutter/app/widgets/container_perfil_psicologo_3.dart';
import 'package:proyecto_flutter/app/widgets/container_perfil_psicologo_4.dart';

class PsicologoMainScreen extends StatefulWidget {
  const PsicologoMainScreen({super.key});

  @override
  State<PsicologoMainScreen> createState() => _PsicologoMainScreenState();
}

class _PsicologoMainScreenState extends State<PsicologoMainScreen> {
  // Control del índice de la pestaña activa en la barra de navegación
  int _currentIndex = 0;

  // 1. Agregamos un trigger para forzar el refresco del Dashboard
  int _dashboardRefreshTrigger = 0;

  @override
  Widget build(BuildContext context) {
    // Definición de las pantallas correspondientes a cada menú indexado
    final List<Widget> screens = [
      // 2. Le pasamos una Key única que cambia cada vez que el usuario navega.
      // Al cambiar la Key, Flutter se ve obligado a recrear el widget y leer los contadores actualizados.
      PsicologoDashboardScreen(key: ValueKey('dashboard_$_dashboardRefreshTrigger')), 
      const PsicologoDerivacionesScreen(), 
      const PsicologoHistorialScreen(),    
      
      // Vista de perfil estructurada con contenedores independientes
      SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          child: Column(
            children: const [
              ContainerPerfilPsicologoUno(),
              SizedBox(height: 16),
              ContainerPerfilPsicologoDos(),
              SizedBox(height: 16),
              ContainerPerfilPsicologoTres(),
              SizedBox(height: 24),
              ContainerPerfilPsicologoCuatro(),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: _currentIndex == 2 || _currentIndex == 3
          ? AppBar(
              title: Text(
                _currentIndex == 2 ? 'Historial de Informes' : 'Mi Perfil',
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              backgroundColor: Colors.white,
              elevation: 0,
              centerTitle: false,
            )
          : null,
      // Persistencia del estado de los componentes mediante IndexedStack
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: CustomPsicologoBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            // 3. Cada vez que el usuario cambie de pestaña o vuelva al inicio,
            // incrementamos el trigger para forzar al Dashboard a recalcular sus datos en tiempo real.
            _dashboardRefreshTrigger++; 
          });
        },
      ),
    );
  }
}