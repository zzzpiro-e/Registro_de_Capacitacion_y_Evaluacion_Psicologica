import 'package:flutter/material.dart';

/// Widget que representa una fila de botones de acción reutilizable.
///
/// Parámetro [buttons]: Lista de mapas con 'icon' y 'label' para cada botón.
/// Parámetro [onButtonPressed]: Callback cuando se presiona un botón, recibe el índice.
class ActionButtonsRow extends StatelessWidget {
  final List<Map<String, dynamic>> buttons;
  final Function(int) onButtonPressed;

  const ActionButtonsRow({
    super.key,
    required this.buttons,
    required this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(
          buttons.length,
          (index) => GestureDetector(
            onTap: () => onButtonPressed(index),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    buttons[index]['icon'] as IconData,
                    size: 20,
                    color: Colors.blue.shade700,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    buttons[index]['label'] as String,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
