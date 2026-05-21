import 'package:flutter/material.dart';

class ContainerDashboardTres extends StatelessWidget {
  const ContainerDashboardTres({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Accesos Rápidos',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF202124),
              ),
            ),
            const SizedBox(height: 20),

            // --- Tarjeta 1: Crear Empleado ---
            _buildQuickActionCard(
              icon: Icons.person_add_alt_1_outlined,
              title: 'Crear Empleado',
              subtitle: 'Agregar nuevo empleado al sistema',
            ),
            const SizedBox(height: 18),

            // --- Tarjeta 2: Ver Empleados ---
            _buildQuickActionCard(
              icon: Icons.groups_outlined,
              title: 'Ver Empleados',
              subtitle: 'Lista completa de empleados',
            ),
            const SizedBox(height: 18),

            // --- Tarjeta 3: Gestionar Capacitaciones ---
            _buildQuickActionCard(
              icon: Icons.checklist_outlined,
              title: 'Gestionar Capacitaciones',
              subtitle: 'Administrar capacitaciones externas',
            ),

            const SizedBox(height: 40), // 🔹 espacio extra al final
          ],
        ),
      ),
    );
  }

  // --- Widget auxiliar para construir cada tarjeta ---
  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
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
              color: const Color(0xFF4CAF50).withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF4CAF50),
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
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF202124),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF2E7D32),
                    fontWeight: FontWeight.w500,
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
