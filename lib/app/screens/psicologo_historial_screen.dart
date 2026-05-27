import 'package:flutter/material.dart';
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

  // Origen de datos estático del historial clínico
  final List<Map<String, dynamic>> _historialInformes = [
    {
      'nombre': 'María González Pérez',
      'rut': '12.345.678-9',
      'motivo': 'Evaluación de estrés laboral',
      'fecha': '19-05-2026',
    },
    {
      'nombre': 'Carlos Rodríguez Silva',
      'rut': '18.765.432-1',
      'motivo': 'Conflicto interpersonal',
      'fecha': '14-05-2026',
    },
    {
      'nombre': 'Ana Martínez López',
      'rut': '15.987.654-3',
      'motivo': 'Adaptación a nuevo cargo',
      'fecha': '09-05-2026',
    },
  ];

  // Estado que almacena la lista filtrada tras la búsqueda
  List<Map<String, dynamic>> _informesFiltrados = [];

  @override
  void initState() {
    super.initState();
    // Inicialización del estado con el listado completo de informes
    _informesFiltrados = _historialInformes;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Filtrado lógico de elementos mediante comparación de cadenas de texto
  void _filtrarInformes(String query) {
    final resultados = _historialInformes.where((informe) {
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