import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDashboardScreen extends StatelessWidget {
  final void Function(String roleFilter, String statusFilter) onOpenWorkersTab;
  final VoidCallback onOpenAuditoriaTab;

  const AdminDashboardScreen({
    super.key,
    required this.onOpenWorkersTab,
    required this.onOpenAuditoriaTab,
  });

  void _abrirTrabajadores({
    required String filtroRol,
    required String filtroEstado,
  }) {
    onOpenWorkersTab(filtroRol, filtroEstado);
  }

  @override
  Widget build(BuildContext context) {
    // Fecha actual formateada exactamente igual a la otra pantalla 📅
    final currentDateRaw = DateFormat(
      'EEEE, d MMMM yyyy',
      'es_CL',
    ).format(DateTime.now());
    final currentDate =
        currentDateRaw[0].toUpperCase() + currentDateRaw.substring(1);

    return SafeArea(
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('trabajadores')
            .snapshots(),
        builder: (context, snapshot) {
          int totalUsuarios = 0;
          int activos = 0;
          int psicologos = 0;
          int rrhh = 0;
          int nuevosEsteMes = 0;

          final DateTime ahora = DateTime.now();

          if (snapshot.hasData && snapshot.data != null) {
            final docs = snapshot.data!.docs;
            totalUsuarios = docs.length;

            for (var doc in docs) {
              final data = doc.data() as Map<String, dynamic>;

              String rol = (data['rol'] ?? '').toString().trim().toLowerCase();
              if (rol == 'psicologo') {
                psicologos++;
              } else if (rol == 'rrhh') {
                rrhh++;
              }

              bool esActivo = data['activo'] ?? true;
              if (esActivo) activos++;

              if (data['fechaCreacion'] != null &&
                  data['fechaCreacion'] is Timestamp) {
                DateTime fechaCreacion = (data['fechaCreacion'] as Timestamp)
                    .toDate();
                if (fechaCreacion.month == ahora.month &&
                    fechaCreacion.year == ahora.year) {
                  nuevosEsteMes++;
                }
              }
            }
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
                  decoration: const BoxDecoration(color: Color(0xFF388E3C)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Bienvenido de vuelta',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Administrador',
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
                const SizedBox(height: 24),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Resumen del Personal',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF202124),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Fila de 2 Tarjetas (Psicólogos y RRHH)
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              'Psicólogos',
                              snapshot.connectionState ==
                                      ConnectionState.waiting
                                  ? '...'
                                  : '$psicologos',
                              Icons.psychology_outlined,
                              const Color(0xFF1976D2), // Azul para psicólogos
                              onTap: () => _abrirTrabajadores(
                                filtroRol: 'psicologo',
                                filtroEstado: 'todos',
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildStatCard(
                              'Personal RRHH',
                              snapshot.connectionState ==
                                      ConnectionState.waiting
                                  ? '...'
                                  : '$rrhh',
                              Icons.badge_outlined,
                              const Color(0xFF9C27B0), // Morado para RRHH
                              onTap: () => _abrirTrabajadores(
                                filtroRol: 'rrhh',
                                filtroEstado: 'todos',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Tarjeta de todo el ancho: Activos
                      _buildStatCard(
                        'Trabajadores Activos',
                        snapshot.connectionState == ConnectionState.waiting
                            ? '...'
                            : '$activos',
                        Icons.how_to_reg_outlined,
                        const Color(0xFF4CAF50), // Verde exitoso para Activos
                        onTap: () => _abrirTrabajadores(
                          filtroRol: 'todos',
                          filtroEstado: 'activo',
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildStatCard(
                        'Total Usuarios Registrados',
                        snapshot.connectionState == ConnectionState.waiting
                            ? '...'
                            : '$totalUsuarios',
                        Icons.groups_outlined,
                        const Color(0xFFF57C00), // Naranja para el global
                        onTap: () => _abrirTrabajadores(
                          filtroRol: 'todos',
                          filtroEstado: 'todos',
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Divider(height: 1, color: Color(0xFFEAEAEA)),
                      const SizedBox(height: 20),
                      const Text(
                        'Auditoría y Rendimiento',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF202124),
                        ),
                      ),
                      const SizedBox(height: 16),

                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: const Color(0xFFEAEAEA),
                            width: 1,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(22),
                          onTap: onOpenAuditoriaTab,
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFF3CD),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Icon(
                                    Icons.history_outlined,
                                    color: Color(0xFFB8860B),
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: const [
                                      Text(
                                        'Registro de Auditoría',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'Ver historial de cambios en el sistema',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.chevron_right,
                                  color: Colors.grey,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F9FA),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: const Color(0xFFEAEAEA),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: const [
                                    Icon(
                                      Icons.trending_up,
                                      color: Color(0xFF2E7D32),
                                      size: 20,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Métricas del Mes',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  DateFormat("MMMM yyyy", 'es_CL')
                                          .format(DateTime.now())
                                          .substring(0, 1)
                                          .toUpperCase() +
                                      DateFormat(
                                        "MMMM yyyy",
                                        'es_CL',
                                      ).format(DateTime.now()).substring(1),
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 13,
                                  ),
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
                                  style: const TextStyle(
                                    fontSize: 34,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2E7D32),
                                  ),
                                ),
                                const Text(
                                  'nuevos colaboradores registrados',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF558B2F),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
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

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color, {
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 4)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: color, size: 32),
                ),
                const SizedBox(height: 16),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
