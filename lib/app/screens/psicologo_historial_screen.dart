import 'package:flutter/material.dart';
import '../services/derivaciones_services.dart'; // Tu fuente de verdad con Firestore
import '../widgets/container_historial_card.dart';
import '../widgets/container_historial_buscador.dart';
import '../widgets/container_historial_contador.dart';
// 🔹 IMPORTANTE: Importamos FirebaseAuth para leer la sesión en caliente
import 'package:firebase_auth/firebase_auth.dart';

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
    // 🔹 OBTENCIÓN DIRECTA: Capturamos el correo del usuario logueado en Firebase de forma reactiva
    final String correoPsicologoLogueado = FirebaseAuth.instance.currentUser?.email ?? '';

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            const SizedBox(height: 12),
            
            // Integración del contenedor modular para el buscador
            ContainerHistorialBuscador(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _queryBuscador = value;
                });
              },
            ),
            
            const SizedBox(height: 16),

            // Consumimos el Stream en tiempo real de Firebase Firestore
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: DerivacionService.obtenerDerivacionesPorPsicologo(correoPsicologoLogueado),
                builder: (context, snapshot) {
                  // 1. Mostrar indicador de carga mientras conecta a Firestore
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: Color(0xFF2E7D32)),
                    );
                  }

                  // 2. Controlar errores de conexión o permisos
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error al cargar el historial: ${snapshot.error}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  // 3. Obtener todas las derivaciones asociadas al psicólogo
                  final todasLasDerivaciones = snapshot.data ?? [];

                  // 4. Filtrar localmente para que SOLO se muestren los casos "Completado"
                  //    y además respondan a los criterios del cuadro de búsqueda.
                  final listaFiltrada = todasLasDerivaciones.where((informe) {
                    // Criterio de Estado Clínico obligatorio
                    final String estado = (informe['estado'] ?? '').toString().toLowerCase();
                    if (estado != 'completado') {
                      return false; // Si no está completado, se descarta de inmediato
                    }

                    // Criterios del cuadro de búsqueda (Filtro local existente)
                    final nombre = (informe['nombre'] ?? '').toString().toLowerCase();
                    final rut = (informe['rut'] ?? '').toString().toLowerCase();
                    final motivo = (informe['motivo'] ?? '').toString().toLowerCase();
                    final input = _queryBuscador.toLowerCase();

                    return nombre.contains(input) || rut.contains(input) || motivo.contains(input);
                  }).toList();

                  // 5. Si la lista filtrada queda vacía (porque no hay completados o no coinciden búsquedas)
                  if (listaFiltrada.isEmpty) {
                    return Column(
                      children: [
                        const ContainerHistorialContador(totalInformes: 0),
                        const Expanded(
                          child: Center(
                            child: Text(
                              'No registras casos completados en el historial.',
                              style: TextStyle(color: Colors.grey, fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    );
                  }

                  return Column(
                    children: [
                      // Integración del contenedor modular para el contador total actualizado
                      ContainerHistorialContador(
                        totalInformes: listaFiltrada.length,
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Listado adaptativo de tarjetas de historial clínico
                      Expanded(
                        child: ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: listaFiltrada.length,
                          itemBuilder: (context, index) {
                            final item = listaFiltrada[index];
                            return ContainerHistorialCard(datos: item);
                          },
                        ),
                      ),
                    ],
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