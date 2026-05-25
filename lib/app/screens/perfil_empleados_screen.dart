import 'package:flutter/material.dart';
import 'package:proyecto_flutter/app/widgets/widgets_perfil_empleado.dart';

class PerfilEmpleadoScreen extends StatelessWidget {
  const PerfilEmpleadoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 🔹 Recibir los argumentos enviados desde la lista
    final empleado = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      bottomNavigationBar: const ContainerPerfilEmpleadoCuatro(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 80),
          child: Column(
            children: [
              const ContainerPerfilEmpleadoUno(),
              const SizedBox(height: 16),

              // 🔹 Datos personales y laborales dinámicos
              ContainerPerfilEmpleadoDos(
                nombre: empleado['nombre'] ?? 'Sin nombre',
                rut: empleado['rut'] ?? 'Sin RUT',
                edad: empleado['edad'] ?? 'Sin edad',
                cargo: empleado['cargo'] ?? 'Sin cargo',
                fechaIngreso: empleado['fechaIngreso'] ?? 'Sin fecha',
                salario: empleado['salario'] ?? 'Sin salario',
                fichaPsicologica: empleado['fichaPsicologica'] ?? 'Sin ficha',
              ),

              const SizedBox(height: 16),

              // 🔹 Historial de capacitaciones dinámico
              ContainerPerfilEmpleadoTres(
                capacitaciones: (empleado['capacitaciones'] as List<Map<String, dynamic>>?)?? [],
              ),
            ],
          ),
        ),
      ),
    );
  }
}