// Archivo: container_dashboard_psicologo_1.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ContainerDashboardPsicologoUno extends StatelessWidget {
  const ContainerDashboardPsicologoUno({super.key});

  @override
  Widget build(BuildContext context) {
    final currentDateRaw = DateFormat('EEEE, d MMMM yyyy', 'es_CL').format(DateTime.now());
    final currentDate = currentDateRaw[0].toUpperCase() + currentDateRaw.substring(1);

    return Container(
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
            'Psicólogo Laboral', 
            style: TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Text(
            currentDate, 
            style: const TextStyle(color: Colors.white, fontSize: 20),
          ),
        ],
      ),
    );
  }
}