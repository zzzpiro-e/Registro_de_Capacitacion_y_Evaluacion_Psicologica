import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'psicologo_detalle_derivacion_screen.dart';
import 'package:intl/intl.dart';

class PsicologoDerivacionesScreen extends StatelessWidget {
  final String? psicologoEmail;

  const PsicologoDerivacionesScreen({super.key, this.psicologoEmail});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            color: Colors.white,
            width: double.infinity,
            child: const Text(
              'Bandeja de Derivaciones',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 10),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('empleados')
                  .where('derivado', isEqualTo: true)
                  .where('psicologoEmail', isEqualTo: psicologoEmail)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No hay empleados derivados"));
                }

                final empleados = snapshot.data!.docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;

                  // 🔹 Formatear fecha de ingreso
                  String fechaIngreso = 'N/A';
                  if (data['fechaIngreso'] is Timestamp) {
                    fechaIngreso = DateFormat('dd/MM/yyyy').format(
                      (data['fechaIngreso'] as Timestamp).toDate(),
                    );
                  }

                  return {
                    'id': doc.id,
                    'nombres': data['nombres'] ?? 'Sin nombre',
                    'rut': data['rut'] ?? 'Sin RUT',
                    'cargo': data['cargo'] ?? 'Sin cargo',
                    'edad': data['edad']?.toString() ?? 'N/A',
                    'estado': data['estado'] ?? 'N/A',
                    'fechaIngreso': fechaIngreso,
                    'salario': '******', // 🔹 ocultamos el sueldo
                    'fichaPsicologica': data['fichaPsicologica'] ?? '',
                  };
                }).toList();

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  itemCount: empleados.length,
                  itemBuilder: (context, index) {
                    final empleado = empleados[index];
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                PsicologoDetalleDerivacionScreen(derivacion: empleado),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            )
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
                              child: const Icon(Icons.person_outline,
                                  color: Color(0xFF2E7D32), size: 28),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    empleado['nombres'],
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Cargo: ${empleado['cargo']}",
                                    style: const TextStyle(
                                        fontSize: 14, color: Colors.black54),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Estado: ${empleado['estado']}",
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.grey),
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
              },
            ),
          ),
        ],
      ),
    );
  }
}
