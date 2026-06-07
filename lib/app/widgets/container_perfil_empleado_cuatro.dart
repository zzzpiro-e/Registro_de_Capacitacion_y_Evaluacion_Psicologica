import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ContainerPerfilEmpleadoCuatro extends StatefulWidget {
  final String empleadoId;

  const ContainerPerfilEmpleadoCuatro({super.key, required this.empleadoId});

  @override
  State<ContainerPerfilEmpleadoCuatro> createState() =>
      _ContainerPerfilEmpleadoCuatroState();
}

class _ContainerPerfilEmpleadoCuatroState
    extends State<ContainerPerfilEmpleadoCuatro> {
  int _retryKey = 0;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      key: ValueKey(_retryKey),
      stream: FirebaseFirestore.instance
          .collection('empleados')
          .doc(widget.empleadoId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Column(
                children: [
                  const Icon(Icons.cloud_off, size: 40, color: Colors.grey),
                  const SizedBox(height: 8),
                  const Text(
                    "Error al cargar capacitaciones",
                    style: TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () => setState(() => _retryKey++),
                    icon: const Icon(Icons.refresh),
                    label: const Text("Reintentar"),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF2E7D32),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const SizedBox.shrink();
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final List<dynamic> capacitaciones = data['capacitaciones'] is List
            ? data['capacitaciones']
            : [];

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
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
              const SizedBox(height: 12),
              if (capacitaciones.isEmpty)
                const Text(
                  'Este empleado no registra capacitaciones aprobadas o realizadas.',
                  style: TextStyle(color: Colors.black54),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: capacitaciones.length,
                  itemBuilder: (context, index) {
                    final item = capacitaciones[index];
                    final titulo = item is Map
                        ? item['titulo'] ?? 'Capacitación sin título'
                        : item.toString();

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: Color(0xFF2E7D32),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              titulo,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}
