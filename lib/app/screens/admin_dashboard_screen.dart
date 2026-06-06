import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AdminDashboardScreen extends StatelessWidget {
  final void Function(String roleFilter, String statusFilter) onOpenWorkersTab;

  const AdminDashboardScreen({super.key, required this.onOpenWorkersTab});

  void _abrirTrabajadores({required String filtroRol, required String filtroEstado}) {
    onOpenWorkersTab(filtroRol, filtroEstado);
  }

  @override
  Widget build(BuildContext context) {
    // Fecha actual formateada elegantemente 📅
    String fechaActual = DateFormat("EEEE, d 'de' MMMM 'de' yyyy", 'es_ES').format(DateTime.now());
    fechaActual = fechaActual.substring(0, 1).toUpperCase() + fechaActual.substring(1);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('trabajadores').snapshots(),
        builder: (context, snapshot) {
          int totalUsuarios = 0;
          int activos = 0;
          int psicologos = 0;
          int rrhh = 0;
          int nuevosEsteMes = 0;

          if (snapshot.hasData) {
            final docs = snapshot.data!.docs;
            totalUsuarios = docs.length;

            DateTime ahora = DateTime.now();
            DateTime inicioMes = DateTime(ahora.year, ahora.month, 1);
            for (var doc in docs) {
              var data = doc.data() as Map<String, dynamic>;
              
              String rol = data['rol'] ?? '';
              if (rol == 'psicologo') {
                psicologos++;
              } else if (rol == 'rrhh') {
                rrhh++;
              }

              bool esActivo = data['activo'] ?? true; 
              if (esActivo) activos++;

              if (data['fechaCreacion'] != null) {
                Timestamp timestamp = data['fechaCreacion'];
                DateTime fechaCreacion = timestamp.toDate();
                if (fechaCreacion.isAfter(inicioMes)) {
                  nuevosEsteMes++;
                }
              }
            }
          }

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                // Header Verde Curvo de Bienvenida
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFF43A047),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(32),
                      bottomRight: Radius.circular(32),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 28.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.shield_outlined, color: Colors.white, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'Bienvenido de vuelta',
                            style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Administrador',
                        style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        fechaActual, 
                        style: const TextStyle(color: Colors.white60, fontSize: 15),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      if (snapshot.connectionState == ConnectionState.waiting)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24.0),
                          child: CircularProgressIndicator(color: Color(0xFF43A047)),
                        )
                      else ...[
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1.3,
                          children: [
                            _buildGridStatCard(icon: Icons.groups_outlined, title: 'Total Usuarios', value: '$totalUsuarios', color: Colors.green, onTap: () => _abrirTrabajadores(filtroRol: 'todos', filtroEstado: 'todos')),
                            _buildGridStatCard(icon: Icons.how_to_reg_outlined, title: 'Activos', value: '$activos', color: Colors.teal, onTap: () => _abrirTrabajadores(filtroRol: 'todos', filtroEstado: 'activo')),
                            _buildGridStatCard(icon: Icons.psychology_outlined, title: 'Psicólogos', value: '$psicologos', color: Colors.blue, onTap: () => _abrirTrabajadores(filtroRol: 'psicologo', filtroEstado: 'todos')),
                            _buildGridStatCard(icon: Icons.badge_outlined, title: 'RRHH', value: '$rrhh', color: Colors.purple, onTap: () => _abrirTrabajadores(filtroRol: 'rrhh', filtroEstado: 'todos')),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Tarjeta de rendimiento mensual
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F9FA),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: const Color(0xFFEAEAEA), width: 1),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: const [
                                      Icon(Icons.trending_up, color: Color(0xFF2E7D32)),
                                      SizedBox(width: 8),
                                      Text('Este Mes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                                    ],
                                  ),
                                  Text(
                                    DateFormat("MMMM yyyy", 'es_ES').format(DateTime.now()).substring(0, 1).toUpperCase() + DateFormat("MMMM yyyy", 'es_ES').format(DateTime.now()).substring(1), 
                                    style: const TextStyle(color: Colors.grey, fontSize: 14)
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    '$nuevosEsteMes ',
                                    style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
                                  ),
                                  const Text(
                                    'nuevos usuarios',
                                    style: TextStyle(fontSize: 16, color: Color(0xFF558B2F), fontWeight: FontWeight.w500),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildGridStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 22),
                  const SizedBox(width: 8),
                  Expanded(child: Text(title, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis)),
                ],
              ),
              Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}