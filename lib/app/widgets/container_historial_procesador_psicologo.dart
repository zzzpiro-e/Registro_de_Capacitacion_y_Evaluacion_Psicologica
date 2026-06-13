// Archivo: container_historial_procesador_psicologo.dart
import 'package:flutter/material.dart';
import 'container_historial_casos_completados.dart';

class ContainerHistorialProcesadorPsicologo extends StatelessWidget {
  final List<Map<String, dynamic>> todasLasDerivaciones;
  final String queryBuscador;

  const ContainerHistorialProcesadorPsicologo({
    super.key,
    required this.todasLasDerivaciones,
    required this.queryBuscador,
  });

  @override
  Widget build(BuildContext context) {
    // Aplicamos el filtro en memoria
    final listaFiltrada = todasLasDerivaciones.where((informe) {
      // 1. Filtro estricto por estado completado
      final String estado = (informe['estado'] ?? '').toString().toLowerCase();
      if (estado != 'completado') {
        return false; 
      }

      // 2. Filtro dinámico por el input del buscador (nombre, rut o motivo)
      final nombre = (informe['nombre'] ?? '').toString().toLowerCase();
      final rut = (informe['rut'] ?? '').toString().toLowerCase();
      final motivo = (informe['motivo'] ?? '').toString().toLowerCase();
      final input = queryBuscador.toLowerCase().trim();

      return nombre.contains(input) || rut.contains(input) || motivo.contains(input);
    }).toList();

    // Le pasamos la lista limpia al componente de UI que definimos arriba
    return ContainerHistorialCasosCompletados(listaFiltrada: listaFiltrada);
  }
}