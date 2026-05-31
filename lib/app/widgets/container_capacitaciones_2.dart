import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ContainerCapacitacionesDos extends StatelessWidget {
  const ContainerCapacitacionesDos({super.key});

  Future<Map<String, int>> _obtenerConteoCapacitaciones() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('capacitaciones')
        .get();

    int pendientes = 0;
    int realizadas = 0;

    for (var doc in snapshot.docs) {
      final estado = (doc['estado'] ?? '').toString().trim().toLowerCase();
      if (estado == 'pendiente') pendientes++;
      if (estado == 'realizada') realizadas++;
    }

    return {
      'pendientes': pendientes,
      'realizadas': realizadas,
      'totales': snapshot.docs.length,
    };
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, int>>(
      future: _obtenerConteoCapacitaciones(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data!;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildCard(
                      'Pendientes',
                      data['pendientes']!,
                      Colors.orange,
                      Icons.schedule,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildCard(
                      'Realizadas',
                      data['realizadas']!,
                      const Color(0xFF2E7D32),
                      Icons.check_circle,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildCard(
                'Totales',
                data['totales']!,
                const Color(0xFF2E7D32),
                Icons.school,
                fullWidth: true,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCard(
    String titulo,
    int cantidad,
    Color color,
    IconData icono, {
    bool fullWidth = false,
  }) {
    return Container(
      height: 90,
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(14),
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
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icono, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2E7D32),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  cantidad.toString(),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}