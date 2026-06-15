import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CapacitacionesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==================== STREAMS ====================
  
  Stream<QuerySnapshot> obtenerCapacitaciones() {
    return _firestore.collection('capacitaciones').snapshots();
  }

  Stream<QuerySnapshot> obtenerCapacitacionesPorEstado(String estado) {
    if (estado == 'todas') {
      return obtenerCapacitaciones();
    }
    return _firestore
        .collection('capacitaciones')
        .where('estado', isEqualTo: estado)
        .snapshots();
  }

  // ==================== MÉTODOS PARA CONTEOS ====================
  
  Future<Map<String, int>> obtenerConteos() async {
    try {
      final snapshot = await _firestore
          .collection('capacitaciones')
          .get()
          .timeout(const Duration(seconds: 10));

      int pendientes = 0;
      int realizadas = 0;

      for (var doc in snapshot.docs) {
        final estado = (doc['estado'] ?? '').toString().trim().toLowerCase();
        if (estado == 'pendiente') pendientes++;
        if (estado == 'realizada') realizadas++;
      }

      return {
        'pendientes': pendientes,
        'realizadas': realizadas,
        'totales': snapshot.docs.length,
      };
    } catch (e) {
      throw Exception('Fallo al conectar con el servidor');
    }
  }

  // ==================== MÉTODOS PARA LISTAS ====================
  
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

  // ==================== MÉTODOS PARA CONVERSIÓN ====================
  
  Map<String, dynamic> convertirDocumento(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final docId = doc.id;

    return {
      ...data,
      'id': docId,
      'fechaInicioFormateada': _formatearFecha(data['fechaInicio']),
      'fechaFinFormateada': _formatearFecha(data['fechaFin']),
      'estadoNormalizado': (data['estado'] ?? 'pendiente').toString().toLowerCase(),
      'esRealizada': (data['estado'] ?? 'pendiente').toString().toLowerCase() == 'realizada',
    };
  }

  List<Map<String, dynamic>> convertirLista(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) => convertirDocumento(doc)).toList();
  }

  // ==================== MÉTODOS PARA FILTRADO ====================
  
  List<Map<String, dynamic>> filtrarPorEstado(
    List<Map<String, dynamic>> capacitaciones,
    String estado,
  ) {
    if (estado == 'todas') return capacitaciones;
    
    return capacitaciones.where((cap) {
      final estadoCap = (cap['estado'] ?? 'pendiente').toString().toLowerCase();
      return estadoCap == estado;
    }).toList();
  }

  // ==================== MÉTODOS PARA ESTADOS ====================
  
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
        debugPrint('Capacitación $docId completada con éxito.');
      } catch (e) {
        debugPrint('Error en actualización automática: $e');
      }
    }
  }

  Future<void> verificarTodosLosEstados() async {
    final snapshot = await _firestore.collection('capacitaciones').get();
    for (final doc in snapshot.docs) {
      final data = doc.data();
      final estadoActual = (data['estado'] ?? 'pendiente').toString();
      await verificarYActualizarEstado(
        doc.id,
        data['empleadosAsignados'],
        data['empleadosRealizaron'],
        estadoActual,
      );
    }
  }

  // ==================== MÉTODOS ESTÁTICOS PARA UI ====================
  
  static Color getColorEtiqueta(String estado) {
    final esRealizada = estado.toLowerCase() == 'realizada';
    return esRealizada ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0);
  }

  static Color getColorTexto(String estado) {
    final esRealizada = estado.toLowerCase() == 'realizada';
    return esRealizada ? const Color(0xFF2E7D32) : Colors.orange;
  }

  static IconData getIconoEstado(String estado) {
    final esRealizada = estado.toLowerCase() == 'realizada';
    return esRealizada ? Icons.check_circle : Icons.schedule;
  }

  static String getTextoEstado(String estado) {
    final esRealizada = estado.toLowerCase() == 'realizada';
    return esRealizada ? 'Realizada' : 'Pendiente';
  }

  // ==================== MÉTODOS PRIVADOS ====================

  String _formatearFecha(Timestamp? timestamp) {
    if (timestamp == null) return 'Sin fecha';
    final fecha = timestamp.toDate();
    return "${fecha.day}/${fecha.month}/${fecha.year}";
  }

  // ==================== MÉTODOS ADICIONALES ====================

Future<List<Map<String, dynamic>>> obtenerDetallesEmpleados(
  List<String> ruts,
) async {
  String normalizar(String rut) {
    return rut
        .replaceAll('.', '')
        .replaceAll('-', '')
        .replaceAll(' ', '')
        .trim()
        .toLowerCase();
  }

  final snapshot = await _firestore.collection('empleados').get();

  List<Map<String, dynamic>> resultado = [];

  for (final rutBuscado in ruts) {
    final rutNormalizado = normalizar(rutBuscado);

    debugPrint("");
    debugPrint("=================================");
    debugPrint("BUSCANDO RUT: $rutBuscado");
    debugPrint("NORMALIZADO: $rutNormalizado");

    Map<String, dynamic>? empleado;

    for (final doc in snapshot.docs) {
      final data = doc.data();

      final rutCampo =
          data['rut']?.toString() ??
          '';

      final rutCampoNormalizado = normalizar(rutCampo);

      if (rutCampoNormalizado == rutNormalizado) {
        empleado = {
          'rut': rutCampo,
          'nombre': data['nombres'] ?? '',
          'apellido': data['apellidos'] ?? '',
        };

        debugPrint(
          "ENCONTRADO -> ${data['nombres']} ${data['apellidos']}",
        );

        break;
      }
    }

    if (empleado != null) {
      resultado.add(empleado);
    } else {
      debugPrint("NO ENCONTRADO -> $rutBuscado");

      resultado.add({
        'rut': rutBuscado,
        'nombre': 'RUT: $rutBuscado',
        'apellido': '(Perfil pendiente)',
      });
    }
  }

  debugPrint("=================================");

  return resultado;
}
}