import 'package:flutter/material.dart';

class ContainerListaEmpleadosCuatro extends StatelessWidget {
  const ContainerListaEmpleadosCuatro({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // 🔹 Inicio (gris, con navegación)
          _buildNavItem(
            context,
            icon: Icons.home,
            label: 'Inicio',
            color: Colors.grey,
            size: 28,
            onTap: () {
              Navigator.pushNamed(context, '/inicio');
            },
          ),

          // 🔹 Empleados (activo y resaltado)
          _buildNavItem(
            context,
            icon: Icons.groups_outlined,
            label: 'Empleados',
            color: const Color(0xFF2E7D32),
            size: 34,
            onTap: () {
              // Ya estamos en Empleados, no navega
            },
          ),

          // 🔹 Capacitaciones (gris)
          _buildNavItem(
            context,
            icon: Icons.school_outlined,
            label: 'Capacitaciones',
            color: Colors.grey,
            size: 28,
            onTap: () {
              // Se agregará navegación más adelante
            },
          ),

          // 🔹 Crear (gris)
          _buildNavItem(
            context,
            icon: Icons.add_circle_outline,
            label: 'Crear',
            color: Colors.grey,
            size: 28,
            onTap: () {
              // Se agregará navegación más adelante
            },
          ),
        ],
      ),
    );
  }

  // --- Widget auxiliar para cada ítem del menú ---
  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required double size,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: size),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
