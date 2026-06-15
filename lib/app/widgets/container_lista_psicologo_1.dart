// Archivo: container_lista_psicologo_1.dart
import 'package:flutter/material.dart';

class ContainerListaPsicologoUno extends StatelessWidget {
  final Map<String, dynamic> empleado;
  final VoidCallback onTap;

  const ContainerListaPsicologoUno({
    super.key,
    required this.empleado,
    required this.onTap,
  });

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
    return InkWell(
      onTap: onTap,
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
  }
}