import 'package:flutter/material.dart';
import '../services/derivaciones_services.dart'; // Tu fuente de verdad con Firestore
import '../widgets/container_historial_card.dart';
import '../widgets/container_historial_buscador.dart';
import '../widgets/container_historial_contador.dart';

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
    // Reemplaza este correo por el email del psicólogo autenticado en tu app
    const String correoPsicologoLogueado = 'psicologo@empresa.cl';

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

                  // 3. Si no hay datos o la colección está vacía
                  final todasLasDerivaciones = snapshot.data ?? [];
                  if (todasLasDerivaciones.isEmpty) {
                    return Column(
                      children: [
                        const ContainerHistorialContador(totalInformes: 0),
                        const Expanded(
                          child: Center(
                            child: Text(
                              'No registras derivaciones asignadas.',
                              style: TextStyle(color: Colors.grey, fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    );
                  }

                  // 4. Aplicamos el filtro de búsqueda local sobre los datos en tiempo real
                  final listaFiltrada = todasLasDerivaciones.where((informe) {
                    final nombre = (informe['nombre'] ?? '').toString().toLowerCase();
                    final rut = (informe['rut'] ?? '').toString().toLowerCase();
                    final motivo = (informe['motivo'] ?? '').toString().toLowerCase();
                    final input = _queryBuscador.toLowerCase();

                    return nombre.contains(input) || rut.contains(input) || motivo.contains(input);
                  }).toList();

                  return Column(
                    children: [
                      // Integración del contenedor modular para el contador total actualizado
                      ContainerHistorialContador(
                        totalInformes: listaFiltrada.length,
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Listado adaptativo de tarjetas de historial clínico
                      Expanded(
                        child: listaFiltrada.isEmpty
                            ? const Center(
                                child: Text(
                                  'No se encontraron informes',
                                  style: TextStyle(color: Colors.grey, fontSize: 16),
                                ),
                              )
                            : ListView.builder(
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