import 'package:flutter/material.dart';
import 'package:proyecto_flutter/app/widgets/widgets_perfil_empleado.dart';
import 'package:proyecto_flutter/app/widgets/custom_bottom_nav_bar.dart';

class PerfilEmpleadoScreen extends StatelessWidget {
  const PerfilEmpleadoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Recibir el ID del empleado enviado desde la lista
    final args = ModalRoute.of(context)!.settings.arguments;
    if (args == null || args is! String) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, 'main');
      });
      return const Scaffold(
        backgroundColor: Color(0xFFF4F4F4),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    final String empleadoId = args;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 80),
          child: Column(
            children: [
              const ContainerPerfilEmpleadoUno(),

              const SizedBox(height: 16),

              // Datos personales y laborales
              ContainerPerfilEmpleadoDos(empleadoId: empleadoId),

              const SizedBox(height: 16),

              // Perfil psicológico
              ContainerPerfilEmpleadoTres(empleadoId: empleadoId),

              const SizedBox(height: 16),

              // Historial de capacitaciones
              ContainerPerfilEmpleadoCuatro(empleadoId: empleadoId),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),

      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushNamed(context, '/dashboard');
          } else if (index == 1) {
            // Ya estamos en empleados
          } else if (index == 2) {
            Navigator.pushNamed(context, '/crear');
          } else if (index == 3) {
            Navigator.pushNamed(context, '/capacitaciones');
          } else if (index == 4) {
            Navigator.pushNamed(context, '/perfil');
          }
        },
      ),
    );
  }
}
