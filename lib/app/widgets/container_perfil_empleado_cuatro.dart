import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

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

  // Color verde principal de tu aplicación
  final Color verdePrincipal = const Color(0xFF2E7D32);

  // 📝 Limpia el RUT eliminando puntos, guiones y espacios
  String _limpiarRut(String rutOriginal) {
    return rutOriginal
        .replaceAll('.', '')
        .replaceAll('-', '')
        .trim()
        .toLowerCase();
  }

  // 🔍 Ejecuta ambas consultas en paralelo en Firestore
  Future<Map<String, List<DocumentSnapshot>>> _obtenerCapacitaciones(
    String rutLimpio,
  ) async {
    final coleccion = FirebaseFirestore.instance.collection('capacitaciones');

    final resultados = await Future.wait([
      coleccion.where('empleadosRealizaron', arrayContains: rutLimpio).get(),
      coleccion.where('empleadosAsignados', arrayContains: rutLimpio).get(),
    ]);

    return {'realizadas': resultados[0].docs, 'pendientes': resultados[1].docs};
  }

  // 📅 Convierte el Timestamp de Firebase a un String legible (ej: 31/05/2026)
  String _formatearFecha(dynamic fechaFormato) {
    if (fechaFormato == null) return 'Sin fecha';
    if (fechaFormato is Timestamp) {
      return DateFormat('dd/MM/yyyy').format(fechaFormato.toDate());
    }
    return fechaFormato.toString();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      key: ValueKey(_retryKey), // Tu reconexión nativa intacta
      stream: FirebaseFirestore.instance
          .collection('empleados')
          .doc(widget.empleadoId)
          .snapshots(),
      builder: (context, empleadoSnapshot) {
        if (empleadoSnapshot.hasError) return _buildErrorWidget();
        if (empleadoSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!empleadoSnapshot.hasData || !empleadoSnapshot.data!.exists) {
          return const SizedBox.shrink();
        }

        final empleadoData =
            empleadoSnapshot.data!.data() as Map<String, dynamic>;
        final rutLimpio = _limpiarRut(empleadoData['rut']?.toString() ?? '');

        return FutureBuilder<Map<String, List<DocumentSnapshot>>>(
          future: _obtenerCapacitaciones(rutLimpio),
          builder: (context, capSnapshot) {
            if (capSnapshot.hasError) return _buildErrorWidget();
            if (capSnapshot.connectionState == ConnectionState.waiting) {
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
              width: double.infinity,
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
                  Text(
                    'Historial de Capacitaciones',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: verdePrincipal,
                    ),
                  ),
                  const SizedBox(height: 12),

                  if (todasLasCapacitaciones.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Este empleado no registra capacitaciones asignadas.',
                        style: TextStyle(color: Colors.black54),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: todasLasCapacitaciones.length,
                      itemBuilder: (context, index) {
                        final item = todasLasCapacitaciones[index];
                        final curso = item['data'];
                        final bool esRealizada = item['esRealizada'];

                        final titulo =
                            curso['titulo'] ?? 'Capacitación sin título';
                        final institucion =
                            curso['institucion'] ??
                            'Institución no especificada';
                        final fechaVencimiento = _formatearFecha(
                          curso['fechaFin'],
                        );

                        // Configuración de la etiqueta de estado sin exceso de color
                        final Color colorEstado = esRealizada
                            ? verdePrincipal
                            : Colors.orange;
                        final String textoEstado = esRealizada
                            ? 'Realizada'
                            : 'Pendiente';

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow:
                                const [], // ❌ Eliminamos por completo el sombreado gris
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Fila superior: Título del curso y Etiqueta de Estado
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      titulo.toString().toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Colors
                                            .black87, // 🟢 Título en color Negro
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Badge de Estado plano y sutil
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: colorEstado.withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: colorEstado.withOpacity(0.5),
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      textoEstado,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: colorEstado,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),

                              // Institución
                              Row(
                                children: [
                                  Icon(
                                    Icons.business,
                                    size: 16,
                                    color: verdePrincipal,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      institucion.toString(),
                                      style: TextStyle(
                                        fontSize: 13,
                                        color:
                                            verdePrincipal, // 🟢 Texto de Institución en Verde
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),

                              // Fecha de Vencimiento / Fin
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    size: 16,
                                    color: verdePrincipal,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Vence: $fechaVencimiento',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color:
                                          verdePrincipal, // 🟢 Texto de Fecha en Verde
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
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
      },
    );
  }

  // 🛠️ Mismo Widget de error y reintentos que tenías originalmente
  Widget _buildErrorWidget() {
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
              style: TextButton.styleFrom(foregroundColor: verdePrincipal),
            ),
          ],
        ),
      ),
    );
  }
}
