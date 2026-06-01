import 'package:flutter/material.dart';
import '../services/derivaciones_services.dart'; // Apuntamos a nuestra única fuente de verdad
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

  // Estado que almacena la lista filtrada tras la búsqueda
  List<Map<String, dynamic>> _informesFiltrados = [];

  @override
  void initState() {
    super.initState();
    // Leemos directamente del servicio compartido para que la data sea consistente en toda la app
    _informesFiltrados = DerivacionService.derivaciones;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Filtrado lógico de elementos apuntando al servicio global
  void _filtrarInformes(String query) {
    final resultados = DerivacionService.derivaciones.where((informe) {
      final nombre = (informe['nombre'] ?? '').toString().toLowerCase();
      final rut = (informe['rut'] ?? '').toString().toLowerCase();
      final motivo = (informe['motivo'] ?? '').toString().toLowerCase();
      final input = query.toLowerCase();

      return nombre.contains(input) || rut.contains(input) || motivo.contains(input);
    }).toList();

    setState(() {
      _informesFiltrados = resultados;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Truco: Si el buscador está vacío, volvemos a capturar el estado global actualizado por si se subió un nuevo PDF
    if (_searchController.text.isEmpty) {
      _informesFiltrados = DerivacionService.derivaciones;
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            const SizedBox(height: 12),
            
            // Integración del contenedor modular para el buscador
            ContainerHistorialBuscador(
              controller: _searchController,
              onChanged: _filtrarInformes,
            ),
            
            const SizedBox(height: 16),
            
            // Integración del contenedor modular para el contador total
            ContainerHistorialContador(
              totalInformes: _informesFiltrados.length,
            ),
            
            const SizedBox(height: 20),
            
            // Listado adaptativo de tarjetas de historial clínico
            Expanded(
              child: _informesFiltrados.isEmpty
                  ? const Center(
                      child: Text(
                        'No se encontraron informes',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: _informesFiltrados.length,
                      itemBuilder: (context, index) {
                        final item = _informesFiltrados[index];
                        return ContainerHistorialCard(datos: item);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}