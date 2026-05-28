import 'package:flutter/material.dart';

class ContainerCrearEmpleadoUno extends StatelessWidget {
  const ContainerCrearEmpleadoUno({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      color: Colors.white,
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.pop(context),
            child: const Icon(
              Icons.arrow_back_ios_new,
              color: Color(0xFF2E7D32), // verde institucional
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Crear Empleado',
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
