import 'package:flutter/material.dart';

/// Widget para mostrar una imagen de pie de página o laboratorio.
///
/// Parámetro [imagePath]: Ruta de la imagen (puede ser asset o URL).
/// Parámetro [height]: Altura personalizada de la imagen.
/// Parámetro [borderRadius]: Radio de esquinas de la imagen.
class FooterImageWidget extends StatelessWidget {
  final String imagePath;
  final double height;
  final double borderRadius;

  const FooterImageWidget({
    super.key,
    required this.imagePath,
    this.height = 200,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Image.asset(
          imagePath,
          height: height,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: height,
              color: Colors.grey.shade300,
              child: const Center(
                child: Icon(Icons.broken_image, size: 48, color: Colors.grey),
              ),
            );
          },
        ),
      ),
    );
  }
}
