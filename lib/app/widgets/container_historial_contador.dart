import 'package:flutter/material.dart';

class ContainerHistorialContador extends StatelessWidget {
  final int totalInformes;

  const ContainerHistorialContador({
    super.key,
    required this.totalInformes,
  });

  @override
  Widget build(BuildContext context) {
    const Color verdeBanner = Color(0xFF2E7D32);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: verdeBanner,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Total de Informes',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$totalInformes',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}