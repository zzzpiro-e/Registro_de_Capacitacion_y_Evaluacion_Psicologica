import 'package:flutter/material.dart';

class ContainerPerfilPsicologoUno extends StatelessWidget {
  final Map<String, dynamic> datos; // Recibe los datos reales de Firestore

  const ContainerPerfilPsicologoUno({
    super.key,
    required this.datos,
  });

  @override
  Widget build(BuildContext context) {
    // Formateamos el rol que viene en minúscula desde el admin
    String rolFormateado = (datos['rol'] == 'psicologo') ? 'Psicólogo' : 'Trabajador';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF388E3C), // Tu verde institucional
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 36,
            backgroundColor: Color(0xFF66BB6A), // Fondo sutil para el icono
            child: Icon(
              Icons.person,
              size: 42,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  datos['nombre'] ?? 'Sin Nombre',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  rolFormateado,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}