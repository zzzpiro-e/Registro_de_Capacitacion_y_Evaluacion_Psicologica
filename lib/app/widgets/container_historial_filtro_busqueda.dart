// Archivo: container_filtro_busqueda_historial.dart
import 'package:flutter/material.dart';
import 'container_historial_casos_completados.dart';

class ContainerHistorialFiltroBusqueda extends StatelessWidget {
  final List<Map<String, dynamic>> todasLasDerivaciones;
  final String queryBuscador;

  const ContainerHistorialFiltroBusqueda({
    super.key,
    required this.todasLasDerivaciones,
    required this.queryBuscador,
  });

  @override
  Widget build(BuildContext context) {
    final listaFiltrada = todasLasDerivaciones.where((informe) {
      final String estado = (informe['estado'] ?? '').toString().toLowerCase();
      if (estado != 'completado') {
        return false; 
      }

      final nombre = (informe['nombre'] ?? '').toString().toLowerCase();
      final rut = (informe['rut'] ?? '').toString().toLowerCase();
      final motivo = (informe['motivo'] ?? '').toString().toLowerCase();
      final input = queryBuscador.toLowerCase().trim();

      return nombre.contains(input) || rut.contains(input) || motivo.contains(input);
    }).toList();

    return ContainerHistorialCasosCompletados(listaFiltrada: listaFiltrada);
  }
}