// Archivo: container_historial_casos_completados.dart
import 'package:flutter/material.dart';
import '../widgets/container_historial_contador.dart';
import '../widgets/container_historial_card.dart';

class ContainerHistorialCasosCompletados extends StatelessWidget {
  final List<Map<String, dynamic>> listaFiltrada;

  const ContainerHistorialCasosCompletados({
    super.key,
    required this.listaFiltrada,
  });

  @override
  Widget build(BuildContext context) {
    // Si la lista final está vacía, mostramos el mensaje de que no hay registros
    if (listaFiltrada.isEmpty) {
      return const Column(
        children: [
          ContainerHistorialContador(totalInformes: 0),
          Expanded(
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

    // Si hay datos, renderizamos el contador real y las tarjetas correspondientes
    return Column(
      children: [
        ContainerHistorialContador(totalInformes: listaFiltrada.length),
        const SizedBox(height: 20),
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
  }
}