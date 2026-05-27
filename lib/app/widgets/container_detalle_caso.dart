import 'package:flutter/material.dart';

class ContainerDetalleCaso extends StatelessWidget {
  final Map<String, dynamic> datos;

  const ContainerDetalleCaso({
    super.key,
    required this.datos,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.description_outlined, color: Color(0xFF2E7D32), size: 24),
              SizedBox(width: 10),
              Text(
                'Detalles de la Derivación',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDatoItem('Fecha de Derivación', datos['fecha'] ?? 'No especificada'),
          const SizedBox(height: 14),
          _buildDatoItem('Motivo', datos['motivo'] ?? 'No especificado'),
          const SizedBox(height: 14),
          _buildDatoItem(
            'Descripción',
            datos['descripcion'] ?? 'Trabajadora presenta síntomas de estrés elevado debido a alta carga laboral durante el último trimestre. Se solicita evaluación psicológica y recomendaciones.',
          ),
        ],
      ),
    );
  }

  Widget _buildDatoItem(String etiqueta, String valor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(etiqueta, style: const TextStyle(fontSize: 13, color: Color(0xFF2E7D32), fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        Text(
          valor,
          style: const TextStyle(fontSize: 15, color: Colors.black87, height: 1.3),
        ),
      ],
    );
  }
}