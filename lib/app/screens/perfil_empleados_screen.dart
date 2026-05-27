import 'package:flutter/material.dart';
import 'package:proyecto_flutter/app/widgets/widgets_perfil_empleado.dart';

class PerfilEmpleadoScreen extends StatelessWidget {
  const PerfilEmpleadoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 🔹 Recibir los argumentos de forma segura (añadimos el '?' para evitar el null crash)
    final args = ModalRoute.of(context)?.settings.arguments;
    
    // 🔹 Si viene un empleado de la lista lo usa, si no, usa un mapa por defecto para pruebas
    final Map<String, dynamic> empleado = (args != null && args is Map<String, dynamic>)
        ? args
        : {
            'nombre': 'Ficha de Prueba (Psicólogo)',
            'rut': '12.345.678-K',
            'edad': '30',
            'cargo': 'Operario',
            'fechaIngreso': '26-05-2026',
            'salario': '\$1.100.000',
            'fichaPsicologica': 'Seleccione un empleado real desde la lista para ver su informe.',
            'capacitaciones': <Map<String, dynamic>>[] // Lista vacía segura
          };

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

              // 🔹 Datos personales y laborales dinámicos seguros
              ContainerPerfilEmpleadoDos(
                nombre: empleado['nombre'] ?? empleado['nombres'] ?? 'Sin nombre', // 👈 Mapea 'nombre' o 'nombres' de tu Firestore
                rut: empleado['rut'] ?? 'Sin RUT',
                edad: empleado['edad'] ?? 'Sin edad',
                cargo: empleado['cargo'] ?? 'Sin cargo',
                fechaIngreso: empleado['fechaIngreso'] ?? 'Sin fecha',
                salario: empleado['salario'] ?? 'Sin salario',
                fichaPsicologica: empleado['fichaPsicologica'] ?? 'Sin ficha',
              ),

              const SizedBox(height: 16),

              // 🔹 Historial de capacitaciones dinámico seguro
              ContainerPerfilEmpleadoTres(
                capacitaciones: (empleado['capacitaciones'] is List)
                    ? List<Map<String, dynamic>>.from(empleado['capacitaciones'])
                    : [],
              ),
            ],
          ),
        ),
      ),
    );
  }
}