import 'package:flutter/material.dart';
import 'package:proyecto_flutter/app/widgets/widgets_perfil_empleado.dart';
import 'package:proyecto_flutter/app/widgets/custom_bottom_nav_bar.dart';

class PerfilEmpleadoScreen extends StatelessWidget {
  const PerfilEmpleadoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 🔹 Recibir el ID del empleado enviado desde la lista
    final empleadoId = ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 80),
          child: Column(
            children: [
              const ContainerPerfilEmpleadoUno(),
              const SizedBox(height: 16),

              // 🔹 Datos personales y laborales desde Firestore
              ContainerPerfilEmpleadoDos(empleadoId: empleadoId),

              const SizedBox(height: 16),

              // 🔹 Perfil Psicológico debajo del recuadro de datos
              ContainerPerfilEmpleadoTres(empleadoId: empleadoId),
            ],
          ),
        ),
      ),

      // 🔹 Aquí va tu barra de navegación personalizada
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 1, // índice que corresponde a "Empleados"
        onTap: (index) {
          // lógica de navegación según el índice
          if (index == 0) {
            Navigator.pushNamed(context, '/dashboard');
          } else if (index == 1) {
            // ya estás en empleados, puedes dejarlo vacío
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
