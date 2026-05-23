import 'package:flutter/material.dart';

class ContainerDashboardCuatro extends StatelessWidget {
  const ContainerDashboardCuatro({super.key});

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
          _buildNavItem(
            context,
            icon: Icons.home,
            label: 'Inicio',
            color: const Color(0xFF2E7D32),
            onTap: () {
              // 🔹 Navegar a pantalla de inicio
              Navigator.pushNamed(context, 'inicio');
            },
          ),
          _buildNavItem(
            context,
            icon: Icons.groups_outlined,
            label: 'Empleados',
            color: const Color(0xFF2E7D32),
            onTap: () {
              Navigator.pushNamed(context, 'empleados'); // 🔹 coincide con AppRoutes
            },
          ),

          _buildNavItem(
            context,
            icon: Icons.school_outlined,
            label: 'Capacitaciones',
            color: const Color(0xFF2E7D32),
            onTap: () {
              Navigator.pushNamed(context, 'capacitaciones');
            },
          ),
          _buildNavItem(
            context,
            icon: Icons.add_circle_outline,
            label: 'Crear',
            color: const Color(0xFF2E7D32),
            onTap: () {
              Navigator.pushNamed(context, 'crear');
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
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 14, // 🔹 un poco más pequeño para evitar overflow
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
