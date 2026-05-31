import 'package:cloud_firestore/cloud_firestore.dart';

class DerivacionService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Stream unificado para escuchar las derivaciones por psicólogo
  static Stream<List<Map<String, dynamic>>> obtenerDerivacionesPorPsicologo(String correoPsicologo) {
    return _db
        .collection('derivaciones')
        .where('psicologoEmail', isEqualTo: correoPsicologo)
        .snapshots()
        .asyncMap((derivacionesSnapshot) async {
          List<Map<String, dynamic>> derivacionesCombinadas = [];

          for (var docIn in derivacionesSnapshot.docs) {
            final dataDerivacion = docIn.data();
            // Guardamos el ID del documento de la derivación para poder actualizarlo después
            dataDerivacion['id_documento'] = docIn.id; 
            final String? empleadoId = dataDerivacion['empleadoId'];

            String nombreCompleto = 'Empleado Desconocido';
            String cargo = 'Sin cargo';
            String rut = empleadoId ?? 'Sin RUT';

            if (empleadoId != null && empleadoId.isNotEmpty) {
              final empleadoDoc = await _db.collection('empleados').doc(empleadoId).get();

              if (empleadoDoc.exists) {
                final dataEmpleado = empleadoDoc.data()!;
                final nombres = dataEmpleado['nombres'] ?? '';
                final apellidos = dataEmpleado['apellidos'] ?? '';
                nombreCompleto = '$nombres $apellidos'.trim();
                cargo = dataEmpleado['cargo'] ?? 'Sin cargo';
                rut = dataEmpleado['rut'] ?? empleadoId;
              }
            }

            derivacionesCombinadas.add({
              ...dataDerivacion,
              'nombre': nombreCompleto,
              'cargo': cargo,
              'rut': rut,
            });
          }
          return derivacionesCombinadas;
        });
  }

  // Método para actualizar el estado de la derivación en Firestore
  static Future<void> actualizarEstado(String idDoc, String nuevoEstado) async {
    await _db.collection('derivaciones').doc(idDoc).update({
      'estado': nuevoEstado,
    });
  }

  // Método para registrar los datos del informe PDF seleccionado
  static Future<void> agregarInformePDF({
    required String idDocumento,
    required String nombreArchivo,
    required String fechaSubida,
    required String rutaLocal,
  }) async {
    // Si la derivación tiene un documento asociado, guardamos los metadatos del PDF allí
    if (idDocumento.isNotEmpty) {
      await _db.collection('derivaciones').doc(idDocumento).update({
        'pdfNombre': nombreArchivo,
        'pdfFechaSubida': fechaSubida,
        'pdfRutaSimulada': rutaLocal, // Al ser Web, aquí se guardará el nombre o ruta segura
      });
    }
  }
}