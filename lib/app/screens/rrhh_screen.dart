import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:proyecto_flutter/app/widgets/container_dashboard_1.dart';
import 'package:proyecto_flutter/app/widgets/container_dashboard_2.dart';

class RrhhScreen extends StatelessWidget {
  const RrhhScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ContainerDashboardUno(),
              const SizedBox(height: 18),
              const ContainerDashboardDos(),
              const SizedBox(height: 18),
              // Accesos rápidos (RRHH) - no incluir "Crear Empleado"
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
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

                    // Ver Empleados
                    _quickActionCard(
                      context,
                      icon: Icons.groups_outlined,
                      title: 'Ver Empleados',
                      subtitle: 'Lista completa de empleados',
                    ),
                    const SizedBox(height: 18),

                    // Gestionar Capacitaciones
                    _quickActionCard(
                      context,
                      icon: Icons.checklist_outlined,
                      title: 'Gestionar Capacitaciones',
                      subtitle: 'Administrar capacitaciones externas',
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _quickActionCard(BuildContext context,
      {required IconData icon,
      required String title,
      required String subtitle}) {
    return Container(
      width: double.infinity,
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
