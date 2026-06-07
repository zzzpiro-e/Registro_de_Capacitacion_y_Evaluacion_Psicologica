import 'package:flutter/material.dart';

class ContainerListaEmpleadosUno extends StatelessWidget {
  final String titulo;
  final VoidCallback? onBackTap;

  const ContainerListaEmpleadosUno({
    super.key, 
    required this.titulo,
    this.onBackTap,
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
                onBackTap!();
              } else {
                Navigator.pop(context);
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