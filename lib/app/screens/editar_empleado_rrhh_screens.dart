import 'package:flutter/material.dart';
import 'package:proyecto_flutter/app/widgets/widgets_editar_empleado.dart';

class EditarEmpleadoRRHHScreen extends StatelessWidget {
  final String empleadoId;

  const EditarEmpleadoRRHHScreen({super.key, required this.empleadoId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // 🔹 Encabezado con título y flecha atrás (no necesita empleadoId)
              const ContainerEditarEmpleadoUno(),

              const SizedBox(height: 20),

              // 🔹 Formulario principal con empleadoId
              ContainerEditarEmpleadoDos(empleadoId: empleadoId),
            ],
          ),
        ),
      ),
    );
  }
}
