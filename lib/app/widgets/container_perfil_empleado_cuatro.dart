import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ContainerPerfilEmpleadoCuatro extends StatelessWidget {
  final String empleadoId;

  const ContainerPerfilEmpleadoCuatro({super.key, required this.empleadoId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('empleados')
          .doc(empleadoId)
          .get(),
      builder: (context, empleadoSnapshot) {
        if (empleadoSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!empleadoSnapshot.hasData || !empleadoSnapshot.data!.exists) {
          return const SizedBox();
        }

        final empleado = empleadoSnapshot.data!.data() as Map<String, dynamic>;

        final rutNormalizado = empleado['rut']?.toString().trim() ?? '';

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('capacitaciones')
              .snapshots(),
          builder: (context, capacitacionesSnapshot) {
            if (capacitacionesSnapshot.connectionState ==
                ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final capacitaciones = (capacitacionesSnapshot.data?.docs ?? [])
                .where((doc) {
                  final data = doc.data() as Map<String, dynamic>;

                  final empleadosAsignados =
                      (data['empleadosAsignados'] as List<dynamic>? ?? []);

                  return empleadosAsignados.any(
                    (rut) => rut.toString().trim() == rutNormalizado,
                  );
                })
                .toList();

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Historial de Capacitaciones',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (capacitaciones.isEmpty)
                    const Text(
                      'Este empleado no registra capacitaciones.',
                      style: TextStyle(color: Colors.black87),
                    ),

                  ...capacitaciones.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;

                    final titulo = data['titulo']?.toString() ?? 'Sin título';

                    final institucion =
                        data['institucion']?.toString() ?? 'Sin institución';

                    final tipo = data['tipo']?.toString() ?? 'No especificado';

                    final empleadosRealizaron =
                        (data['empleadosRealizaron'] as List<dynamic>? ?? [])
                            .map((e) => e.toString().trim())
                            .toList();

                    final realizada = empleadosRealizaron.contains(
                      rutNormalizado,
                    );

                    final estado = realizada ? 'REALIZADA' : 'PENDIENTE';

                    String fechaInicio = '-';
                    String fechaFin = '-';

                    if (data['fechaInicio'] is Timestamp) {
                      fechaInicio = DateFormat(
                        'dd/MM/yyyy',
                      ).format((data['fechaInicio'] as Timestamp).toDate());
                    }

                    if (data['fechaFin'] is Timestamp) {
                      fechaFin = DateFormat(
                        'dd/MM/yyyy',
                      ).format((data['fechaFin'] as Timestamp).toDate());
                    }

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.school,
                            color: Color(0xFF2E7D32),
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  titulo,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(institucion),
                                const SizedBox(height: 2),
                                Text('Tipo: $tipo'),

                                Container(
                                  margin: const EdgeInsets.only(top: 4),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: realizada
                                        ? Colors.green.shade100
                                        : Colors.orange.shade100,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    estado,
                                    style: TextStyle(
                                      color: realizada
                                          ? Colors.green.shade800
                                          : Colors.orange.shade800,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),

                                Text('Periodo: $fechaInicio - $fechaFin'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
