import 'package:cloud_firestore/cloud_firestore.dart';

class DerivacionService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// STREAM EN TIEMPO REAL: Obtiene los empleados derivados que pertenecen a un psicólogo específico.
  static Stream<List<Map<String, dynamic>>> obtenerDerivacionesPorPsicologo(String emailPsicologo) {
    return _db
        .collection('empleados')
        .where('derivado', isEqualTo: true)
        .where('psicologoEmail', isEqualTo: emailPsicologo)
        .snapshots()
        .map((snapshot) {
      List<Map<String, dynamic>> lista = [];
      
      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data();
        
        // Inyectamos el ID del documento
        data['id_documento'] = doc.id;
        
        // Mapeo y normalización de nombres según tu Firestore ("nombres" y "apellidos")
        data['nombre'] = data['nombre'] ?? '${data['nombres'] ?? ''} ${data['apellidos'] ?? ''}'.trim();
        if (data['nombre'].toString().isEmpty) {
          data['nombre'] = 'Empleado Sin Nombre';
        }
        
        // Resguardos por si faltan campos en la UI
        data['rut'] = data['rut'] ?? doc.id;
        data['estado'] = data['estado'] ?? 'Pendiente';
        data['cargo'] = data['cargo'] ?? 'Sin cargo';
        data['area'] = data['area'] ?? 'No especificada';
        
        // Según tu captura, el motivo o diagnóstico viene en 'fichaPsicologica'
        data['motivo'] = data['fichaPsicologica'] ?? data['motivo'] ?? 'No especificado';
        
        // Mapeo adaptativo de la fecha
        if (data['derivacionFecha'] != null) {
          // Si viene como Timestamp de Firebase lo manejamos, si no, que use fallback
          data['fecha'] = data['derivacionFecha'];
        } else {
          data['fecha'] = 'Hoy'; 
        }

        lista.add(data);
      }
      return lista;
    });
  }

  /// STREAM COMPLEMENTARIO: Obtiene todos los empleados sin filtros por si lo usas en otra vista
  static Stream<List<Map<String, dynamic>>> obtenerEmpleadosDesdeFirebase() {
    return _db.collection('empleados').snapshots().map((snapshot) {
      List<Map<String, dynamic>> lista = [];
      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data();
        data['id_documento'] = doc.id;
        data['nombre'] = data['nombre'] ?? '${data['nombres'] ?? ''} ${data['apellidos'] ?? ''}'.trim();
        lista.add(data);
      }
      return lista;
    });
  }

  /// Método para actualizar el estado de un empleado directamente en Firestore
  static Future<void> actualizarEstado(String idDoc, String nuevoEstado) async {
    await _db.collection('empleados').doc(idDoc).update({
      'estado': nuevoEstado,
    });
  }
}