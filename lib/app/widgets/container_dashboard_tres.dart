import 'package:flutter/material.dart';

class ContainerDashboardTres extends StatelessWidget {
  const ContainerDashboardTres({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Accesos Rápidos',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D32),
            ),
          ),

          const SizedBox(height: 18),

          _buildAccesoRapido(
            context,
            icon: Icons.person_add_alt_1,
            titulo: 'Crear Empleado',
            onTap: () {
              Navigator.pushNamed(context, 'crear_empleado');
            },
          ),

          const SizedBox(height: 16),

          _buildAccesoRapido(
            context,
            icon: Icons.groups,
            titulo: 'Ver Empleados',
            onTap: () {
              Navigator.pushNamed(context, 'empleados');
            },
          ),

          const SizedBox(height: 16),

          _buildAccesoRapido(
            context,
            icon: Icons.school,
            titulo: 'Gestionar Capacitaciones',
            onTap: () {
              Navigator.pushNamed(context, 'capacitaciones');
            },
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildAccesoRapido(
    BuildContext context, {
    required IconData icon,
    required String titulo,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
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
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D32).withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: const Color(0xFF2E7D32), size: 34),
            ),

            const SizedBox(width: 18),

            Expanded(
              child: Text(
                titulo,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ),

            const Icon(
              Icons.arrow_forward_ios,
              size: 18,
              color: Color(0xFF2E7D32),
            ),
          ],
        ),
      ),
    );
  }
}
