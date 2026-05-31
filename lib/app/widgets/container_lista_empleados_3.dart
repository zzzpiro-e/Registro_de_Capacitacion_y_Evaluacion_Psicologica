import 'package:flutter/material.dart';

class ContainerListaEmpleadosTres extends StatelessWidget {
  final List<Map<String, dynamic>> empleados;

  const ContainerListaEmpleadosTres({super.key, required this.empleados});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: empleados.length,
      itemBuilder: (context, index) {
        final empleado = empleados[index];

        final nombres = empleado['nombres'] ?? '';
        final apellidos = empleado['apellidos'] ?? '';
        final rut = empleado['rut'] ?? 'Sin RUT';

        return InkWell(
          onTap: () {
            Navigator.pushNamed(
              context,
              'perfil_empleado',
              arguments: empleado['id'], // ✅ ahora pasamos solo el ID
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

                // Nombre completo y RUT
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "$nombres $apellidos".trim().isEmpty
                            ? "Sin nombre"
                            : "$nombres $apellidos",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        rut,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ],
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
