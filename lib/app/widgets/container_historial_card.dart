import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Importante para reconocer el tipo Timestamp
import 'package:intl/intl.dart';                     // Necesario para DateFormat

class ContainerHistorialCard extends StatelessWidget {
  final Map<String, dynamic> datos;

  const ContainerHistorialCard({
    super.key,
    required this.datos,
  });

  // Función interna para formatear de manera segura cualquier tipo de fecha que venga en 'datos'
  String _formatearFecha(dynamic fecha) {
    if (fecha is Timestamp) {
      return DateFormat('dd/MM/yyyy').format(fecha.toDate());
    }
    if (fecha is DateTime) {
      return DateFormat('dd/MM/yyyy').format(fecha);
    }
    if (fecha is String && fecha.isNotEmpty) {
      if (fecha.toLowerCase() == 'hoy') {
        return DateFormat('dd/MM/yyyy').format(DateTime.now());
      }
      // Si el string ya es una fecha ISO, intentamos parsearla
      final parseada = DateTime.tryParse(fecha);
      if (parseada != null) {
        return DateFormat('dd/MM/yyyy').format(parseada);
      }
      return fecha; // Si ya viene formateado, lo devuelve intacto
    }
    return 'No especificada';
  }

  @override
  Widget build(BuildContext context) {
    final Color verdePrincipal = const Color(0xFF2E7D32);
    final Color verdeBotonVer = const Color(0xFF1B5E20);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person_outline, color: verdePrincipal, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  datos['nombre'] ?? '',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Text(
            'RUT: ${datos['rut'] ?? ''}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.green.shade700,
            ),
          ),
          const SizedBox(height: 4),

          Text(
            datos['motivo'] ?? '',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              const Icon(Icons.calendar_today_outlined, color: Colors.grey, size: 14),
              const SizedBox(width: 6),
              // CORRECCIÓN AQUÍ: Envolvemos en Expanded y usamos el formateador seguro
              Expanded(
                child: Text(
                  'Evaluado el ${_formatearFecha(datos['fecha'] ?? datos['derivacionFecha'])}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis, // Si el contenedor es chico, añade "..." en vez de romper la UI
                ),
              ),
            ],
          ),
          const SizedBox(height: 16), 
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  'historial_informes',
                  arguments: datos,
                );
              },
              icon: const Icon(Icons.visibility_outlined, size: 18, color: Colors.white),
              label: const Text(
                'Ver Informes Psicológicos', 
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: verdeBotonVer,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}