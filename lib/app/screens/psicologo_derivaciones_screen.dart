import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'psicologo_detalle_derivacion_screen.dart';
import 'package:intl/intl.dart';

class PsicologoDerivacionesScreen extends StatefulWidget {
  final String? psicologoEmail;

  const PsicologoDerivacionesScreen({super.key, this.psicologoEmail});

  @override
  State<PsicologoDerivacionesScreen> createState() => _PsicologoDerivacionesScreenState();
}

class _PsicologoDerivacionesScreenState extends State<PsicologoDerivacionesScreen> {
  
  Color _colorEstado(String estado) {
    switch (estado) {
      case 'Pendiente': return const Color(0xFFFFF3CD);
      case 'En Proceso': return const Color(0xFFD0E2FF);
      case 'Completado': return const Color(0xFFDFFFD6);
      default: return Colors.grey.shade200;
    }
  }

  Color _colorTextoEstado(String estado) {
    switch (estado) {
      case 'Pendiente': return const Color(0xFFB8860B);
      case 'En Proceso': return const Color(0xFF0056B3);
      case 'Completado': return const Color(0xFF2E7D32);
      default: return Colors.black54;
    }
  }

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
                  .where('psicologoEmail', isEqualTo: widget.psicologoEmail)
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

                  String fechaIngreso = 'N/A';
                  if (data['fechaIngreso'] is Timestamp) {
                    fechaIngreso = DateFormat('dd/MM/yyyy').format(
                      (data['fechaIngreso'] as Timestamp).toDate(),
                    );
                  }

                  // 🔹 Creamos el mapa unificado con los datos reales de la DB
                  return {
                    'id': doc.id,
                    'nombre': data['nombres'] ?? 'Sin nombre', // Usamos 'nombre' para mantener compatibilidad con tu pantalla de detalle
                    'rut': data['rut'] ?? 'Sin RUT',
                    'cargo': data['cargo'] ?? 'Sin cargo',
                    'edad': data['edad']?.toString() ?? 'N/A',
                    'estado': data['estado'] ?? 'Pendiente', // Si no viene, asumimos Pendiente
                    'fechaIngreso': fechaIngreso,
                    'salario': '******', 
                    'fichaPsicologica': data['fichaPsicologica'] ?? '',
                    'motivo': data['motivo'] ?? 'No especificado', // Campo del flujo de Marianela
                    'fecha': data['fechaDerivacion'] ?? data['fecha'] ?? 'Hoy',
                  };
                }).toList();

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  itemCount: empleados.length,
                  itemBuilder: (context, index) {
                    final empleado = empleados[index];
                    return InkWell(
                      onTap: () async {
                        // Esperamos el regreso de la pantalla de detalle por si mutó el estado
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PsicologoDetalleDerivacionScreen(derivacion: empleado),
                          ),
                        );
                        setState(() {});
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
                              child: const Icon(Icons.person_outline, color: Color(0xFF2E7D32), size: 28),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    empleado['nombre'],
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Cargo: ${empleado['cargo']}",
                                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Motivo: ${empleado['motivo']}",
                                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            // 🔹 Renderizado de tus etiquetas de colores institucionales en base al estado real
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: _colorEstado(empleado['estado']),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                empleado['estado'],
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: _colorTextoEstado(empleado['estado']),
                                ),
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