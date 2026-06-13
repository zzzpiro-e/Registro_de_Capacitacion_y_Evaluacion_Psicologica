// Archivo: container_lista_psicologo_2.dart
import 'package:flutter/material.dart';

class ContainerListaPsicologoDos extends StatelessWidget {
  final String titulo;

  const ContainerListaPsicologoDos({
    super.key,
    required this.titulo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      color: Colors.white,
      width: double.infinity,
      child: Text(
        titulo,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }
}