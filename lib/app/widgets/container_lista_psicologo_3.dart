// Archivo: container_lista_psicologo_3.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../screens/psicologo_detalle_derivacion_screen.dart';
import 'container_lista_psicologo_1.dart';

class ContainerListaPsicologoTres extends StatelessWidget {
  final List<QueryDocumentSnapshot> documentosRaw;
  final String filtroTexto;
  final VoidCallback onRefresh;

  const ContainerListaPsicologoTres({
    super.key,
    required this.documentosRaw,
    required this.filtroTexto,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Mapeo y formateo de la data de Firebase
    final todosLosEmpleados = documentosRaw.map((doc) {
      final data = doc.data() as Map<String, dynamic>;

      String fechaIngreso = 'N/A';
      if (data['fechaIngreso'] is Timestamp) {
        fechaIngreso = DateFormat(
          'dd/MM/yyyy',
        ).format((data['fechaIngreso'] as Timestamp).toDate());
      }

      String nombreCompleto = '';
      if (data['nombre'] != null && data['nombre'].toString().isNotEmpty) {
        nombreCompleto = data['nombre'].toString().trim();
      } else {
        final String nombres = data['nombres'] ?? 'Sin nombre';
        final String apellidos = data['apellidos'] ?? '';
        nombreCompleto = "$nombres $apellidos".trim();
      }

      String estadoClinico = data['estado'] ?? 'Pendiente';
      if (estadoClinico.toLowerCase() == 'activo') {
        estadoClinico = 'Pendiente';
      }

      return {
        'id': doc.id,
        'nombre': nombreCompleto,
        'rut': data['rut'] ?? 'Sin RUT',
        'cargo': data['cargo'] ?? 'Sin cargo',
        'area': data['area'] ?? 'No especificada',
        'edad': data['edad']?.toString() ?? 'N/A',
        'estado': estadoClinico,
        'fechaIngreso': fechaIngreso,
        'salario': '******',
        'fichaPsicologica': data['fichaPsicologica'] ?? '',
        'motivo': data['motivo'] ?? 'No especificado',
        'fecha': data['fechaDerivacion'] ?? data['fecha'] ?? 'Hoy',
      };
    }).toList();

    // 2. Filtrado en memoria
    final empleadosFiltrados = todosLosEmpleados.where((empleado) {
      final String nombre = empleado['nombre'].toString().toLowerCase();
      final String rut = empleado['rut'].toString().toLowerCase();
      final String cargo = empleado['cargo'].toString().toLowerCase();

      return nombre.contains(filtroTexto) ||
          rut.contains(filtroTexto) ||
          cargo.contains(filtroTexto);
    }).toList();

    if (empleadosFiltrados.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            'No se encontraron resultados para "$filtroTexto"',
            style: const TextStyle(color: Colors.grey, fontSize: 15),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    // 3. Renderizado del listado usando el Container 1
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: empleadosFiltrados.length,
      itemBuilder: (context, index) {
        final empleado = empleadosFiltrados[index];

        return ContainerListaPsicologoUno(
          empleado: empleado,
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    PsicologoDetalleDerivacionScreen(derivacion: empleado),
              ),
            );
            onRefresh(); // Notifica a la pantalla principal que haga el setState
          },
        );
      },
    );
  }
}
