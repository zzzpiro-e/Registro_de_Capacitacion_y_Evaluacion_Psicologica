import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proyecto_flutter/app/screens/capacitaciones_screen.dart'; // importa tu página

class ContainerDashboardDos extends StatelessWidget {
  const ContainerDashboardDos({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24).copyWith(top: 16),
      child: Column(
        children: [
          // --- Tarjeta 1: Total Empleados ---
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('empleados').snapshots(),
            builder: (context, snapshot) {
              final total = snapshot.hasData ? snapshot.data!.docs.length : 0;
              return InkWell(
                onTap: () {
                  Navigator.pushNamed(context, 'empleados');
                },
                child: _buildStatCard(
                  icon: Icons.groups_outlined,
                  iconColor: const Color(0xFF2E7D32),
                  title: 'Total Empleados',
                  value: total.toString(),
                ),
              );
            },
          ),
          const SizedBox(height: 18),

          // --- Tarjetas de Capacitaciones ---
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('capacitaciones').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Column(
                  children: [
                    _buildStatCard(
                      icon: Icons.school_outlined,
                      iconColor: const Color(0xFFFF9800),
                      title: 'Capacitaciones Pendientes',
                      value: '...',
                    ),
                    const SizedBox(height: 18),
                    _buildStatCard(
                      icon: Icons.check_circle_outline,
                      iconColor: const Color(0xFF4CAF50),
                      title: 'Capacitaciones Realizadas',
                      value: '...',
                    ),
                    const SizedBox(height: 18),
                    _buildStatCard(
                      icon: Icons.list_alt_outlined,
                      iconColor: Colors.blueGrey,
                      title: 'Capacitaciones Totales',
                      value: '...',
                    ),
                  ],
                );
              }

              final docs = snapshot.data!.docs;

              final pendientes = docs.where((doc) {
                final estado = (doc['estado'] ?? '').toString().trim().toLowerCase();
                return estado == 'pendiente';
              }).length;

              final realizadas = docs.where((doc) {
                final estado = (doc['estado'] ?? '').toString().trim().toLowerCase();
                return estado == 'realizada';
              }).length;

              final totales = docs.length;

              return Column(
                children: [
                  // Pendientes
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CapacitacionesPage(filtroInicial: 'pendiente'),
                        ),
                      );
                    },
                    child: _buildStatCard(
                      icon: Icons.school_outlined,
                      iconColor: const Color(0xFFFF9800),
                      title: 'Capacitaciones Pendientes',
                      value: pendientes.toString(),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Realizadas
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CapacitacionesPage(filtroInicial: 'realizada'),
                        ),
                      );
                    },
                    child: _buildStatCard(
                      icon: Icons.check_circle_outline,
                      iconColor: const Color(0xFF4CAF50),
                      title: 'Capacitaciones Realizadas',
                      value: realizadas.toString(),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Totales
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CapacitacionesPage(filtroInicial: 'todas'),
                        ),
                      );
                    },
                    child: _buildStatCard(
                      icon: Icons.list_alt_outlined,
                      iconColor: Colors.blueGrey,
                      title: 'Capacitaciones Totales',
                      value: totales.toString(),
                    ),
                  ),
                ],
              );
            },
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
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: iconColor, size: 36),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                      color: iconColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    )),
                const SizedBox(height: 6),
                Text(value,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
