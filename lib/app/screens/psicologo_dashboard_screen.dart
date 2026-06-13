// Archivo: psicologo_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// 🔹 IMPORTACIÓN DE NUEVOS CONTAINERS EN ESPAÑOL Y RELACIONADOS AL PSICÓLOGO
import '../widgets/container_dashboard_psicologo_1.dart';
import '../widgets/container_dashboard_psicologo_2.dart';

class PsicologoDashboardScreen extends StatefulWidget {
  const PsicologoDashboardScreen({super.key});

  @override
  State<PsicologoDashboardScreen> createState() => _PsicologoDashboardScreenState();
}

class _PsicologoDashboardScreenState extends State<PsicologoDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    // 🔹 OBTENCIÓN DIRECTA: Recuperamos el email del usuario autenticado en Firebase
    final String correoPsicologo = FirebaseAuth.instance.currentUser?.email ?? '';

    return SafeArea(
      child: StreamBuilder<QuerySnapshot>(
        // 🔹 FILTRADO AUTOMÁTICO: Usamos la variable local directa sin depender del constructor
        stream: FirebaseFirestore.instance
            .collection('empleados')
            .where('derivado', isEqualTo: true)
            .where('psicologoEmail', isEqualTo: correoPsicologo)
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

          final bool estaCargando = snapshot.connectionState == ConnectionState.waiting;

          return SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🏢 CONTENEDOR 1: Cabecera de bienvenida con fecha integrada
                const ContainerDashboardPsicologoUno(),
                const SizedBox(height: 24),
                
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Resumen de Casos', 
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF202124)),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ContainerDashboardPsicologoDos(
                              titulo: 'Pendientes',
                              valor: estaCargando ? '...' : '$pendientes',
                              icono: Icons.hourglass_empty,
                              color: const Color(0xFFF57C00),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ContainerDashboardPsicologoDos(
                              titulo: 'En Proceso',
                              valor: estaCargando ? '...' : '$enProceso',
                              icono: Icons.autorenew,
                              color: const Color(0xFF1976D2),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ContainerDashboardPsicologoDos(
                        titulo: 'Atenciones Finalizadas',
                        valor: estaCargando ? '...' : '$completados',
                        icono: Icons.check_circle_outline,
                        color: const Color(0xFF4CAF50),
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
}