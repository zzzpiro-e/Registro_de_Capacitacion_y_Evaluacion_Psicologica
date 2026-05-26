import 'package:flutter/material.dart';
import 'package:proyecto_flutter/app/screens/psicologo_dashboard_screen.dart';
import 'package:proyecto_flutter/app/screens/psicologo_derivaciones_screen.dart';
import 'package:proyecto_flutter/app/widgets/custom_psicologo_bottom_nav_bar.dart';

class PsicologoMainScreen extends StatefulWidget {
  const PsicologoMainScreen({super.key});

  @override
  State<PsicologoMainScreen> createState() => _PsicologoMainScreenState();
}

class _PsicologoMainScreenState extends State<PsicologoMainScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      const PsicologoDashboardScreen(), // Posición 0: Inicio
      const PsicologoDerivacionesScreen(), // Posición 1: Derivaciones
      const Center(child: Text('Historial de Informes')), // Posición 2: Historial (Próxima tarea)
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
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