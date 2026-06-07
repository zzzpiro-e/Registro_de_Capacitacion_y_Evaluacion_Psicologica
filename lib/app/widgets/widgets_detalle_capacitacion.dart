import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CardInformacionPrincipal extends StatelessWidget {
  final Map<String, dynamic> capacitacion;
  const CardInformacionPrincipal({super.key, required this.capacitacion});

  @override
  Widget build(BuildContext context) {
    final titulo = capacitacion['titulo'] ?? 'Sin título';
    final descripcion = capacitacion['descripcion'] ?? 'Sin descripción';
    final institucion = capacitacion['institucion'] ?? 'Sin institución';
    final estado = capacitacion['estado'] ?? 'Pendiente';
    final tipo = capacitacion['tipo'] ?? 'General';

    final esRealizada = estado.toLowerCase() == 'realizada';
    final colorEtiqueta = esRealizada
        ? const Color(0xFFE8F5E9)
        : const Color(0xFFFFF3E0);
    final colorTexto = esRealizada
        ? const Color(0xFF2E7D32)
        : const Color(0xFFFF9800);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F0F0),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  tipo,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: colorEtiqueta,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  estado,
                  style: TextStyle(
                    color: colorTexto,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            titulo,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            institucion,
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
          const Divider(height: 24, thickness: 1),
          const Text(
            "Descripción",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            descripcion,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class CardFechasCapacitacion extends StatelessWidget {
  final Map<String, dynamic> capacitacion;
  const CardFechasCapacitacion({super.key, required this.capacitacion});

  String _formatearFechaTimestamp(dynamic campo) {
    if (campo is Timestamp) {
      final fecha = campo.toDate();
      return "${fecha.day}/${fecha.month}/${fecha.year} a las ${fecha.hour}:${fecha.minute.toString().padLeft(2, '0')}";
    }
    return 'No especificada';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Vigencia y Horarios",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.date_range, size: 18, color: Colors.black45),
              const SizedBox(width: 8),
              Text(
                "Inicio: ${_formatearFechaTimestamp(capacitacion['fechaInicio'])}",
                style: const TextStyle(fontSize: 13, color: Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.event_available,
                size: 18,
                color: Colors.black45,
              ),
              const SizedBox(width: 8),
              Text(
                "Término: ${_formatearFechaTimestamp(capacitacion['fechaFin'])}",
                style: const TextStyle(fontSize: 13, color: Colors.black87),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CardListaEmpleadosCruce extends StatelessWidget {
  final dynamic rutsCampo;
  final String tituloSeccion;
  final IconData icono;
  final Color colorIcono;
  final String mensajeVacio;

  const CardListaEmpleadosCruce({
    super.key,
    required this.rutsCampo,
    required this.tituloSeccion,
    required this.icono,
    required this.colorIcono,
    required this.mensajeVacio,
  });

  String _limpiarRut(String rutRaw) {
    return rutRaw.toLowerCase().replaceAll(RegExp(r'[^0-9kK]'), '').trim();
  }

  List<String> _procesarRuts(dynamic campo) {
    if (campo == null) return [];
    if (campo is List) {
      return campo
          .map((e) => _limpiarRut(e.toString()))
          .where((e) => e.isNotEmpty)
          .toList();
    }
    if (campo is String) {
      if (campo.trim().isEmpty) return [];
      return campo
          .split(',')
          .map((e) => _limpiarRut(e))
          .where((e) => e.isNotEmpty)
          .toList();
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    final rutsCapacitacion = _procesarRuts(rutsCampo);

    // 🟢 PRINT DIAGNÓSTICO 1
    print("=== [DEBUG] $tituloSeccion ===");
    print("RUTs que llegaron procesados de la capacitación: $rutsCapacitacion");

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icono, color: colorIcono, size: 20),
              const SizedBox(width: 8),
              Text(
                tituloSeccion,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (rutsCapacitacion.isEmpty)
            Text(
              mensajeVacio,
              style: const TextStyle(color: Colors.black45, fontSize: 14),
            )
          else
            FutureBuilder<QuerySnapshot>(
              future: FirebaseFirestore.instance.collection('empleados').get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Text(
                    "No se encontraron empleados registrados en el sistema.",
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  );
                }

                // Filtrar empleados
                final empleadosFiltrados = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final rutEmpleadoRaw = data['rut']?.toString() ?? '';
                  final rutEmpleadoLimpio = _limpiarRut(rutEmpleadoRaw);

                  final coincide = rutsCapacitacion.contains(rutEmpleadoLimpio);

                  // 🟢 PRINT DIAGNÓSTICO 2 (Ver por qué no coincide)
                  print(
                    "Comparando en BD: Original='$rutEmpleadoRaw' -> Limpio='$rutEmpleadoLimpio' | ¿Coincide?: $coincide",
                  );

                  return coincide;
                }).toList();

                print(
                  "Total empleados cruzados que sí hicieron match: ${empleadosFiltrados.length}",
                );

                if (empleadosFiltrados.isEmpty) {
                  return Text(
                    mensajeVacio,
                    style: const TextStyle(fontSize: 14, color: Colors.black45),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: empleadosFiltrados.length,
                  itemBuilder: (context, index) {
                    final emp =
                        empleadosFiltrados[index].data()
                            as Map<String, dynamic>;
                    final nombreCompleto =
                        "${emp['nombres'] ?? ''} ${emp['apellidos'] ?? ''}";
                    final cargo = emp['cargo'] ?? 'Sin cargo asignado';

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.account_circle,
                            color: Color(0xFF2E7D32),
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  nombreCompleto,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                                Text(
                                  "$cargo • RUT: ${emp['rut']}",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
        ],
      ),
    );
  }
}
