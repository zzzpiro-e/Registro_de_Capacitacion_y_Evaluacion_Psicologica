import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'lista_empleadosrrhh.dart';
import 'capacitaciones_rrhh.dart';

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

              const SizedBox(height: 20),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Panel RRHH',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [

                    Row(
                      children: [
                        Expanded(
                          child: _statCard(
                            context: context,
                            title: "Empleados",
                            stream: FirebaseFirestore.instance
                                .collection('empleados')
                                .snapshots(),
                            icon: Icons.people,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _statCard(
                            context: context,
                            title: "Pendientes",
                            filter: "Pendiente",
                            stream: FirebaseFirestore.instance
                                .collection('capacitaciones')
                                .where('estado', isEqualTo: 'Pendiente')
                                .snapshots(),
                            icon: Icons.hourglass_bottom,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: _statCard(
                            context: context,
                            title: "En Proceso",
                            filter: "Proceso",
                            stream: FirebaseFirestore.instance
                                .collection('capacitaciones')
                                .where('estado', isEqualTo: 'Proceso')
                                .snapshots(),
                            icon: Icons.autorenew,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _statCard(
                            context: context,
                            title: "Completadas",
                            filter: "Completada",
                            stream: FirebaseFirestore.instance
                                .collection('capacitaciones')
                                .where('estado', isEqualTo: 'Completada')
                                .snapshots(),
                            icon: Icons.check_circle,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _actionCard(
                  context,
                  icon: Icons.groups,
                  title: 'Ver Empleados',
                  subtitle: 'Lista completa de empleados',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const ListaEmpleadosRRHH(),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 18),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _actionCard(
                  context,
                  icon: Icons.checklist,
                  title: 'Gestionar Capacitaciones',
                  subtitle: 'Ver todas las capacitaciones',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const CapacitacionesRRHH(),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statCard({
    required BuildContext context,
    required String title,
    required Stream<QuerySnapshot> stream,
    required IconData icon,
    String? filter,
  }) {
    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (context, snapshot) {
        final count =
            snapshot.hasData ? snapshot.data!.docs.length : 0;

        return InkWell(
          borderRadius: BorderRadius.circular(18),

          onTap: filter == null
              ? null
              : () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CapacitacionesRRHH(
                        estadoInicial: filter,
                      ),
                    ),
                  );
                },

          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 6,
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(icon, color: const Color(0xFF4CAF50)),
                const SizedBox(height: 10),
                Text(
                  "$count",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(title),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _actionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
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
                child: Icon(icon,
                    color: const Color(0xFF4CAF50), size: 36),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}