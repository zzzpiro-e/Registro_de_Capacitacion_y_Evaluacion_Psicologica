import 'package:flutter/material.dart';

class ContainerHistorialCard extends StatelessWidget {
  final Map<String, dynamic> datos;

  const ContainerHistorialCard({
    super.key,
    required this.datos,
  });

  @override
  Widget build(BuildContext context) {
    // Paleta institucional
    final Color verdePrincipal = const Color(0xFF2E7D32); // Verde oscuro para textos/bordes
    final Color verdeBotonVer = const Color(0xFF1B5E20);  // Verde sólido para el botón "Ver"

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
          // Nombre con Icono de Usuario
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

          // RUT
          Text(
            'RUT: ${datos['rut'] ?? ''}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.green.shade700,
            ),
          ),
          const SizedBox(height: 4),

          // Motivo / Tipo de Informe
          Text(
            datos['motivo'] ?? '',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 8),

          // Fecha de Evaluación
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined, color: Colors.grey, size: 14),
              const SizedBox(width: 6),
              Text(
                'Evaluado el ${datos['fecha'] ?? ''}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Botones de Acción de la Tarjeta
          Row(
            children: [
              // Botón "Ver" (Relleno)
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Implementar lógica para visualizar el informe completo
                  },
                  icon: const Icon(Icons.visibility_outlined, size: 18, color: Colors.white),
                  label: const Text('Ver', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: verdeBotonVer,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              
              // Botón "Descargar" (Delineado)
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // TODO: Implementar lógica de descarga de PDF
                  },
                  icon: Icon(Icons.download_outlined, size: 18, color: verdeBotonVer),
                  label: Text('Descargar', style: TextStyle(color: verdeBotonVer, fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: verdeBotonVer, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}