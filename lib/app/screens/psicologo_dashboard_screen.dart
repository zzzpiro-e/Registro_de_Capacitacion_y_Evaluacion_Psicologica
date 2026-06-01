import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PsicologoDashboardScreen extends StatefulWidget {
  const PsicologoDashboardScreen({super.key});

  @override
  State<PsicologoDashboardScreen> createState() => _PsicologoDashboardScreenState();
}

class _PsicologoDashboardScreenState extends State<PsicologoDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final currentDateRaw = DateFormat('EEEE, d MMMM yyyy', 'es_CL').format(DateTime.now());
    final currentDate = currentDateRaw[0].toUpperCase() + currentDateRaw.substring(1);

    return SafeArea(
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('empleados')
            .where('derivado', isEqualTo: true)
            .snapshots(),
        builder: (context, snapshot) {
          int pendientes = 0;
          int enProceso = 0;
          int completados = 0;

          if (snapshot.hasData && snapshot.data != null) {
            for (var doc in snapshot.data!.docs) {
              final datos = doc.data() as Map<String, dynamic>;
              String estadoLimpio = (datos['estado'] ?? '').toString().trim().toLowerCase();
              if (estadoLimpio == 'en proceso') {
                enProceso++;
              } else if (estadoLimpio == 'completado') {
                completados++;
              } else {
                pendientes++;
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
                      const Text('Bienvenido de vuelta', style: TextStyle(color: Colors.white, fontSize: 18)),
                      const SizedBox(height: 12),
                      const Text('Psicólogo Laboral', style: TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20),
                      Text(currentDate, style: const TextStyle(color: Colors.white, fontSize: 20)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Resumen de Casos', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF202124))),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              'Pendientes', 
                              snapshot.connectionState == ConnectionState.waiting ? '...' : '$pendientes', 
                              Icons.hourglass_empty, 
                              const Color(0xFFF57C00)
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildStatCard(
                              'En Proceso', 
                              snapshot.connectionState == ConnectionState.waiting ? '...' : '$enProceso', 
                              Icons.autorenew, 
                              const Color(0xFF1976D2)
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildStatCard(
                        'Atenciones Finalizadas', 
                        snapshot.connectionState == ConnectionState.waiting ? '...' : '$completados', 
                        Icons.check_circle_outline, 
                        const Color(0xFF4CAF50)
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

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(16)),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(height: 16),
          Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black)),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}