import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../widgets/dashboard_stat_card.dart';
import '../widgets/quick_action_card.dart';
import 'package:proyecto_flutter/shared/widgets/custom_bottom_nav_bar.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentDateRaw = DateFormat(
      'EEEE, d MMMM yyyy',
      'es_ES',
    ).format(DateTime.now());

    final currentDate =
        currentDateRaw[0].toUpperCase() +
        currentDateRaw.substring(1);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),

      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 0,
        onTap: (index) {},
      ),

      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 80),
              decoration: const BoxDecoration(
                color: Color(0xFF388E3C),
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Bienvenido de vuelta',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    'Jefe de RRHH',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    currentDate,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Transform.translate(
                offset: const Offset(0, -55),

                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),

                  children: const [
                    DashboardStatCard(
                      title: 'Total Empleados',
                      value: '47',
                      icon: Icons.groups_outlined,
                      iconColor: Color(0xFF2E7D32),
                    ),

                    SizedBox(height: 18),

                    DashboardStatCard(
                      title: 'Capacitaciones Pendientes',
                      value: '8',
                      icon: Icons.school_outlined,
                      iconColor: Color(0xFFFF9800),
                    ),

                    SizedBox(height: 18),

                    DashboardStatCard(
                      title: 'Capacitaciones Realizadas',
                      value: '23',
                      icon: Icons.check_circle_outline,
                      iconColor: Color(0xFF4CAF50),
                    ),

                    SizedBox(height: 36),

                    Text(
                      'Accesos Rápidos',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF202124),
                      ),
                    ),

                    SizedBox(height: 20),

                    QuickActionCard(
                      title: 'Crear Empleado',
                      subtitle: 'Agregar nuevo empleado al sistema',
                      icon: Icons.person_add_alt_1_outlined,
                    ),

                    SizedBox(height: 18),

                    QuickActionCard(
                      title: 'Ver Empleados',
                      subtitle: 'Lista completa de empleados',
                      icon: Icons.groups_outlined,
                    ),

                    SizedBox(height: 18),

                    QuickActionCard(
                      title: 'Gestionar Capacitaciones',
                      subtitle: 'Administrar capacitaciones externas',
                      icon: Icons.checklist_outlined,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}