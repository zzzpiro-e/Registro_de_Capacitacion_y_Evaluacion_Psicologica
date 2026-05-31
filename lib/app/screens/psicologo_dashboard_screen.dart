import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/derivaciones_services.dart'; 

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
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
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

            // Contadores de estado vinculados en tiempo real a Firebase
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Resumen de Casos', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF202124))),
                  const SizedBox(height: 16),
                  
                  StreamBuilder<List<Map<String, dynamic>>>(
                    stream: DerivacionService.obtenerDerivacionesPorPsicologo('psicologo@empresa.cl'), // Filtramos por el correo de la base de datos
                    builder: (context, snapshot) {
                      // 1. Mientras conecta a Firebase, mostramos un cargador sutil
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: Center(child: CircularProgressIndicator(color: Color(0xFF388E3C))),
                        );
                      }

                      // Valores iniciales por defecto si no hay datos o la colección está vacía
                      int pendientes = 0;
                      int enProceso = 0;
                      int finalizadas = 0;

                      // 2. Si hay datos reales, calculamos las cantidades filtrando la lista por 'estado'
                      if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                        final listaDerivaciones = snapshot.data!;
                        
                        // Filtramos las derivaciones contando cuántas corresponden a cada estado
                        // (Asegúrate de que coincida con los textos que asigne tu app, ej: "Pendiente", "En Proceso", "Completado")
                        pendientes = listaDerivaciones.where((d) => d['estado'] == 'Pendiente').length;
                        enProceso = listaDerivaciones.where((d) => d['estado'] == 'En Proceso').length;
                        finalizadas = listaDerivaciones.where((d) => d['estado'] == 'Completado').length;
                      }

                      // 3. Pintamos las tarjetas con los datos reales calculados al vuelo
                      return Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  'Pendientes', 
                                  '$pendientes', 
                                  Icons.hourglass_empty, 
                                  const Color(0xFFF57C00)
                                )
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildStatCard(
                                  'En Proceso', 
                                  '$enProceso', 
                                  Icons.autorenew, 
                                  const Color(0xFF1976D2)
                                )
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildStatCard(
                            'Atenciones Finalizadas', 
                            '$finalizadas', 
                            Icons.check_circle_outline, 
                            const Color(0xFF4CAF50)
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
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