import 'package:flutter/material.dart';

class CrearBurbujas extends StatelessWidget {
  final VoidCallback onCrearEmpleado;
  final VoidCallback onCrearCapacitacion;

  const CrearBurbujas({
    super.key,
    required this.onCrearEmpleado,
    required this.onCrearCapacitacion,
  });

  @override
  Widget build(BuildContext context) {
    const Color verdePrincipal = Color(0xFF2E7D32);

    return Positioned(
      bottom: 80,
      right: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _bubbleButton(
            iconColor: verdePrincipal,
            label: 'Empleado',
            onTap: onCrearEmpleado,
          ),
          const SizedBox(height: 12),
          _bubbleButton(
            iconColor: verdePrincipal,
            label: 'Capacitación',
            onTap: onCrearCapacitacion,
          ),
        ],
      ),
    );
  }

  Widget _bubbleButton({
    required Color iconColor,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add, color: iconColor, size: 24),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(color: iconColor, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
