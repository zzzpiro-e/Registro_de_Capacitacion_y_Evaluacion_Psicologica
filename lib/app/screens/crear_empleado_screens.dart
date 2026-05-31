import 'package:flutter/material.dart';
import 'package:proyecto_flutter/app/widgets/widgets_crear_empleado.dart';

class CrearEmpleadoScreen extends StatelessWidget {
  const CrearEmpleadoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: const [
              // 🔹 Encabezado con flecha atrás y título
              ContainerCrearEmpleadoUno(),

              SizedBox(height: 16),

              // 🔹 Formulario para crear empleado
              ContainerCrearEmpleadoDos(),
            ],
          ),
        ),
      ),
    );
  }
}
