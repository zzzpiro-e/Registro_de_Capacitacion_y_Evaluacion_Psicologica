
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

  // 🔍 Ejecuta la consulta de forma correcta basándose únicamente en los asignados
  Future<List<DocumentSnapshot>> _obtenerCapacitaciones(
    String rutLimpio,
  ) async {
    final coleccion = FirebaseFirestore.instance.collection('capacitaciones');

    // Buscamos todas las capacitaciones donde el empleado esté asignado originalmente
    final resultado = await coleccion.where('empleadosAsignados', arrayContains: rutLimpio).get();

    return resultado.docs;
  }

  // 🔄 Cambia el estado de la capacitación en Firestore sin borrar al empleado de asignados
  Future<void> _cambiarEstadoCapacitacion({
    required String idDocumento,
    required String rutLimpio,
    required bool esRealizadaActual,
  }) async {
    final docRef = FirebaseFirestore.instance
        .collection('capacitaciones')
        .doc(idDocumento);

    try {
      if (esRealizadaActual) {
        // Pasa de Realizada a Pendiente: Solo lo sacamos de los que realizaron
        await docRef.update({
          'empleadosRealizaron': FieldValue.arrayRemove([rutLimpio]),
        });
      } else {
        // Pasa de Pendiente a Realizada: Lo sumamos a realizaron, y lo DEJAMOS en asignados
        await docRef.update({
          'empleadosRealizaron': FieldValue.arrayUnion([rutLimpio]),
        });
      }
      // Forzar la actualización de la interfaz de usuario
      setState(() {});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar el estado: $e')),
        );
      }
    }
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

        return FutureBuilder<List<DocumentSnapshot>>(
          future: _obtenerCapacitaciones(rutLimpio),
          builder: (context, capSnapshot) {
            if (capSnapshot.hasError) return _buildErrorWidget();
            if (capSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final documentos = capSnapshot.data ?? [];
            final List<Map<String, dynamic>> todasLasCapacitaciones = [];

            for (var doc in documentos) {
              final data = doc.data() as Map<String, dynamic>;
              
              // Extraemos la lista de los que realizaron para verificar si este RUT específico ya está allí
              final realizararonLista = data['empleadosRealizaron'] is List
                  ? List.from(data['empleadosRealizaron'])
                  : [];

              // Es realizada para ESTE empleado si su RUT ya figura en la lista de los que completaron
              final bool esteEmpleadoLaHizo = realizararonLista.contains(rutLimpio);

              todasLasCapacitaciones.add({
                'id': doc.id,
                'data': data,
                'esRealizada': esteEmpleadoLaHizo,
              });
            }

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
                        final idDocumento = item['id'];
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

                        // Configuración de la etiqueta de estado
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
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
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
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  InkWell(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: const Text(
                                              'Modificar Estado',
                                            ),
                                            content: Text(
                                              '¿Deseas cambiar el estado de "$titulo" a ${esRealizada ? "Pendiente" : "Realizada"}?',
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                                child: const Text('Cancelar'),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                  _cambiarEstadoCapacitacion(
                                                    idDocumento: idDocumento,
                                                    rutLimpio: rutLimpio,
                                                    esRealizadaActual:
                                                        esRealizada,
                                                  );
                                                },
                                                child: const Text('Confirmar'),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                    borderRadius: BorderRadius.circular(20),
                                    child: Container(
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
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            textoEstado,
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: colorEstado,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Icon(
                                            Icons.edit,
                                            size: 12,
                                            color: colorEstado,
                                          ),
                                        ],
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
                                        color: verdePrincipal,
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
                                      color: verdePrincipal,
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
