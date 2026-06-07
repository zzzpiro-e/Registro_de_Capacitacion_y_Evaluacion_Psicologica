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
  //String _filtroActivo = 'todas';
  late String _filtroActivo;
  @override
  void initState() {
    super.initState();
    _filtroActivo = widget.filtroInicial; // <-- inicialización con el filtro recibido
  }
  // Función automática para comparar las listas de empleados y actualizar la BD
  // 🔹 Versión corregida y estricta: separa el caso vacío del caso con RUTs
  // 🔹 Regla definitiva: Solo automatiza si hay RUTs cargados y coinciden
  void _verificarYActualizarEstado(
    String docId,
    dynamic asignados,
    dynamic realizaron,
    String estadoActual,
  ) {
    // Si ya está realizada en Firebase, no hacemos nada más
    if (estadoActual.trim().toLowerCase() == 'realizada') return;

    List<String> listaAsignados = _convertirAListaString(asignados);
    List<String> listaRealizaron = _convertirAListaString(realizaron);

    // ❌ CORRECCIÓN: Si ambas listas están vacías, SALIMOS. No debe pasar a realizada.
    if (listaAsignados.isEmpty && listaRealizaron.isEmpty) return;

    // Si una tiene datos y la otra no (ej: asignados tiene RUTs pero realizaron está vacía)
    // tampoco son iguales, así que salimos y se queda pendiente.
    if (listaAsignados.isEmpty || listaRealizaron.isEmpty) return;

    // Convertimos a Set para comparar los RUTs sin importar el orden
    final setAsignados = listaAsignados.toSet();
    final setRealizaron = listaRealizaron.toSet();

    // ✔️ Solo si tienen los mismos RUTs y la misma cantidad, pasa a realizada
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
            // Encabezado (Archivo 1)
            ContainerCapacitacionesUno(onBackTap: widget.onReturnToDashboard),

            // 🔹 Contadores de tarjetas (Archivo 2) con detector de toques por posición
            // Usamos un LayoutBuilder para envolver las zonas interactivas sin alterar ContainerCapacitacionesDos
            Stack(
              children: [
                const ContainerCapacitacionesDos(),
                Positioned.fill(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final mitadAncho = constraints.maxWidth / 2;
                      return Column(
                        children: [
                          // Fila superior: Pendientes (Izquierda) y Realizadas (Derecha)
                          SizedBox(
                            height:
                                100, // Alto aproximado de la primera fila con paddings
                            child: Row(
                              children: [
                                // Lado Izquierdo: Pendientes
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
                                // Lado Derecho: Realizadas
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
                          // Fila inferior: Totales
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

            // 🔹 Indicador visual del filtro seleccionado actualmente
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

            // Listado Dinámico en tiempo real filtrado
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('capacitaciones')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text("No hay capacitaciones registradas"),
                    );
                  }

                  // 1. Mapeamos y corremos la automatización de estados
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

                  // 2. 🔹 Aplicamos el filtro seleccionado antes de enviarlo a la lista de tarjetas
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

                  // Retorna la lista enviándole solo los datos filtrados (Archivo 3)
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
