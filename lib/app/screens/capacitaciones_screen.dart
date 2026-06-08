import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proyecto_flutter/app/widgets/container_capacitaciones_1.dart';
import 'package:proyecto_flutter/app/widgets/container_capacitaciones_2.dart';
import 'package:proyecto_flutter/app/widgets/container_capacitaciones_3.dart';

class CapacitacionesPage extends StatefulWidget {
  final VoidCallback? onReturnToDashboard;
  final String filtroInicial;

  const CapacitacionesPage({super.key, this.onReturnToDashboard, this.filtroInicial = 'todas'});

  @override
  State<CapacitacionesPage> createState() => _CapacitacionesPageState();
}

class _CapacitacionesPageState extends State<CapacitacionesPage> {
  // 🔹 Estado del filtro: 'todas', 'pendiente' o 'realizada'
  String _filtroActivo = 'todas';
  int _retryKey = 0;
  // Función automática para comparar las listas de empleados y actualizar la BD
  // 🔹 Versión corregida y estricta: separa el caso vacío del caso con RUTs
  // 🔹 Regla definitiva: Solo automatiza si hay RUTs cargados y coinciden
  void _verificarYActualizarEstado(
    String docId,
    dynamic asignados,
    dynamic realizaron,
    String estadoActual,
  ) {
    if (estadoActual.trim().toLowerCase() == 'realizada') return;

    List<String> listaAsignados = _convertirAListaString(asignados);
    List<String> listaRealizaron = _convertirAListaString(realizaron);

    if (listaAsignados.isEmpty && listaRealizaron.isEmpty) return;
    if (listaAsignados.isEmpty || listaRealizaron.isEmpty) return;

    final setAsignados = listaAsignados.toSet();
    final setRealizaron = listaRealizaron.toSet();

    if (setAsignados.length == setRealizaron.length &&
        setAsignados.containsAll(setRealizaron)) {
      FirebaseFirestore.instance
          .collection('capacitaciones')
          .doc(docId)
          .update({'estado': 'realizada'})
          .then(
            (_) => debugPrint(
              'Capacitación con RUTs $docId completada con éxito.',
            ),
          )
          .catchError(
            (e) => debugPrint('Error en actualización automática: $e'),
          );
    }
  }

  List<String> _convertirAListaString(dynamic campo) {
    if (campo == null) return [];
    if (campo is List) {
      return campo
          .map((e) => e.toString().trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    if (campo is String) {
      if (campo.trim().isEmpty) return [];
      return campo
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      body: SafeArea(
        child: Column(
          children: [
            ContainerCapacitacionesUno(onBackTap: widget.onReturnToDashboard),
            Stack(
              children: [
                const ContainerCapacitacionesDos(),
                Positioned.fill(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Column(
                        children: [
                          SizedBox(
                            height: 100,
                            child: Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    behavior: HitTestBehavior.translucent,
                                    onTap: () {
                                      setState(() {
                                        _filtroActivo = 'pendiente';
                                      });
                                      debugPrint(
                                        "Filtro cambiado a: PENDIENTES",
                                      );
                                    },
                                    child: const SizedBox.expand(),
                                  ),
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    behavior: HitTestBehavior.translucent,
                                    onTap: () {
                                      setState(() {
                                        _filtroActivo = 'realizada';
                                      });
                                      debugPrint(
                                        "Filtro cambiado a: REALIZADAS",
                                      );
                                    },
                                    child: const SizedBox.expand(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: () {
                                setState(() {
                                  _filtroActivo = 'todas';
                                });
                                debugPrint("Filtro cambiado a: TODAS");
                              },
                              child: const SizedBox.expand(),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    "Mostrando: ${_filtroActivo == 'todas'
                        ? 'Todas'
                        : _filtroActivo == 'pendiente'
                        ? 'Pendientes'
                        : 'Realizadas'}",
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.black54,
                    ),
                  ),
                  if (_filtroActivo != 'todas') ...[
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () => setState(() => _filtroActivo = 'todas'),
                      child: const Text(
                        "(Ver todas)",
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF2E7D32),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                key: ValueKey(_retryKey),
                stream: FirebaseFirestore.instance
                    .collection('capacitaciones')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.cloud_off,
                            size: 48,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            "Error de conexión al cargar las capacitaciones",
                            style: TextStyle(color: Colors.black54),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                _retryKey++;
                              });
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text("Reintentar"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2E7D32),
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text("No hay capacitaciones registradas"),
                    );
                  }

                  final todasLasCapacitaciones = snapshot.data!.docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final docId = doc.id;
                    final estadoActual = (data['estado'] ?? 'pendiente')
                        .toString();

                    _verificarYActualizarEstado(
                      docId,
                      data['empleadosAsignados'],
                      data['empleadosRealizaron'],
                      estadoActual,
                    );

                    return {
                      ...data,
                      'id': docId,
                      'fechaInicioFormateada': data['fechaInicio'] != null
                          ? "${(data['fechaInicio'] as Timestamp).toDate().day}/"
                                "${(data['fechaInicio'] as Timestamp).toDate().month}/"
                                "${(data['fechaInicio'] as Timestamp).toDate().year}"
                          : 'Sin fecha',
                    };
                  }).toList();

                  final capacitacionesFiltradas = todasLasCapacitaciones.where((
                    cap,
                  ) {
                    final estado = (cap['estado'] ?? 'pendiente')
                        .toString()
                        .trim()
                        .toLowerCase();

                    if (_filtroActivo == 'todas') return true;
                    return estado == _filtroActivo;
                  }).toList();

                  if (capacitacionesFiltradas.isEmpty) {
                    return Center(
                      child: Text(
                        "No hay capacitaciones ${_filtroActivo == 'pendiente' ? 'pendientes' : 'realizadas'}",
                        style: const TextStyle(
                          color: Colors.black45,
                          fontSize: 15,
                        ),
                      ),
                    );
                  }

                  return ContainerCapacitacionesTres(
                    capacitaciones: capacitacionesFiltradas,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
