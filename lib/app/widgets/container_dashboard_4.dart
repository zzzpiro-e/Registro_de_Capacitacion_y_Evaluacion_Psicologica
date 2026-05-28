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
            isActive: false,
            onTap: () {
              Navigator.pushNamed(context, 'inicio');
            },
          ),
          _buildNavItem(
            context,
            icon: Icons.groups_outlined,
            label: 'Empleados',
            isActive: false,
            onTap: () {
              Navigator.pushNamed(context, 'empleados');
            },
          ),
          _buildNavItem(
            context,
            icon: Icons.school_outlined,
            label: 'Capacitaciones',
            isActive: false,
            onTap: () {
              Navigator.pushNamed(context, 'capacitaciones');
            },
          ),
          _buildNavItem(
            context,
            icon: Icons.add_circle_outline,
            label: 'Crear',
            isActive: true, // 🔹 aquí marcamos activo cuando estamos en "Crear"
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
    required bool isActive,
    required VoidCallback onTap,
  }) {
    final Color activeColor = const Color(0xFF2E7D32);
    final Color inactiveColor = Colors.grey;

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? activeColor : inactiveColor,
            size: isActive ? 34 : 28, // 🔹 más grande si está activo
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: isActive ? activeColor : inactiveColor,
              fontSize: 14,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
