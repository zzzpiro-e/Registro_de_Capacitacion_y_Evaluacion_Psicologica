import 'package:flutter/material.dart';
import 'package:proyecto_flutter/app/services/detalle_capacitacion_service.dart';

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
        final fecha = cap['fechaInicioFormateada'] ?? 'Sin fecha';
        final estado = (cap['estado'] ?? 'pendiente').toString().toLowerCase();

        final esRealizada = estado == 'realizada';

        final colorEtiqueta = esRealizada
            ? const Color(0xFFE8F5E9)
            : const Color(0xFFFFF3E0);

        final colorTexto = esRealizada
            ? const Color(0xFF2E7D32)
            : Colors.orange;

        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    DetalleCapacitacionPage(capacitacion: cap),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: const Icon(
                    Icons.school,
                    color: Color(0xFF2E7D32),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titulo,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 6),

                      Row(
                        children: [
                          const Icon(
                            Icons.business,
                            size: 16,
                            color: Color(0xFF2E7D32),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              institucion,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF2E7D32),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: Color(0xFF2E7D32),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            fecha,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF2E7D32),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: colorEtiqueta,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        esRealizada ? Icons.check_circle : Icons.schedule,
                        size: 14,
                        color: colorTexto,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        esRealizada ? 'Realizada' : 'Pendiente',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: colorTexto,
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