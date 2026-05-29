import 'package:flutter/material.dart';

/// Widget reutilizable y paramétrico para bloques de texto informativos.
///
/// Implementa el patrón DRY (Don't Repeat Yourself) para evitar duplicación
/// de código en bloques de contenido similar (encabezado + descripción).
///
/// Parámetro [title]: Título del bloque.
/// Parámetro [description]: Descripción o contenido principal.
/// Parámetro [isHighlighted]: Define si el texto tiene énfasis visual.
/// Parámetro [textColor]: Color personalizado para el título (por defecto: negro).
class CustomTextBlock extends StatelessWidget {
  final String title;
  final String description;
  final bool isHighlighted;
  final Color textColor;

  const CustomTextBlock({
    super.key,
    required this.title,
    required this.description,
    this.isHighlighted = false,
    this.textColor = Colors.black87,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isHighlighted ? Colors.blue.shade50 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isHighlighted ? Colors.blue.shade300 : Colors.grey.shade300,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isHighlighted ? Colors.blue.shade700 : textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            textAlign: TextAlign.justify,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
