import 'package:flutter/material.dart';

class ContainerCapacitacionesUno extends StatelessWidget {
  final VoidCallback? onBackTap;

  const ContainerCapacitacionesUno({super.key, this.onBackTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      color: Colors.white,
      child: Row(
        children: [
          InkWell(
            onTap: onBackTap ?? () => Navigator.pop(context),
            child: const Icon(
              Icons.arrow_back_ios_new,
              color: Color(0xFF2E7D32), // verde institucional
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Capacitaciones',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
