// Archivo: psicologo_historial_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/derivaciones_services.dart'; 
import '../widgets/container_historial_buscador.dart';

// 🏢 IMPORTACIÓN DEL CONTENEDOR CON TU NOMBRE SOLICITADO
import '../widgets/container_historial_procesador_psicologo.dart';

class PsicologoHistorialScreen extends StatefulWidget {
  const PsicologoHistorialScreen({super.key});

  @override
  State<PsicologoHistorialScreen> createState() => _PsicologoHistorialScreenState();
}

class _PsicologoHistorialScreenState extends State<PsicologoHistorialScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _queryBuscador = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String correoPsicologoLogueado = FirebaseAuth.instance.currentUser?.email ?? '';

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            const SizedBox(height: 12),
            
            // Buscador del historial
            ContainerHistorialBuscador(
              controller: _searchController,
              onChanged: (value) => setState(() => _queryBuscador = value),
            ),
            
            const SizedBox(height: 16),

            // El StreamBuilder solo actúa como puente de datos en tiempo real hacia el procesador
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: DerivacionService.obtenerDerivacionesPorPsicologo(correoPsicologoLogueado),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: Color(0xFF2E7D32)),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error al cargar el historial: ${snapshot.error}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  // 🏢 LLAMADA AL PROCESADOR CON TU NUEVO NOMBRE CORREGIDO
                  return ContainerHistorialProcesadorPsicologo(
                    todasLasDerivaciones: snapshot.data ?? [],
                    queryBuscador: _queryBuscador,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}