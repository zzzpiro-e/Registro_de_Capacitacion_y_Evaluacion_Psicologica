import 'package:flutter/material.dart';

class ContainerDashboardDos extends StatelessWidget {
  const ContainerDashboardDos({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24).copyWith(top: 16),
      child: Column(
        children: [
          // --- Tarjeta 1: Total Empleados ---
          InkWell(
            onTap: () {
              Navigator.pushNamed(context, 'empleados'); // 🔹 Navegar a lista_empleados_screen.dart
            },
            child: _buildStatCard(
              icon: Icons.groups_outlined,
              iconColor: const Color(0xFF2E7D32),
              title: 'Total Empleados',
              value: '47',
            ),
          ),
          const SizedBox(height: 18),

          // --- Tarjeta 2: Capacitaciones Pendientes ---
          _buildStatCard(
            icon: Icons.school_outlined,
            iconColor: const Color(0xFFFF9800),
            title: 'Capacitaciones Pendientes',
            value: '8',
          ),
          const SizedBox(height: 18),

          // --- Tarjeta 3: Capacitaciones Realizadas ---
          _buildStatCard(
            icon: Icons.check_circle_outline,
            iconColor: const Color(0xFF4CAF50),
            title: 'Capacitaciones Realizadas',
            value: '23',
          ),
          const SizedBox(height: 36),
        ],
      ),
    );
  }

  // --- Widget auxiliar para construir cada tarjeta ---
  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Ícono
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 36,
            ),
          ),
          const SizedBox(width: 20),

          // Texto
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: iconColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
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
