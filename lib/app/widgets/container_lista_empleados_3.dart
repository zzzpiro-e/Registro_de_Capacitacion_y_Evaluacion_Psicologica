import 'package:flutter/material.dart';

class ContainerListaEmpleadosTres extends StatelessWidget {
  final List<Map<String, dynamic>> empleados;

  const ContainerListaEmpleadosTres({super.key, required this.empleados});

  Color _colorEstado(String? estado) {
    switch (estado?.toLowerCase() ?? '') {
      case 'activo':
        return const Color(0xFFDFFFD6); // Verde claro
      case 'pendiente':
        return const Color(0xFFFFF3CD); // Amarillo claro
      default:
        return Colors.grey.shade200;
    }
  }

  Color _colorTextoEstado(String? estado) {
    switch (estado?.toLowerCase() ?? '') {
      case 'activo':
        return const Color(0xFF2E7D32); // Verde institucional
      case 'pendiente':
        return const Color(0xFFB8860B); // Amarillo oscuro
      default:
        return Colors.black54;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: empleados.length,
      itemBuilder: (context, index) {
        final empleado = empleados[index];

        return InkWell(
          onTap: () {
            print(empleado);
            Navigator.pushNamed(
              context,
              'perfil_empleado',
              arguments: empleado,
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Ícono de empleado
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: const Icon(
                    Icons.person_outline,
                    color: Color(0xFF2E7D32),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),

                // Nombre y RUT
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        empleado['nombre'] ?? 'Sin nombre',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        empleado['rut'] ?? 'Sin RUT',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),

                // Estado
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _colorEstado(empleado['estado']),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    empleado['estado'] ?? 'Sin estado',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: _colorTextoEstado(empleado['estado']),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
