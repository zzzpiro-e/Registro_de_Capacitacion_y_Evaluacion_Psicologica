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
  final List<Map<String, dynamic>> rutsCampo;
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

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (rutsCampo.isEmpty)
            Text(
              mensajeVacio,
              style: const TextStyle(
                color: Colors.black54,
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: rutsCampo.length,
              itemBuilder: (context, index) {
                final emp = rutsCampo[index];

                final nombre =
                    emp['nombre']?.toString() ?? '';

                final apellido =
                    emp['apellido']?.toString() ?? '';

                final rut =
                    emp['rut']?.toString() ?? '';

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 6,
                  ),
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
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              "$nombre $apellido",
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              rut,
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
            ),
        ],
      ),
    );
  }
}

