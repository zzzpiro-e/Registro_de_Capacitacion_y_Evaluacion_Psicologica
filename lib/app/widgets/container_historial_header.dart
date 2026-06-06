import 'package:flutter/material.dart';

class ContainerHistorialHeader extends StatelessWidget {
  final String nombre;
  final String rut;

  const ContainerHistorialHeader({
    super.key,
    required this.nombre,
    required this.rut,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            nombre, 
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)
          ),
          const SizedBox(height: 4),
          Text(
            'RUT: $rut', 
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.green.shade700)
          ),
        ],
      ),
    );
  }
}