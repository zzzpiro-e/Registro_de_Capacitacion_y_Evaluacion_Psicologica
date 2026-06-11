import 'package:flutter/material.dart';

class ContainerListaEmpleadosUno extends StatelessWidget {
  final String titulo;
  final VoidCallback? onBackTap;

  const ContainerListaEmpleadosUno({
    super.key, 
    required this.titulo,
    this.onBackTap,
  });

  void _handleBack(BuildContext context) {
    if (onBackTap != null) {
      onBackTap!();
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      color: Colors.white,
      child: Row(
        children: [
          InkWell(
            onTap: () => _handleBack(context),
            borderRadius: BorderRadius.circular(30), // 👈 Feedback táctil
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(
                Icons.arrow_back_ios_new,
                color: Color(0xFF2E7D32),
                size: 22,
              ),
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