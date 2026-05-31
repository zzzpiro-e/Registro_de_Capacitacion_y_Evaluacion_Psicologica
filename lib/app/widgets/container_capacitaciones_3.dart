import 'package:flutter/material.dart';

class ContainerCapacitacionesTres extends StatelessWidget {
  final List<Map<String, dynamic>> capacitaciones;

  const ContainerCapacitacionesTres({super.key, required this.capacitaciones});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: capacitaciones.length,
      itemBuilder: (context, index) {
        final cap = capacitaciones[index];

        final titulo = cap['titulo'] ?? 'Sin título';
        final institucion = cap['institucion'] ?? 'Sin institución';
        final fecha = cap['fechaInicio'] ?? 'Sin fecha';
        final estado = cap['estado'] ?? 'pendiente';

        final esRealizada = estado.toLowerCase() == 'realizada';
        final colorEtiqueta = esRealizada ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0);
        final colorTexto = esRealizada ? const Color(0xFF2E7D32) : const Color(0xFFFF9800);

        return InkWell(
          onTap: () {
            Navigator.pushNamed(
              context,
              'detalle_capacitacion',
              arguments: cap,
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
                // Ícono
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: const Icon(Icons.school, color: Color(0xFF2E7D32), size: 28),
                ),
                const SizedBox(width: 16),

                // Datos principales
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(titulo,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)),
                      const SizedBox(height: 4),
                      Text(institucion,
                          style: const TextStyle(fontSize: 14, color: Colors.black54)),
                      const SizedBox(height: 4),
                      Text(fecha,
                          style: const TextStyle(fontSize: 13, color: Colors.black45)),
                    ],
                  ),
                ),

                // Estado
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: colorEtiqueta,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    esRealizada ? 'Realizada' : 'Pendiente',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: colorTexto,
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
