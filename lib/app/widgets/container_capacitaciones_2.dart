import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ContainerCapacitacionesDos extends StatelessWidget {
  const ContainerCapacitacionesDos({super.key});

  Future<Map<String, int>> _obtenerConteoCapacitaciones() async {
    final snapshot = await FirebaseFirestore.instance.collection('capacitaciones').get();

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
            mainAxisSize: MainAxisSize.min, // 🔹 evita overflow
            children: [
              // 🔹 Fila superior: Pendientes y Realizadas
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: _buildCard('Pendientes', data['pendientes']!, Colors.orange),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildCard('Realizadas', data['realizadas']!, const Color(0xFF2E7D32)),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 🔹 Fila inferior: Totales (ancho completo)
              _buildCard('Totales', data['totales']!, Colors.blueGrey, fullWidth: true),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCard(String titulo, int cantidad, Color color, {bool fullWidth = false}) {
    return Container(
      height: 80,
      width: fullWidth ? double.infinity : null,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center, // 🔹 centra verticalmente
        children: [
          Text(
            titulo,
            style: const TextStyle(
              color: Color(0xFF2E7D32),
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            cantidad.toString(),
            style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

