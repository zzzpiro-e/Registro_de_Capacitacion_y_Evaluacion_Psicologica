// Archivo: container_historial_vacio_psicologo.dart
import 'package:flutter/material.dart';

class ContainerHistorialVacioPsicologo extends StatelessWidget {
  const ContainerHistorialVacioPsicologo({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.picture_as_pdf_outlined, color: Colors.grey.shade400, size: 54),
          const SizedBox(height: 12),
          Text(
            'No se registran informes cargados.', 
            style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
          ),
        ],
      ),
    );
  }
}