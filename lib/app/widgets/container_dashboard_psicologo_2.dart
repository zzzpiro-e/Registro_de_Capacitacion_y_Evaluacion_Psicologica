// Archivo: container_dashboard_psicologo_2.dart
import 'package:flutter/material.dart';

class ContainerDashboardPsicologoDos extends StatelessWidget {
  final String titulo;
  final String valor;
  final IconData icono;
  final Color color;

  const ContainerDashboardPsicologoDos({
    super.key,
    required this.titulo,
    required this.valor,
    required this.icono,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12, 
            blurRadius: 6, 
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15), 
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icono, color: color, size: 32),
          ),
          const SizedBox(height: 16),
          Text(
            valor, 
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          const SizedBox(height: 4),
          Text(
            titulo, 
            style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}