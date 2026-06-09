import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class CapacitacionesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==================== STREAMS ORIGINALES ====================
  
  Stream<QuerySnapshot> obtenerCapacitaciones() {
    return _firestore.collection('capacitaciones').snapshots();
  }

  // NUEVO: Obtener capacitaciones filtradas por estado (optimizado)
  Stream<QuerySnapshot> obtenerCapacitacionesPorEstado(String estado) {
    if (estado == 'todas') {
      return obtenerCapacitaciones();
    }
    
    return _firestore
        .collection('capacitaciones')
        .where('estado', isEqualTo: estado)
        .snapshots();
  }

  // ==================== MÉTODOS EXISTENTES (MANTENIDOS) ====================
  
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

  // MÉTODO EXISTENTE MEJORADO
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

  // NUEVO: Verificar múltiples capacitaciones (para initState)
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

  // ==================== NUEVOS MÉTODOS OPTIMIZADOS ====================

  // Convertir un solo documento a modelo
  Map<String, dynamic> convertirDocumento(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final docId = doc.id;

    return {
      ...data,
      'id': docId,
      'estadoNormalizado': _normalizarEstado(data['estado']),
      'fechaInicioFormateada': _formatearFecha(data['fechaInicio']),
      'fechaFinFormateada': _formatearFecha(data['fechaFin']),
      'progreso': _calcularProgreso(
        data['empleadosAsignados'],
        data['empleadosRealizaron'],
      ),
    };
  }

  // Convertir lista completa (reemplaza el map que hacías en el widget)
  List<Map<String, dynamic>> convertirLista(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) => convertirDocumento(doc)).toList();
  }

  // Filtrar en memoria (fallback si no usas el stream filtrado)
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

  // Obtener estadísticas para el dashboard
  Future<Map<String, int>> obtenerEstadisticas() async {
    final snapshot = await _firestore.collection('capacitaciones').get();
    
    int pendientes = 0;
    int realizadas = 0;
    
    for (final doc in snapshot.docs) {
      final estado = (doc.data()['estado'] ?? 'pendiente').toString().toLowerCase();
      if (estado == 'pendiente') {
        pendientes++;
      } else if (estado == 'realizada') {
        realizadas++;
      }
    }
    
    return {
      'pendientes': pendientes,
      'realizadas': realizadas,
      'totales': snapshot.docs.length,
    };
  }

  // ==================== MÉTODOS PRIVADOS ====================

  String _normalizarEstado(dynamic estado) {
    final estadoStr = (estado ?? 'pendiente').toString().trim().toLowerCase();
    return estadoStr;
  }

  String _formatearFecha(Timestamp? timestamp) {
    if (timestamp == null) return 'Sin fecha';
    final fecha = timestamp.toDate();
    return "${fecha.day}/${fecha.month}/${fecha.year}";
  }

  int _calcularProgreso(dynamic asignados, dynamic realizaron) {
    final listaAsignados = convertirAListaString(asignados);
    final listaRealizaron = convertirAListaString(realizaron);
    
    final total = listaAsignados.length;
    final realizados = listaRealizaron.length;
    
    if (total == 0) return 0;
    return ((realizados / total) * 100).round();
  }
}