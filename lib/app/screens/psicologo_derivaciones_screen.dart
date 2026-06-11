import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'psicologo_detalle_derivacion_screen.dart';
import 'package:intl/intl.dart';
import '../widgets/container_detalle_buscador.dart';
import '../widgets/container_derivaciones_contador.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PsicologoDerivacionesScreen extends StatefulWidget {
  const PsicologoDerivacionesScreen({super.key});

  @override
  State<PsicologoDerivacionesScreen> createState() =>
      _PsicologoDerivacionesScreenState();
}

class _PsicologoDerivacionesScreenState
    extends State<PsicologoDerivacionesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _filtroTexto = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Color _colorEstado(String estado) {
    switch (estado) {
      case 'Pendiente':
        return const Color(0xFFFFF3CD);
      case 'En Proceso':
        return const Color(0xFFD0E2FF);
      case 'Completado':
        return const Color(0xFFDFFFD6);
      default:
        return Colors.grey.shade200;
    }
  }

  Color _colorTextoEstado(String estado) {
    switch (estado) {
      case 'Pendiente':
        return const Color(0xFFB8860B);
      case 'En Proceso':
        return const Color(0xFF0056B3);
      case 'Completado':
        return const Color(0xFF2E7D32);
      default:
        return Colors.black54;
    }
  }

  @override
  Widget build(BuildContext context) {
    final String correoPsicologo =
        FirebaseAuth.instance.currentUser?.email ?? '';

    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 12),
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: ContainerDerivacionesContador(
              psicologoEmail: correoPsicologo,
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: ContainerDetalleBuscador(
              controller: _searchController,
              onChanged: (valor) {
                setState(() {
                  _filtroTexto = valor.toLowerCase().trim();
                });
              },
            ),
          ),
          const SizedBox(height: 2),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('empleados')
                  .where('derivado', isEqualTo: true)
                  .where('psicologoEmail', isEqualTo: correoPsicologo)
                  .where(
                    'estado',
                    whereIn: ['Pendiente', 'En Proceso', 'activo'],
                  )
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text("No hay empleados derivados"),
                  );
                }

                final todosLosEmpleados = snapshot.data!.docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;

                  String fechaIngreso = 'N/A';
                  if (data['fechaIngreso'] is Timestamp) {
                    fechaIngreso = DateFormat(
                      'dd/MM/yyyy',
                    ).format((data['fechaIngreso'] as Timestamp).toDate());
                  }

                  final String nombres = data['nombres'] ?? 'Sin nombre';
                  final String apellidos = data['apellidos'] ?? '';
                  final String nombreCompleto = "$nombres $apellidos".trim();

                  String estadoClinico = data['estado'] ?? 'Pendiente';
                  if (estadoClinico.toLowerCase() == 'activo') {
                    estadoClinico = 'Pendiente';
                  }

                  return {
                    'id': doc.id,
                    'nombre': nombreCompleto,
                    'rut': data['rut'] ?? 'Sin RUT',
                    'cargo': data['cargo'] ?? 'Sin cargo',
                    'area': data['area'] ?? 'No especificada',
                    'edad': data['edad']?.toString() ?? 'N/A',
                    'estado': estadoClinico,
                    'fechaIngreso': fechaIngreso,
                    'salario': '******',
                    'fichaPsicologica': data['fichaPsicologica'] ?? '',
                    'motivo': data['motivo'] ?? 'No especificado',
                    'fecha': data['fechaDerivacion'] ?? data['fecha'] ?? 'Hoy',
                  };
                }).toList();

                final empleadosFiltrados = todosLosEmpleados.where((empleado) {
                  final String nombre = empleado['nombre']
                      .toString()
                      .toLowerCase();
                  final String rut = empleado['rut'].toString().toLowerCase();
                  final String cargo = empleado['cargo']
                      .toString()
                      .toLowerCase();

                  return nombre.contains(_filtroTexto) ||
                      rut.contains(_filtroTexto) ||
                      cargo.contains(_filtroTexto);
                }).toList();

                if (empleadosFiltrados.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        'No se encontraron resultados para "$_filtroTexto"',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 15,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  itemCount: empleadosFiltrados.length,
                  itemBuilder: (context, index) {
                    final empleado = empleadosFiltrados[index];
                    return InkWell(
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                PsicologoDetailDerivacionScreen(
                                  derivacion: empleado,
                                ),
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
                                Icons.person_outline,
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
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Motivo: ${empleado['motivo']}",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
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
