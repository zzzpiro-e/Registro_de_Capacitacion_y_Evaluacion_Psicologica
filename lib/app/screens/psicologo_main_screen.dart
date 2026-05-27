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

  @override
  Widget build(BuildContext context) {
    // Definición de las pantallas correspondientes a cada menú indexado
    final List<Widget> screens = [
      const PsicologoDashboardScreen(),   // Índice 0: Dashboard principal
      const PsicologoDerivacionesScreen(), // Índice 1: Listado de derivaciones activas
      const PsicologoHistorialScreen(),    // Índice 2: Pantalla de historial con contenedores modulares
      
      // Índice 3: Vista de perfil estructurada con contenedores independientes
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
      // Control centralizado del AppBar superior para las pestañas de Historial (2) y Perfil (3)
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
          });
        },
      ),
    );
  }
}