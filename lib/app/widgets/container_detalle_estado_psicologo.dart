// Archivo: container_detalle_estado_psicologo.dart
import 'package:flutter/material.dart';

class ContainerDetalleEstadoPsicologo extends StatelessWidget {
  final String estadoActual;

  const ContainerDetalleEstadoPsicologo({
    super.key,
    required this.estadoActual,
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
    return Center(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
        decoration: BoxDecoration(
          color: _colorEstado(estadoActual),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          estadoActual,
          style: TextStyle(
            fontSize: 14, 
            fontWeight: FontWeight.bold, 
            color: _colorTextoEstado(estadoActual),
          ),
        ),
      ),
    );
  }
}