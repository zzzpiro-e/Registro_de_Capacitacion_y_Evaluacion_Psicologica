import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class CapacitacionesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> obtenerCapacitaciones() {
    return _firestore.collection('capacitaciones').snapshots();
  }

  List<String> convertirAListaString(dynamic campo) {
    if (campo == null) return [];

    if (campo is List) {
      return campo
          .map((e) => e.toString().trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }

    if (campo is String) {
      if (campo.trim().isEmpty) return [];

      return campo
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }

    return [];
  }

  Future<void> verificarYActualizarEstado(
    String docId,
    dynamic asignados,
    dynamic realizaron,
    String estadoActual,
  ) async {
    if (estadoActual.trim().toLowerCase() == 'realizada') return;

    final listaAsignados = convertirAListaString(asignados);
    final listaRealizaron = convertirAListaString(realizaron);

    if (listaAsignados.isEmpty && listaRealizaron.isEmpty) return;
    if (listaAsignados.isEmpty || listaRealizaron.isEmpty) return;

    final setAsignados = listaAsignados.toSet();
    final setRealizaron = listaRealizaron.toSet();

    if (setAsignados.length == setRealizaron.length &&
        setAsignados.containsAll(setRealizaron)) {
      try {
        await _firestore
            .collection('capacitaciones')
            .doc(docId)
            .update({'estado': 'realizada'});

        debugPrint(
          'Capacitación con RUTs $docId completada con éxito.',
        );
      } catch (e) {
        debugPrint(
          'Error en actualización automática: $e',
        );
      }
    }
  }
}