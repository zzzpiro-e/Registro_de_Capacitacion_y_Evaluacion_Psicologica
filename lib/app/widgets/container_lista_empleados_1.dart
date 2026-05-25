import 'package:flutter/material.dart';

class ContainerListaEmpleadosUno extends StatelessWidget {
  final String titulo;
  final VoidCallback? onBackTap; // 🔹 Añadimos la función callback

  const ContainerListaEmpleadosUno({
    super.key, 
    required this.titulo,
    this.onBackTap, // 🔹 La incluimos en el constructor
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      color: Colors.white,
      child: Row(
        children: [
          InkWell(
            onTap: () {
              if (onBackTap != null) {
                onBackTap!(); // 🔹 Si se pasa la acción, se ejecuta
              } else {
                Navigator.pop(context); // Comportamiento de respaldo
              }
            },
            child: const Icon(
              Icons.arrow_back_ios_new,
              color: Color(0xFF2E7D32),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            titulo,
            style: const TextStyle(
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