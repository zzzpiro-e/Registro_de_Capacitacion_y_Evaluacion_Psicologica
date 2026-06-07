import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ContainerCapacitacionesDos extends StatefulWidget {
  const ContainerCapacitacionesDos({super.key});

  @override
  State<ContainerCapacitacionesDos> createState() =>
      _ContainerCapacitacionesDosState();
}

class _ContainerCapacitacionesDosState
    extends State<ContainerCapacitacionesDos> {
  late Future<Map<String, int>> _conteoFuture;

  @override
  void initState() {
    super.initState();
    _cargarConteos();
  }

  void _cargarConteos() {
    _conteoFuture = _obtenerConteoCapacitaciones();
  }

  Future<Map<String, int>> _obtenerConteoCapacitaciones() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('capacitaciones')
          .get()
          .timeout(const Duration(seconds: 10));

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
    } catch (e) {
      throw Exception('Fallo al conectar con el servidor');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, int>>(
      future: _conteoFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      'Error de conexión al cargar totales.',
                      style: TextStyle(color: Colors.redAccent, fontSize: 13),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Color(0xFF2E7D32)),
                    onPressed: () {
                      setState(() {
                        _cargarConteos();
                      });
                    },
                  ),
                ],
              ),
            ),
          );
        }

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
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
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
