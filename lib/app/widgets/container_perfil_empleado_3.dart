import 'package:flutter/material.dart';

class ContainerPerfilEmpleadoTres extends StatelessWidget {
  final List<Map<String, dynamic>> capacitaciones;

  const ContainerPerfilEmpleadoTres({super.key, required this.capacitaciones});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF4F4F4),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔹 Título principal
          Row(
            children: const [
              Icon(Icons.workspace_premium_outlined,
                  color: Color(0xFF2E7D32), size: 22),
              SizedBox(width: 8),
              Text(
                'Historial de Capacitaciones',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 🔹 Lista de capacitaciones dinámica
          Column(
            children: capacitaciones.map((cap) {
              final estado = cap['estado'] ?? ''; // evita null
              final colorEstado = estado == 'Realizada'
                  ? const Color(0xFF2E7D32)
                  : const Color(0xFFFF9800);
              final fondoEstado = estado == 'Realizada'
                  ? const Color(0xFFE8F5E9)
                  : const Color(0xFFFFF3E0);

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título y estado
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            cap['titulo'] ?? 'Sin título',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: fondoEstado,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            estado.isNotEmpty ? estado : 'Sin estado',
                            style: TextStyle(
                              color: colorEstado,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      cap['institucion'] ?? 'Institución no especificada',
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      cap['fecha'] ?? 'Fecha no disponible',
                      style: const TextStyle(
                        color: Colors.black45,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
