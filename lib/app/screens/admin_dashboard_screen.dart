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
    // Fecha actual formateada exactamente igual
    final currentDateRaw = DateFormat('EEEE, d MMMM yyyy', 'es_CL').format(DateTime.now());
    final currentDate = currentDateRaw[0].toUpperCase() + currentDateRaw.substring(1);

    // Paleta de colores exacta de tus pantallas
    const Color verdePrincipal = Color(0xFF388E3C);
    const Color fondoGris = Color(0xFFF5F5F5);

    return Scaffold(
      backgroundColor: fondoGris,
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('trabajadores').snapshots(),
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

                if (data['fechaCreacion'] != null && data['fechaCreacion'] is Timestamp) {
                  DateTime fechaCreacion = (data['fechaCreacion'] as Timestamp).toDate();
                  if (fechaCreacion.month == ahora.month && fechaCreacion.year == ahora.year) {
                    nuevosEsteMes++;
                  }
                }
              }
            }

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🟢 HEADER VERDE SÓLIDO (Idéntico en proporciones y textos a tu captura)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
                    decoration: const BoxDecoration(color: verdePrincipal),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Bienvenido de vuelta',
                          style: TextStyle(
                            color: Colors.white, 
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                          ),
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
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 📄 CUERPO CON LAS TARJETAS ESTILIZADAS
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Resumen del Personal',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E7D32), // Tono verde oscuro de subtítulos
                          ),
                        ),
                        const SizedBox(height: 16),

                        // 📊 TARJETAS HORIZONTALES CON EL ESTILO EXACTO DE TU CAPTURA
                        _buildHorizontalStatCard(
                          title: 'Psicólogos registrados',
                          value: snapshot.connectionState == ConnectionState.waiting ? '...' : '$psicologos',
                          icon: Icons.psychology_outlined,
                          colorIcono: const Color(0xFF1976D2),
                          colorFondoIcono: const Color(0xFFE3F2FD),
                          onTap: () => _abrirTrabajadores(filtroRol: 'psicologo', filtroEstado: 'todos'),
                        ),

                        _buildHorizontalStatCard(
                          title: 'Personal de RRHH',
                          value: snapshot.connectionState == ConnectionState.waiting ? '...' : '$rrhh',
                          icon: Icons.badge_outlined,
                          colorIcono: const Color(0xFF9C27B0),
                          colorFondoIcono: const Color(0xFFF3E5F5),
                          onTap: () => _abrirTrabajadores(filtroRol: 'rrhh', filtroEstado: 'todos'),
                        ),

                        _buildHorizontalStatCard(
                          title: 'Trabajadores Activos',
                          value: snapshot.connectionState == ConnectionState.waiting ? '...' : '$activos',
                          icon: Icons.how_to_reg_outlined,
                          colorIcono: verdePrincipal,
                          colorFondoIcono: const Color(0xFFE8F5E9),
                          onTap: () => _abrirTrabajadores(filtroRol: 'todos', filtroEstado: 'activo'),
                        ),

                        _buildHorizontalStatCard(
                          title: 'Total Usuarios Registrados',
                          value: snapshot.connectionState == ConnectionState.waiting ? '...' : '$totalUsuarios',
                          icon: Icons.groups_outlined,
                          colorIcono: const Color(0xFFF57C00),
                          colorFondoIcono: const Color(0xFFFFF3E0),
                          onTap: () => _abrirTrabajadores(filtroRol: 'todos', filtroEstado: 'todos'),
                        ),

                        const SizedBox(height: 20),
                        const Text(
                          'Auditoría y Rendimiento',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // 🛡️ REGISTRO DE AUDITORÍA CON EL NUEVO ESTILO
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(color: const Color(0xFFEAEAEA), width: 1),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(22),
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
                                    const Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Registro de Auditoría',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            'Ver historial de cambios en el sistema',
                                            style: TextStyle(
                                              fontSize: 13,
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
                        ),

                        // 📈 MÉTRICAS DEL MES AJUSTADAS
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(color: const Color(0xFFEAEAEA), width: 1),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Row(
                                    children: [
                                      Icon(
                                        Icons.trending_up,
                                        color: Color(0xFF2E7D32),
                                        size: 20,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Métricas del Mes',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    DateFormat("MMMM yyyy", 'es_CL').format(DateTime.now()).substring(0, 1).toUpperCase() +
                                        DateFormat("MMMM yyyy", 'es_CL').format(DateTime.now()).substring(1),
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
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
                                  const Expanded(
                                    child: Text(
                                      'nuevos colaboradores registrados',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF558B2F),
                                        fontWeight: FontWeight.w500,
                                      ),
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
      ),
    );
  }

  // 🛠️ COMPONENTE MAESTRO FIEL A TU CAPTURA DE PANTALLA
  Widget _buildHorizontalStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color colorIcono,
    required Color colorFondoIcono,
    required VoidCallback onTap,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16), // Espaciado exacto entre tarjetas
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22), // Redondeado de tus tarjetas
        border: Border.all(
          color: const Color(0xFFEAEAEA), // Borde gris claro sutil perimetral
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12, // Sombra definida hacia abajo igual a tu captura
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(18), // Padding interno balanceado
            child: Row(
              children: [
                // Contenedor del icono cuadrado/redondeado suave
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: colorFondoIcono,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: colorIcono, size: 28),
                ),
                const SizedBox(width: 18),
                // Textos estructurados verticalmente pero ordenados a la derecha del icono
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: colorIcono, // Color según el rol o estado
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        value,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.black, // Número limpio y sólido
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
    );
  }
}
