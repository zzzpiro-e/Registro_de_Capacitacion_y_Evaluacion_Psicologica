import 'package:flutter/material.dart';

/// Widget encabezado reutilizable que contiene el título, las sedes e icono de correo.
///
/// Parámetro [title]: Título principal a mostrar.
/// Parámetro [subtitle]: Subtítulo o información adicional.
/// Parámetro [showMailIcon]: Determina si se muestra el icono de correo.
class HeaderTitleWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool showMailIcon;

  const HeaderTitleWidget({
    super.key,
    required this.title,
    required this.subtitle,
    this.showMailIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (showMailIcon)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.mail_outline,
                    color: Colors.blue.shade700,
                    size: 24,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
